"""Best-effort fallback parser for frameworks we don't explicitly support.

This parser does NOT try to be clever. It sweeps source files for common
route-registration patterns and emits endpoints with minimal metadata
(no body inference, auth usually unknown). The point is to get *something*
importable rather than produce nothing.

When this parser runs, the caller should clearly tell the user that accuracy
is reduced.
"""

from __future__ import annotations

import re
from pathlib import Path

from common import (
    Endpoint,
    extract_path_params,
    iter_files,
    normalize_path,
    pascal_to_folder,
)


PATTERNS: list[tuple[re.Pattern[str], str]] = [
    # Flask: @app.route('/x', methods=['POST']) or @blueprint.route
    (
        re.compile(
            r"@(?:app|[A-Za-z_][A-Za-z0-9_]*)\.route\s*\(\s*['\"]([^'\"]+)['\"][^)]*methods\s*=\s*\[\s*['\"]([A-Z]+)['\"]",
            re.IGNORECASE,
        ),
        "py",
    ),
    # Flask simpler: @app.get('/x') — already covered by fastapi parser but here as fallback for Flask.
    (
        re.compile(
            r"@(?:app|[A-Za-z_][A-Za-z0-9_]*)\.(get|post|put|patch|delete)\s*\(\s*['\"]([^'\"]+)['\"]",
            re.IGNORECASE,
        ),
        "py",
    ),
    # Gin / Echo Go: r.GET("/x", handler)
    (
        re.compile(
            r"\b([A-Za-z_][A-Za-z0-9_]*)\.(GET|POST|PUT|PATCH|DELETE)\s*\(\s*\"([^\"]+)\"",
            re.IGNORECASE,
        ),
        "go",
    ),
    # Spring: @GetMapping("/x")
    (
        re.compile(
            r"@(Get|Post|Put|Patch|Delete)Mapping\s*\(\s*\"([^\"]+)\"", re.IGNORECASE
        ),
        "java",
    ),
    # Laravel: Route::get('/x', ...)
    (
        re.compile(
            r"Route::(get|post|put|patch|delete)\s*\(\s*['\"]([^'\"]+)['\"]",
            re.IGNORECASE,
        ),
        "php",
    ),
]


def parse(root: Path, verbose: bool = False) -> tuple[list[Endpoint], list[str]]:
    files = iter_files(
        root, (".py", ".go", ".java", ".kt", ".php", ".rb", ".js", ".ts")
    )
    endpoints: list[Endpoint] = []
    warnings: list[str] = []

    for f in files:
        try:
            text = f.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue

        folder = pascal_to_folder(f.stem)
        file_count = 0

        for pattern, _lang in PATTERNS:
            for m in pattern.finditer(text):
                groups = m.groups()
                # Normalise (method, path) depending on pattern shape.
                if (
                    len(groups) == 2
                    and groups[0].upper() in {"GET", "POST", "PUT", "PATCH", "DELETE"}
                    and groups[1].startswith("/")
                ):
                    method, path = groups[0].upper(), groups[1]
                elif len(groups) == 2:
                    path, method = groups[0], groups[1].upper()
                elif len(groups) == 3:
                    # (app_var, METHOD, path) — Gin shape.
                    _, method, path = groups
                    method = method.upper()
                else:
                    continue

                full_path = normalize_path(path)
                endpoints.append(
                    Endpoint(
                        method=method,
                        path=full_path,
                        folder=folder,
                        name=f"{method} {full_path}",
                        path_params=extract_path_params(full_path),
                        source=str(f),
                    )
                )
                file_count += 1

        if verbose and file_count:
            print(f"[generic] {f}: {file_count} endpoints")

    return endpoints, warnings
