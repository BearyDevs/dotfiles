"""FastAPI parser.

Uses Python's stdlib `ast` module for accuracy. Walks the project looking for
`APIRouter()` / `FastAPI()` instances, extracts their prefixes, and resolves
`app.include_router(router, prefix=...)` calls to compose final paths.

Pydantic models used as request bodies are resolved across files by matching
class names. We don't do a full import graph — in practice a BaseModel
referenced in a handler is either imported and visible in the file, or defined
in the same file. We index every BaseModel in the project upfront so a
cross-file reference is just a dict lookup.
"""

from __future__ import annotations

import ast
from pathlib import Path
from typing import Any

from common import (
    Endpoint,
    extract_path_params,
    iter_files,
    normalize_path,
    pascal_to_folder,
)


HTTP_DECORATORS = {"get", "post", "put", "patch", "delete", "head", "options"}


def parse(root: Path, verbose: bool = False) -> tuple[list[Endpoint], list[str]]:
    files = iter_files(root, (".py",))
    warnings: list[str] = []

    # Pre-parse every file once; cache trees.
    trees: dict[Path, ast.Module] = {}
    for f in files:
        tree = _parse_file(f)
        if tree is not None:
            trees[f] = tree

    # 1) Index all Pydantic models across the project.
    models: dict[str, list[dict[str, Any]]] = {}
    for tree in trees.values():
        for node in ast.walk(tree):
            if isinstance(node, ast.ClassDef) and _is_basemodel(node):
                models[node.name] = _basemodel_fields(node)

    # 2) Build a file-level import map: in each file, which *module* path does
    #    each imported name refer to? We use this to resolve `users.router` →
    #    the file app/routers/users.py.
    module_paths = _index_modules(root, list(trees.keys()))  # dotted path -> file Path
    imports_by_file: dict[Path, dict[str, Path]] = {}
    for f, tree in trees.items():
        local_map: dict[str, Path] = {}
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    target = _resolve_module(alias.name, module_paths, f)
                    if target is not None:
                        local_map[alias.asname or alias.name.split(".")[-1]] = target
            elif isinstance(node, ast.ImportFrom) and node.module:
                for alias in node.names:
                    # Prefer resolving "module.alias" first — this handles the
                    # common FastAPI pattern `from app.routers import users`
                    # where `users` is itself a module.
                    dotted_full = f"{node.module}.{alias.name}"
                    target = _resolve_module(dotted_full, module_paths, f)
                    if target is None:
                        target = _resolve_module(node.module, module_paths, f)
                    if target is not None:
                        local_map[alias.asname or alias.name] = target
        imports_by_file[f] = local_map

    # 3) First pass over every file: find APIRouter/FastAPI instantiations
    #    (with their local prefixes), handlers with decorators, and
    #    include_router calls to determine extra prefixes to apply.
    endpoints: list[Endpoint] = []
    extra_prefix_by_file: dict[Path, str] = {}

    # include_router calls must run first so that the prefix is known by the
    # time we emit endpoints. But we can't know all of them until we scan every
    # file — so do a dedicated pass.
    for f, tree in trees.items():
        for node in ast.walk(tree):
            if isinstance(node, ast.Expr) and isinstance(node.value, ast.Call):
                call = node.value
                if not _call_name(call, attr="include_router") or not call.args:
                    continue
                extra = _kwarg_string(call, "prefix") or ""
                target_file = _resolve_router_arg(
                    call.args[0], imports_by_file.get(f, {})
                )
                if target_file is None:
                    continue
                existing = extra_prefix_by_file.get(target_file, "")
                extra_prefix_by_file[target_file] = existing + extra

    # 4) Second pass: emit endpoints with the correct combined prefix.
    for f, tree in trees.items():
        folder_base = pascal_to_folder(f.stem)
        extra_prefix = extra_prefix_by_file.get(f, "")

        local_routers: dict[str, str] = {}
        for node in ast.walk(tree):
            if isinstance(node, ast.Assign) and isinstance(node.value, ast.Call):
                if _call_name(node.value) in {"APIRouter", "FastAPI"}:
                    prefix = _kwarg_string(node.value, "prefix") or ""
                    for target in node.targets:
                        if isinstance(target, ast.Name):
                            local_routers[target.id] = prefix

        file_count = 0
        for node in ast.walk(tree):
            if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                continue
            for deco in node.decorator_list:
                info = _decorator_info(deco)
                if info is None:
                    continue
                router_var, method, path_arg = info
                router_prefix = local_routers.get(router_var, "")
                full_path = normalize_path(extra_prefix, router_prefix, path_arg)

                auth = _detect_auth(node)
                body = _detect_body(node, models)
                query = _detect_query(node, full_path)

                endpoints.append(
                    Endpoint(
                        method=method.upper(),
                        path=full_path,
                        folder=folder_base,
                        name=f"{method.upper()} {full_path}",
                        body=body,
                        query_params=query,
                        path_params=extract_path_params(full_path),
                        auth=auth,
                        source=f"{f}:{node.lineno}",
                    )
                )
                file_count += 1
        if verbose and file_count:
            print(f"[fastapi] {f}: {file_count} endpoints")

    return endpoints, warnings


# ---------- module / import resolution ----------


def _index_modules(root: Path, files: list[Path]) -> dict[str, Path]:
    """Build a map from dotted module path → file path.

    We try several roots (the project root, and any `src/` or `app/` under it)
    because Python projects are inconsistent about where the module root lives.
    """
    candidates_roots = [root]
    for extra in ("src", "app"):
        candidate = root / extra
        if candidate.is_dir():
            candidates_roots.append(candidate)

    out: dict[str, Path] = {}
    for f in files:
        for r in candidates_roots:
            try:
                rel = f.relative_to(r)
            except ValueError:
                continue
            parts = list(rel.with_suffix("").parts)
            if parts and parts[-1] == "__init__":
                parts.pop()
            if not parts:
                continue
            dotted = ".".join(parts)
            # Prefer the shortest (most specific) match; last write wins is fine
            # since file→path is a function.
            out[dotted] = f
            # Also register without the leading src/app segment style.
            break
    return out


def _resolve_module(
    dotted: str, module_paths: dict[str, Path], from_file: Path
) -> Path | None:
    # Try exact match first.
    if dotted in module_paths:
        return module_paths[dotted]
    # Try progressively stripping the leading component (handles `app.routers.users`
    # when modules were indexed relative to `app/`).
    parts = dotted.split(".")
    for i in range(1, len(parts)):
        key = ".".join(parts[i:])
        if key in module_paths:
            return module_paths[key]
    return None


def _resolve_router_arg(node: ast.AST, local_imports: dict[str, Path]) -> Path | None:
    """Given the first arg of `app.include_router(...)`, return the file in which
    the router is declared. Handles both `router` (Name) and `users.router`
    (Attribute) styles."""
    if isinstance(node, ast.Name):
        # Either a local variable or a directly-imported name.
        return local_imports.get(node.id)
    if isinstance(node, ast.Attribute) and isinstance(node.value, ast.Name):
        return local_imports.get(node.value.id)
    return None


# ---------- AST helpers ----------


def _parse_file(path: Path) -> ast.Module | None:
    try:
        return ast.parse(path.read_text(encoding="utf-8", errors="ignore"))
    except (OSError, SyntaxError):
        return None


def _is_basemodel(cls: ast.ClassDef) -> bool:
    for base in cls.bases:
        if isinstance(base, ast.Name) and base.id == "BaseModel":
            return True
        if isinstance(base, ast.Attribute) and base.attr == "BaseModel":
            return True
    return False


def _basemodel_fields(cls: ast.ClassDef) -> list[dict[str, Any]]:
    fields: list[dict[str, Any]] = []
    for item in cls.body:
        if isinstance(item, ast.AnnAssign) and isinstance(item.target, ast.Name):
            name = item.target.id
            ann = item.annotation
            optional = False
            # Handle Optional[X] and X | None.
            if isinstance(ann, ast.Subscript) and _ann_name(ann.value) == "Optional":
                optional = True
                ann = ann.slice
            elif isinstance(ann, ast.BinOp) and isinstance(ann.op, ast.BitOr):
                if _ann_name(ann.right) in {"None"}:
                    optional = True
                    ann = ann.left
                elif _ann_name(ann.left) in {"None"}:
                    optional = True
                    ann = ann.right

            descriptor = _py_ann_to_descriptor(name, ann)
            descriptor["optional"] = optional

            if item.value is not None:
                default = _literal_value(item.value)
                if default is not None:
                    descriptor["default"] = default
            fields.append(descriptor)
    return fields


def _py_ann_to_descriptor(name: str, ann: ast.AST) -> dict[str, Any]:
    n = _ann_name(ann)
    if n in {"str"}:
        return {"name": name, "type": "string"}
    if n in {"int", "float", "Decimal"}:
        return {"name": name, "type": "number"}
    if n == "bool":
        return {"name": name, "type": "boolean"}
    if n == "EmailStr":
        return {"name": name, "type": "string", "format": "email"}
    if n == "UUID":
        return {"name": name, "type": "string", "format": "uuid"}
    if n in {"datetime", "date"}:
        return {"name": name, "type": "string", "format": "date-time"}
    if n == "HttpUrl":
        return {"name": name, "type": "string", "format": "url"}
    if isinstance(ann, ast.Subscript):
        container = _ann_name(ann.value)
        if container in {"List", "list"}:
            return {
                "name": name,
                "type": "array",
                "item_type": _py_ann_to_descriptor(name, ann.slice),
            }
        if container in {"Dict", "dict"}:
            return {"name": name, "type": "object", "fields": []}
    # Unknown — treat as string so the output is still usable.
    return {"name": name, "type": "string"}


def _ann_name(node: ast.AST) -> str:
    if isinstance(node, ast.Name):
        return node.id
    if isinstance(node, ast.Attribute):
        return node.attr
    if isinstance(node, ast.Constant):
        if node.value is None:
            return "None"
        return str(node.value)
    return ""


def _literal_value(node: ast.AST) -> Any:
    if isinstance(node, ast.Constant):
        return node.value
    # Field(default=X) — dig into the call.
    if isinstance(node, ast.Call) and _call_name(node) == "Field":
        for kw in node.keywords:
            if kw.arg in {"default", "default_factory"} and isinstance(
                kw.value, ast.Constant
            ):
                return kw.value.value
    return None


def _call_name(node: ast.Call, attr: str | None = None) -> str:
    func = node.func
    if attr:
        if isinstance(func, ast.Attribute) and func.attr == attr:
            return attr
        return ""
    if isinstance(func, ast.Name):
        return func.id
    if isinstance(func, ast.Attribute):
        return func.attr
    return ""


def _kwarg_string(node: ast.Call, name: str) -> str | None:
    for kw in node.keywords:
        if (
            kw.arg == name
            and isinstance(kw.value, ast.Constant)
            and isinstance(kw.value.value, str)
        ):
            return kw.value.value
    return None


def _decorator_info(deco: ast.AST) -> tuple[str, str, str] | None:
    """Return (router_var, method, path) if deco is @router.METHOD('/path')."""
    if not isinstance(deco, ast.Call):
        return None
    func = deco.func
    if not isinstance(func, ast.Attribute):
        return None
    if func.attr.lower() not in HTTP_DECORATORS:
        return None
    if not isinstance(func.value, ast.Name):
        return None
    if not deco.args:
        return None
    first = deco.args[0]
    if not (isinstance(first, ast.Constant) and isinstance(first.value, str)):
        return None
    return func.value.id, func.attr.lower(), first.value


def _detect_auth(func: ast.FunctionDef | ast.AsyncFunctionDef) -> str | None:
    for arg in list(func.args.args) + list(func.args.kwonlyargs):
        default = _default_for_arg(func, arg)
        if isinstance(default, ast.Call) and _call_name(default) == "Depends":
            if default.args:
                name = _ann_name(default.args[0])
                if not name:
                    continue
                lowered = name.lower()
                if "api_key" in lowered or "apikey" in lowered:
                    return "apikey"
                if (
                    "token" in lowered
                    or "jwt" in lowered
                    or "current_user" in lowered
                    or "oauth" in lowered
                    or "bearer" in lowered
                ):
                    return "bearer"
                # Generic Depends — ambiguous, default to bearer as conservative protection assumption.
                return "bearer"
    return None


def _default_for_arg(
    func: ast.FunctionDef | ast.AsyncFunctionDef, arg: ast.arg
) -> ast.AST | None:
    args = list(func.args.args)
    defaults = list(func.args.defaults)
    if arg in args:
        offset = len(args) - len(defaults)
        idx = args.index(arg)
        if idx >= offset:
            return defaults[idx - offset]
    kwonlyargs = list(func.args.kwonlyargs)
    kw_defaults = list(func.args.kw_defaults)
    if arg in kwonlyargs:
        idx = kwonlyargs.index(arg)
        return kw_defaults[idx] if idx < len(kw_defaults) else None
    return None


def _detect_body(
    func: ast.FunctionDef | ast.AsyncFunctionDef,
    models: dict[str, list[dict[str, Any]]],
) -> Any:
    from dto_inferrer import example_for_body

    for arg in func.args.args:
        ann = arg.annotation
        if ann is None:
            continue
        type_name = _ann_name(ann)
        if type_name in models:
            return example_for_body(models[type_name])
    return None


def _detect_query(
    func: ast.FunctionDef | ast.AsyncFunctionDef, path: str
) -> list[dict[str, str]]:
    path_names = {p["key"] for p in extract_path_params(path)}
    out: list[dict[str, str]] = []
    args = list(func.args.args)
    defaults = list(func.args.defaults)
    offset = len(args) - len(defaults)
    for i, arg in enumerate(args):
        if arg.arg in path_names:
            continue
        default = defaults[i - offset] if i >= offset else None
        if isinstance(default, ast.Call) and _call_name(default) == "Depends":
            continue
        ann_name = _ann_name(arg.annotation) if arg.annotation else ""
        # Skip body-like args (BaseModel) and typical request/self.
        if arg.arg in {"self", "request", "response"}:
            continue
        if (
            ann_name
            and ann_name[:1].isupper()
            and ann_name not in {"UUID", "EmailStr", "HttpUrl"}
        ):
            continue
        out.append({"key": arg.arg, "description": ""})
    return out
