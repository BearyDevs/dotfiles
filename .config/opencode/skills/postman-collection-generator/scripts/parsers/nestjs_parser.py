"""NestJS controller parser.

Strategy: regex-based. TypeScript AST parsing would be more robust but would
require a JS/TS runtime or tree-sitter, which we're explicitly avoiding to keep
the skill zero-dependency.

We accept that the parser will miss:
- Controllers that dynamically compose routes in module providers.
- DTOs imported via non-trivial path aliases beyond a single tsconfig lookup.

These edge cases are reported as warnings.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any

from common import (
    Endpoint,
    extract_path_params,
    iter_files,
    normalize_path,
    pascal_to_folder,
)


_CONTROLLER_RE = re.compile(r"@Controller\s*\(\s*([^)]*)\s*\)", re.MULTILINE)
_CONTROLLER_CLASS_RE = re.compile(
    r"export\s+class\s+([A-Za-z0-9_]+)\s*(?:implements|extends|\{)"
)
_METHOD_DECORATOR_RE = re.compile(
    r"@(Get|Post|Put|Patch|Delete|Head|Options|All)\s*\(\s*([^)]*)\s*\)",
    re.IGNORECASE,
)
_USE_GUARDS_RE = re.compile(r"@UseGuards\s*\(\s*([^)]+)\s*\)")
# Locator for handler starts: we find @Method(...) then the handler name,
# then parse the parameter list with paren-balanced extraction because
# parameter decorators like @Body() / @Query('x') contain their own parens.
_HANDLER_START_RE = re.compile(
    r"@(Get|Post|Put|Patch|Delete|Head|Options|All)\s*\(([^)]*)\)\s*"
    r"(?:@[A-Za-z]+\s*\([^)]*\)\s*)*"
    r"(?:public\s+|private\s+|protected\s+)?"
    r"(?:async\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*\(",
    re.IGNORECASE,
)
_BODY_PARAM_RE = re.compile(
    r"@Body\s*\(\s*[^)]*\)\s*([A-Za-z0-9_]+)\s*:\s*([A-Za-z0-9_<>\[\]\s,.|]+)"
)
_QUERY_PARAM_RE = re.compile(r"@Query\s*\(\s*['\"]([A-Za-z0-9_]+)['\"]")
_QUERY_OBJECT_RE = re.compile(r"@Query\s*\(\s*\)\s*[A-Za-z0-9_]+\s*:\s*([A-Za-z0-9_]+)")
_GLOBAL_PREFIX_RE = re.compile(r"setGlobalPrefix\s*\(\s*['\"]([^'\"]+)['\"]\s*\)")

_CLASS_VALIDATOR_TYPES = {
    "IsString": ("string", None),
    "IsNumber": ("number", None),
    "IsInt": ("number", None),
    "IsBoolean": ("boolean", None),
    "IsEmail": ("string", "email"),
    "IsUUID": ("string", "uuid"),
    "IsDateString": ("string", "date-time"),
    "IsUrl": ("string", "url"),
    "IsPhoneNumber": ("string", "phone"),
}


def parse(root: Path, verbose: bool = False) -> tuple[list[Endpoint], list[str]]:
    files = iter_files(root, (".ts",))
    controller_files = [f for f in files if ".controller." in f.name]
    global_prefix = _find_global_prefix(files)

    endpoints: list[Endpoint] = []
    warnings: list[str] = []

    dto_cache: dict[str, list[dict[str, Any]]] = {}

    for cf in controller_files:
        try:
            text = cf.read_text(encoding="utf-8", errors="ignore")
        except OSError as e:
            warnings.append(f"Could not read {cf}: {e}")
            continue

        endpoints.extend(
            _parse_controller_file(
                cf, text, global_prefix, dto_cache, root, warnings, verbose
            )
        )

    return endpoints, warnings


def _find_global_prefix(files: list[Path]) -> str:
    for f in files:
        if f.name == "main.ts":
            try:
                text = f.read_text(encoding="utf-8", errors="ignore")
            except OSError:
                continue
            m = _GLOBAL_PREFIX_RE.search(text)
            if m:
                return m.group(1)
    return ""


def _parse_controller_file(
    path: Path,
    text: str,
    global_prefix: str,
    dto_cache: dict[str, list[dict[str, Any]]],
    project_root: Path,
    warnings: list[str],
    verbose: bool,
) -> list[Endpoint]:
    class_match = _CONTROLLER_CLASS_RE.search(text)
    ctrl_match = _CONTROLLER_RE.search(text)
    if not class_match or not ctrl_match:
        return []

    class_name = class_match.group(1)
    folder = pascal_to_folder(class_name)
    base_path = _clean_string_arg(ctrl_match.group(1))

    # Class-level guard (applies to every handler unless overridden).
    class_guards = _extract_guards_near(text, class_match.start())

    endpoints: list[Endpoint] = []
    for m in _HANDLER_START_RE.finditer(text):
        method = m.group(1).upper()
        route_arg = _clean_string_arg(m.group(2))
        handler_name = m.group(3)

        # m.end() points right after the opening '(' of the handler parameter list.
        params_block = _read_balanced(text, m.end(), open_char="(", close_char=")")

        # Method-level guards are harder — look at the lines immediately before
        # the handler decorator stack.
        handler_guards = _extract_guards_near(text, m.start())
        auth = _guards_to_auth(class_guards + handler_guards)

        # Body DTO
        body_example = None
        body_dto = _BODY_PARAM_RE.search(params_block)
        if body_dto:
            dto_type = body_dto.group(2).strip().split("|")[0].strip()
            dto_type = dto_type.replace("[]", "")
            if dto_type and dto_type not in {"any", "unknown", "object"}:
                fields = _resolve_dto(dto_type, path, project_root, dto_cache, warnings)
                if fields is None:
                    body_example = {}
                    warnings.append(
                        f"{path}: could not resolve DTO '{dto_type}' for {method} {handler_name}; emitting empty body."
                    )
                else:
                    from dto_inferrer import example_for_body

                    body_example = example_for_body(fields)

        # Query params (only @Query('name') style; @Query() DTO objects we flag separately)
        query_params = [
            {"key": q, "description": ""} for q in _QUERY_PARAM_RE.findall(params_block)
        ]
        query_obj = _QUERY_OBJECT_RE.search(params_block)
        if query_obj:
            warnings.append(
                f"{path}: {method} {handler_name} uses @Query() DTO '{query_obj.group(1)}'; query params left empty."
            )

        full_path = normalize_path(global_prefix, base_path, route_arg)
        path_params = extract_path_params(full_path)

        endpoints.append(
            Endpoint(
                method=method,
                path=full_path,
                folder=folder,
                name=f"{method} {full_path}",
                body=body_example,
                query_params=query_params,
                path_params=path_params,
                auth=auth,
                source=str(path),
            )
        )

    if verbose:
        print(f"[nestjs] {path}: {len(endpoints)} endpoints")
    return endpoints


def _read_balanced(text: str, start: int, open_char: str, close_char: str) -> str:
    """Read forward from `start` until the opening bracket (already consumed
    by the caller) is closed, respecting nesting. Returns the inner content."""
    depth = 1
    i = start
    while i < len(text) and depth > 0:
        c = text[i]
        if c == open_char:
            depth += 1
        elif c == close_char:
            depth -= 1
            if depth == 0:
                return text[start:i]
        i += 1
    return text[start:i]


def _clean_string_arg(raw: str) -> str:
    """'users' or "users" -> users. Strips array literal wrappers too."""
    raw = raw.strip()
    if not raw:
        return ""
    # Handle @Controller(['users', 'u']) — take the first literal.
    if raw.startswith("["):
        inner = raw.strip("[]").split(",")[0]
        return inner.strip().strip("'\"")
    return raw.strip("'\"")


def _extract_guards_near(text: str, pos: int) -> list[str]:
    """Walk backward from `pos` collecting @UseGuards(...) on contiguous preceding lines."""
    # Take the 10 lines before `pos`.
    start = max(0, text.rfind("\n\n", 0, pos))
    window = text[start:pos]
    return _USE_GUARDS_RE.findall(window)


def _guards_to_auth(guard_args: list[str]) -> str | None:
    flat = " ".join(guard_args)
    if re.search(
        r"Jwt|Bearer|Auth(?!orization)\b|AuthGuard\('jwt'\)", flat, re.IGNORECASE
    ):
        return "bearer"
    if re.search(r"ApiKey|X-?Api-?Key", flat, re.IGNORECASE):
        return "apikey"
    if re.search(r"Public|NoAuth|SkipAuth", flat, re.IGNORECASE):
        return "none"
    if not guard_args:
        return None
    # Unknown guard — default to bearer, which is the safest assumption for "something is protecting this".
    return "bearer"


# ---------- DTO resolution ----------

_IMPORT_RE = re.compile(
    r"import\s+(?:type\s+)?\{([^}]+)\}\s+from\s+['\"]([^'\"]+)['\"]",
    re.MULTILINE,
)


def _resolve_dto(
    dto_name: str,
    from_file: Path,
    project_root: Path,
    cache: dict[str, list[dict[str, Any]]],
    warnings: list[str],
    depth: int = 0,
) -> list[dict[str, Any]] | None:
    cache_key = f"{from_file}::{dto_name}"
    if cache_key in cache:
        return cache[cache_key]
    if depth > 3:
        return None

    try:
        text = from_file.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return None

    # First try: DTO is defined in this same file.
    local = _parse_class_fields(text, dto_name)
    if local is not None:
        cache[cache_key] = local
        return local

    # Else: follow imports.
    for imp_match in _IMPORT_RE.finditer(text):
        names = [n.strip() for n in imp_match.group(1).split(",")]
        # Handle "Foo as Bar" — we care about the alias, since that's what appears in code.
        names = [n.split(" as ")[-1].strip() for n in names]
        if dto_name in names:
            target = _resolve_import_path(from_file, imp_match.group(2), project_root)
            if target is None:
                continue
            # In the target file, the DTO may have been re-exported, so try recursively.
            resolved = _resolve_dto(
                dto_name, target, project_root, cache, warnings, depth + 1
            )
            if resolved is not None:
                cache[cache_key] = resolved
                return resolved
    return None


def _resolve_import_path(from_file: Path, spec: str, project_root: Path) -> Path | None:
    """Resolve a relative or '@/' import to an actual .ts/.tsx file on disk.

    We deliberately append extensions rather than using `Path.with_suffix`,
    because filenames like 'create-user.dto' already have a '.dto' suffix
    and `with_suffix('.ts')` would *replace* it, producing 'create-user.ts'.
    """

    def candidates_for(base: Path) -> list[Path]:
        return [
            Path(str(base) + ".ts"),
            Path(str(base) + ".tsx"),
            base / "index.ts",
            base / "index.tsx",
        ]

    if spec.startswith("."):
        base = from_file.parent / spec
        for c in candidates_for(base):
            c = c.resolve()
            if c.exists():
                return c
        return None
    if spec.startswith("@/"):
        base = project_root / "src" / spec[2:]
        for c in candidates_for(base):
            if c.exists():
                return c
    return None


_CLASS_FIELD_RE = re.compile(
    r"^\s*(?:(?:public|private|readonly|static)\s+)*"
    r"([A-Za-z_][A-Za-z0-9_]*)(\??):\s*([A-Za-z0-9_<>\[\]|\s,.]+?)(?:=\s*([^;]+))?;",
    re.MULTILINE,
)


def _parse_class_fields(text: str, class_name: str) -> list[dict[str, Any]] | None:
    # Locate the class declaration.
    pattern = re.compile(
        rf"(?:export\s+)?class\s+{re.escape(class_name)}\s*(?:extends\s+[^\{{]+)?\{{",
        re.MULTILINE,
    )
    m = pattern.search(text)
    if not m:
        return None
    # Walk forward to find the matching closing brace.
    depth = 1
    i = m.end()
    while i < len(text) and depth > 0:
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
        i += 1
    body = text[m.end() : i - 1]

    fields: list[dict[str, Any]] = []
    for fm in _CLASS_FIELD_RE.finditer(body):
        name = fm.group(1)
        optional = fm.group(2) == "?"
        type_raw = fm.group(3).strip()
        default_raw = fm.group(4)

        # Look for class-validator decorators on preceding lines.
        preceding = body[: fm.start()]
        last_block = preceding.rsplit(";", 1)[-1]
        decorators = re.findall(r"@([A-Za-z]+)\s*\(", last_block)

        # Optional via decorator.
        if "IsOptional" in decorators:
            optional = True

        descriptor = _ts_type_to_descriptor(name, type_raw)
        # Enrich with decorator info.
        for d in decorators:
            if d in _CLASS_VALIDATOR_TYPES:
                canon, fmt = _CLASS_VALIDATOR_TYPES[d]
                descriptor["type"] = canon
                if fmt:
                    descriptor["format"] = fmt
            if d == "IsEnum":
                descriptor["type"] = "enum"
                # Values unknown without further parsing; fallback to "string".
                descriptor.setdefault("enum_values", ["string"])

        descriptor["optional"] = optional
        if default_raw is not None:
            descriptor["default"] = _parse_ts_default(default_raw.strip())

        fields.append(descriptor)

    return fields


def _ts_type_to_descriptor(name: str, raw: str) -> dict[str, Any]:
    raw = raw.strip()
    if raw.endswith("[]"):
        inner = raw[:-2].strip()
        return {
            "name": name,
            "type": "array",
            "item_type": _ts_type_to_descriptor(name, inner),
        }
    lowered = raw.lower()
    if lowered in {"string"}:
        return {"name": name, "type": "string"}
    if lowered in {"number", "int", "float"}:
        return {"name": name, "type": "number"}
    if lowered in {"boolean", "bool"}:
        return {"name": name, "type": "boolean"}
    if lowered in {"date"}:
        return {"name": name, "type": "string", "format": "date-time"}
    # Generic / complex type — treat as unknown, let fallback produce "string".
    return {"name": name, "type": "string"}


def _parse_ts_default(raw: str) -> Any:
    raw = raw.strip().rstrip(",")
    if raw in {"true", "false"}:
        return raw == "true"
    if raw == "null":
        return None
    if raw.startswith(("'", '"', "`")):
        return raw.strip("'\"`")
    try:
        if "." in raw:
            return float(raw)
        return int(raw)
    except ValueError:
        return None
