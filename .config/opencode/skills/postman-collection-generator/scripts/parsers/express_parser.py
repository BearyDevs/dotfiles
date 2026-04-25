"""Express / Fastify route parser.

Scans JS/TS files for `app.METHOD(path, ...)` and `router.METHOD(path, ...)`
patterns. Resolves `app.use('/prefix', router)` mounts so final paths are
correct, including the common cross-file case where the imported router is
aliased to a different variable name in the mounting file.

Body inference for Express is best-effort: if the handler or a middleware in
the same file references a Zod schema on the matching path, we use it.
Otherwise body is null.
"""

from __future__ import annotations

import re
from collections import defaultdict
from pathlib import Path
from typing import Any

from common import (
    Endpoint,
    extract_path_params,
    iter_files,
    normalize_path,
    pascal_to_folder,
)


# Match app.get('/x', ...), router.post("/x", ...), app.route('/x').get(...)
_ROUTE_RE = re.compile(
    r"\b([A-Za-z_][A-Za-z0-9_]*)\.(get|post|put|patch|delete|head|options|all)\s*\(\s*(['\"`])([^'\"`]+)\3",
    re.IGNORECASE,
)

# Match app.use('/prefix', routerVariable)
_USE_RE = re.compile(
    r"\b([A-Za-z_][A-Za-z0-9_]*)\.use\s*\(\s*(['\"`])([^'\"`]+)\2\s*,\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)"
)

# const X = require('./path') or const X = require("./path")
_REQUIRE_RE = re.compile(
    r"(?:const|let|var)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*require\s*\(\s*['\"]([^'\"]+)['\"]\s*\)"
)

# import X from './path' (including default imports and named-as-default)
_IMPORT_DEFAULT_RE = re.compile(
    r"import\s+([A-Za-z_][A-Za-z0-9_]*)\s+from\s+['\"]([^'\"]+)['\"]"
)


# Match app.get('/x', ...), router.post("/x", ...), app.route('/x').get(...)
_ROUTE_RE = re.compile(
    r"\b([A-Za-z_][A-Za-z0-9_]*)\.(get|post|put|patch|delete|head|options|all)\s*\(\s*(['\"`])([^'\"`]+)\3",
    re.IGNORECASE,
)

# Match app.use('/prefix', routerVariable)
_USE_RE = re.compile(
    r"\b([A-Za-z_][A-Za-z0-9_]*)\.use\s*\(\s*(['\"`])([^'\"`]+)\2\s*,\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)"
)

# Zod schema definition: const fooSchema = z.object({ ... })
_ZOD_RE = re.compile(
    r"(?:const|let|var)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*z\.object\s*\(\s*\{([^}]*)\}",
    re.DOTALL,
)

# Auth middleware hints in the same call expression.
_AUTH_HINTS_BEARER = re.compile(
    r"\b(auth|authenticate|requireAuth|jwt[A-Za-z]*|passport\.authenticate\(\s*['\"]jwt)",
    re.IGNORECASE,
)
_AUTH_HINTS_APIKEY = re.compile(
    r"\b(apiKey|api_key|apikey|requireApiKey)", re.IGNORECASE
)
_AUTH_HINTS_NONE = re.compile(r"\b(public|skipAuth|noAuth)", re.IGNORECASE)


def parse(root: Path, verbose: bool = False) -> tuple[list[Endpoint], list[str]]:
    files = iter_files(root, (".ts", ".js", ".mjs", ".cjs"))
    endpoints: list[Endpoint] = []
    warnings: list[str] = []

    # Pass 1: read every file once, into memory.
    file_text: dict[Path, str] = {}
    for f in files:
        try:
            file_text[f] = f.read_text(encoding="utf-8", errors="ignore")
        except OSError as e:
            warnings.append(f"Could not read {f}: {e}")

    # Pass 2: in each file, catalogue imports/requires so we can map a local
    # variable name back to the file it was imported from.
    imports_by_file: dict[Path, dict[str, Path]] = {}
    for f, text in file_text.items():
        local_map: dict[str, Path] = {}
        for m in _REQUIRE_RE.finditer(text):
            var, spec = m.group(1), m.group(2)
            target = _resolve_js_import(f, spec)
            if target is not None and target in file_text:
                local_map[var] = target
        for m in _IMPORT_DEFAULT_RE.finditer(text):
            var, spec = m.group(1), m.group(2)
            target = _resolve_js_import(f, spec)
            if target is not None and target in file_text:
                local_map[var] = target
        imports_by_file[f] = local_map

    # Pass 3: find every app.use('/prefix', routerVar) mount. If the routerVar
    # was imported from another file, tag THAT file with the prefix. Otherwise,
    # it's a prefix for a router declared in this same file — still a valid
    # signal.
    mount_prefix_by_file: dict[Path, str] = {}
    mount_prefix_by_local_var: dict[tuple[Path, str], str] = {}
    for f, text in file_text.items():
        for m in _USE_RE.finditer(text):
            prefix = m.group(3)
            router_var = m.group(4)
            imported_from = imports_by_file.get(f, {}).get(router_var)
            if imported_from is not None:
                # Combine prefixes if we see multiple mounts (rare).
                existing = mount_prefix_by_file.get(imported_from, "")
                mount_prefix_by_file[imported_from] = existing + prefix
            else:
                mount_prefix_by_local_var[(f, router_var)] = prefix

    # Pass 4: actually extract routes.
    per_file_endpoints: dict[Path, list[Endpoint]] = defaultdict(list)
    for f, text in file_text.items():
        folder = pascal_to_folder(
            f.stem.replace(".routes", "")
            .replace(".route", "")
            .replace(".controller", "")
        )
        file_prefix = mount_prefix_by_file.get(f, "")

        # Collect Zod schemas in the file for potential body lookup.
        zod_schemas = {m.group(1): m.group(2) for m in _ZOD_RE.finditer(text)}

        for m in _ROUTE_RE.finditer(text):
            app_var = m.group(1)
            method = m.group(2).upper()
            if method == "ALL":
                warnings.append(
                    f"{f}: skipping {app_var}.all() at offset {m.start()} — ambiguous method."
                )
                continue

            route = m.group(4)
            local_prefix = mount_prefix_by_local_var.get((f, app_var), "")
            full_path = normalize_path(file_prefix, local_prefix, route)

            # Look at the rest of this call expression for auth + schema hints.
            call_end = _find_call_end(text, m.end())
            call_block = text[m.start() : call_end]

            auth = _infer_auth(call_block)
            body = _infer_body_from_call(call_block, zod_schemas)

            endpoint = Endpoint(
                method=method,
                path=full_path,
                folder=folder,
                name=f"{method} {full_path}",
                body=body,
                path_params=extract_path_params(full_path),
                auth=auth,
                source=str(f),
            )
            per_file_endpoints[f].append(endpoint)

        if verbose and per_file_endpoints.get(f):
            print(f"[express] {f}: {len(per_file_endpoints[f])} endpoints")

    for eps in per_file_endpoints.values():
        endpoints.extend(eps)

    return endpoints, warnings


def _resolve_js_import(from_file: Path, spec: str) -> Path | None:
    """Resolve a relative require()/import path to an actual file on disk.

    We don't handle bare package names (e.g. `require('express')`) because those
    never point to project source files anyway. We try common JS/TS extensions
    and also index.* inside a directory — same contract Node's module resolver
    uses.
    """
    if not spec.startswith("."):
        return None
    base = from_file.parent / spec
    candidates = [
        Path(str(base) + ".ts"),
        Path(str(base) + ".js"),
        Path(str(base) + ".mjs"),
        Path(str(base) + ".cjs"),
        base / "index.ts",
        base / "index.js",
        base / "index.mjs",
        base / "index.cjs",
    ]
    for c in candidates:
        c = c.resolve()
        if c.exists():
            return c
    return None


def _find_call_end(text: str, start: int) -> int:
    depth = 1
    i = start
    while i < len(text):
        c = text[i]
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return min(len(text), start + 1000)


def _infer_auth(call_block: str) -> str | None:
    if _AUTH_HINTS_NONE.search(call_block):
        return "none"
    if _AUTH_HINTS_APIKEY.search(call_block):
        return "apikey"
    if _AUTH_HINTS_BEARER.search(call_block):
        return "bearer"
    return None


def _infer_body_from_call(call_block: str, zod_schemas: dict[str, str]) -> Any:
    # Look for 'validate(fooSchema)' or 'validateBody(fooSchema)' in the call block.
    for m in re.finditer(
        r"validate(?:Body)?\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)", call_block
    ):
        schema_name = m.group(1)
        schema_body = zod_schemas.get(schema_name)
        if schema_body:
            return _zod_body_to_example(schema_body)
    return None


_ZOD_FIELD_RE = re.compile(r"([A-Za-z_][A-Za-z0-9_]*)\s*:\s*z\.([A-Za-z_]+)\s*\(")


def _zod_body_to_example(body: str) -> dict[str, Any]:
    example: dict[str, Any] = {}
    for m in _ZOD_FIELD_RE.finditer(body):
        name = m.group(1)
        ztype = m.group(2)
        example[name] = _zod_type_example(name, ztype)
    return example


def _zod_type_example(name: str, ztype: str) -> Any:
    from dto_inferrer import example_for_field

    if ztype == "string":
        return example_for_field({"name": name, "type": "string"})
    if ztype in {"number", "int"}:
        return 0
    if ztype == "boolean":
        return False
    if ztype == "array":
        return []
    if ztype == "object":
        return {}
    if ztype == "date":
        return "2025-01-01T00:00:00.000Z"
    if ztype == "email":
        return "user@example.com"
    if ztype == "uuid":
        return "00000000-0000-0000-0000-000000000000"
    if ztype == "url":
        return "https://example.com"
    return "string"
