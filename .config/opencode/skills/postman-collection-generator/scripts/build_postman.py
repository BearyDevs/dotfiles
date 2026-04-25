#!/usr/bin/env python3
"""Generate a Postman Collection v2.1 JSON from a backend codebase.

Usage:
    python3 build_postman.py --root . --out ./postman --name myapi

See the skill's SKILL.md for the full workflow.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

# Make sibling modules importable regardless of how we're invoked.
SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
sys.path.insert(0, str(SCRIPT_DIR / "parsers"))

from common import Endpoint  # noqa: E402
from emit_collection import build_collection, build_environment  # noqa: E402


def main() -> int:
    args = _parse_args()
    root = Path(args.root).resolve()
    if not root.is_dir():
        print(f"error: --root {root} is not a directory", file=sys.stderr)
        return 2

    framework = args.framework
    if framework == "auto":
        framework = _detect_framework(root)
        print(f"Detected framework: {framework}")
    else:
        print(f"Using framework: {framework} (forced)")

    endpoints, warnings = _run_parser(framework, root, args.verbose)

    # De-duplicate (same method + path) while preserving first occurrence.
    endpoints = _dedupe(endpoints, warnings)

    # Summary stats.
    folders = {e.folder for e in endpoints}
    auth_counts = {"bearer": 0, "apikey": 0, "none": 0, "inherit": 0}
    for e in endpoints:
        auth_counts[e.auth or "inherit"] = auth_counts.get(e.auth or "inherit", 0) + 1

    print(f"Scanned files under {root}.")
    print(f"Found {len(endpoints)} endpoints across {len(folders)} folders.")
    print(
        "Auth: "
        f"{auth_counts.get('bearer', 0)} bearer, "
        f"{auth_counts.get('apikey', 0)} apiKey, "
        f"{auth_counts.get('none', 0)} none, "
        f"{auth_counts.get('inherit', 0)} inherit-from-collection."
    )
    for w in warnings:
        print(f"warning: {w}")

    if args.dry_run:
        print("dry-run: no files written.")
        return 0

    out_dir = Path(args.out).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    base_url = args.base_url or _detect_base_url(root)
    collection = build_collection(
        endpoints, args.name, include_scripts=args.include_scripts
    )
    environment = build_environment(args.name, base_url)

    coll_path = out_dir / f"{args.name}.postman_collection.json"
    env_path = out_dir / f"{args.name}.postman_environment.json"
    coll_path.write_text(
        json.dumps(collection, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    env_path.write_text(
        json.dumps(environment, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    print(f"Wrote: {coll_path}")
    print(f"Wrote: {env_path}")
    print(f"Environment baseUrl: {base_url}")
    return 0


def _parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Generate a Postman Collection v2.1 from a backend repo."
    )
    p.add_argument(
        "--root", default=".", help="Project root to scan (default: current directory)"
    )
    p.add_argument(
        "--out", default="./postman", help="Output directory (default: ./postman)"
    )
    p.add_argument(
        "--name", required=True, help="Collection name, used as filename prefix too."
    )
    p.add_argument(
        "--framework",
        choices=["auto", "nestjs", "express", "fastapi", "generic"],
        default="auto",
    )
    p.add_argument(
        "--base-url", default=None, help="Default baseUrl for the environment file."
    )
    p.add_argument(
        "--include-scripts",
        action="store_true",
        help="Add pm.test status-code checks per request.",
    )
    p.add_argument(
        "--dry-run", action="store_true", help="Print stats without writing any files."
    )
    p.add_argument(
        "--verbose", action="store_true", help="Print per-file parse decisions."
    )
    return p.parse_args()


def _detect_framework(root: Path) -> str:
    pkg = root / "package.json"
    if pkg.is_file():
        try:
            data = json.loads(pkg.read_text(encoding="utf-8", errors="ignore"))
        except json.JSONDecodeError:
            data = {}
        deps = {
            **(data.get("dependencies") or {}),
            **(data.get("devDependencies") or {}),
        }
        if any(k.startswith("@nestjs/") for k in deps):
            return "nestjs"

    # FastAPI?
    for candidate in (root / "requirements.txt", root / "pyproject.toml"):
        if candidate.is_file():
            text = candidate.read_text(encoding="utf-8", errors="ignore").lower()
            if "fastapi" in text:
                return "fastapi"

    # Any .py file importing fastapi?
    for p in root.rglob("*.py"):
        if any(
            part in {"node_modules", ".git", "__pycache__", ".venv", "venv"}
            for part in p.parts
        ):
            continue
        try:
            head = p.read_text(encoding="utf-8", errors="ignore")[:4000]
        except OSError:
            continue
        if "from fastapi" in head or "import fastapi" in head:
            return "fastapi"
        break  # one sample is enough to avoid a heavy scan

    # Express / Fastify fallback for Node projects.
    if pkg.is_file():
        try:
            data = json.loads(pkg.read_text(encoding="utf-8", errors="ignore"))
        except json.JSONDecodeError:
            data = {}
        deps = {
            **(data.get("dependencies") or {}),
            **(data.get("devDependencies") or {}),
        }
        if "express" in deps or "fastify" in deps:
            return "express"

    return "generic"


def _run_parser(
    framework: str, root: Path, verbose: bool
) -> tuple[list[Endpoint], list[str]]:
    if framework == "nestjs":
        from parsers import nestjs_parser

        return nestjs_parser.parse(root, verbose=verbose)
    if framework == "express":
        from parsers import express_parser

        return express_parser.parse(root, verbose=verbose)
    if framework == "fastapi":
        from parsers import fastapi_parser

        return fastapi_parser.parse(root, verbose=verbose)
    from parsers import generic_parser

    return generic_parser.parse(root, verbose=verbose)


def _dedupe(endpoints: list[Endpoint], warnings: list[str]) -> list[Endpoint]:
    seen: dict[tuple[str, str], Endpoint] = {}
    for ep in endpoints:
        key = (ep.method, ep.path)
        if key in seen:
            warnings.append(
                f"duplicate route {ep.method} {ep.path} (also at {seen[key].source}); keeping first."
            )
            continue
        seen[key] = ep
    return list(seen.values())


_PORT_RE = re.compile(r"(?:PORT\s*[:=]\s*['\"]?|listen\s*\(\s*)(\d{2,5})")


def _detect_base_url(root: Path) -> str:
    """Peek into common entrypoints for a port number; fallback to 3000."""
    candidates = [
        root / ".env",
        root / ".env.example",
        root / "src" / "main.ts",
        root / "main.py",
        root / "app" / "main.py",
        root / "app.py",
        root / "server.ts",
        root / "server.js",
    ]
    for c in candidates:
        if not c.is_file():
            continue
        try:
            text = c.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        m = _PORT_RE.search(text)
        if m:
            return f"http://localhost:{m.group(1)}"
    return "http://localhost:3000"


if __name__ == "__main__":
    raise SystemExit(main())
