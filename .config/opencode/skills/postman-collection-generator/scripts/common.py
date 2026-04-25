"""Shared types and helpers used across parsers."""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


@dataclass
class Endpoint:
    """One HTTP endpoint discovered in the codebase."""

    method: str  # "GET" | "POST" | ...
    path: str  # full path including any prefixes, e.g. "/api/users/:id"
    folder: str  # group name, e.g. "Users"
    name: str | None = None  # display name; defaults to f"{method} {path}"
    description: str = ""
    # Body example as a Python-native structure (dict/list/primitive).
    # None means no body. {} means "body is an object but we couldn't infer fields".
    body: Any = None
    # List of { "key": str, "description": str | None } — not baked into values,
    # left disabled in Postman so the user opts in.
    query_params: list[dict[str, str]] = field(default_factory=list)
    # List of { "key": str, "description": str | None }
    path_params: list[dict[str, str]] = field(default_factory=list)
    # "bearer" | "apikey" | "none" | None (None = inherit collection default)
    auth: str | None = None
    # Warnings captured during parsing; propagated to CLI output.
    warnings: list[str] = field(default_factory=list)
    # Source reference, e.g. "src/users/users.controller.ts:42"
    source: str = ""


HTTP_METHODS = {"GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS", "ALL"}


def normalize_path(*parts: str) -> str:
    """Join path segments into a single canonical path like '/api/users/:id'."""
    cleaned: list[str] = []
    for p in parts:
        if not p:
            continue
        p = p.strip().strip("'\"")
        if not p:
            continue
        p = p.strip("/")
        if p:
            cleaned.append(p)
    joined = "/" + "/".join(cleaned) if cleaned else "/"
    # Convert {id} style (FastAPI, Spring) to :id style for Postman consistency.
    joined = re.sub(r"\{([^}/]+)\}", r":\1", joined)
    # Collapse duplicate slashes defensively.
    joined = re.sub(r"/+", "/", joined)
    return joined


def pascal_to_folder(name: str) -> str:
    """Turn 'UsersController' or 'users_router' into 'Users'."""
    stripped = re.sub(
        r"(Controller|Router|Resource|Handler|Routes?)$", "", name, flags=re.IGNORECASE
    )
    stripped = stripped.replace("_", " ").replace("-", " ")
    # Split camelCase / PascalCase
    spaced = re.sub(r"(?<!^)(?=[A-Z])", " ", stripped)
    words = [w for w in re.split(r"\s+", spaced) if w]
    if not words:
        return "Default"
    return " ".join(w[0].upper() + w[1:] for w in words)


def iter_files(
    root: Path,
    extensions: tuple[str, ...],
    ignore_dirs: tuple[str, ...] = (
        "node_modules",
        ".git",
        "dist",
        "build",
        "__pycache__",
        ".venv",
        "venv",
        ".next",
        ".turbo",
        "coverage",
    ),
) -> list[Path]:
    """Walk `root` and return all files with matching extensions, skipping noise directories."""
    results: list[Path] = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if any(part in ignore_dirs for part in path.parts):
            continue
        if path.suffix in extensions:
            results.append(path)
    return results


def extract_path_params(path: str) -> list[dict[str, str]]:
    """Find :name or {name} style path variables."""
    names = re.findall(r":([a-zA-Z_][a-zA-Z0-9_]*)", path)
    names += re.findall(r"\{([a-zA-Z_][a-zA-Z0-9_]*)\}", path)
    seen: set[str] = set()
    out: list[dict[str, str]] = []
    for n in names:
        if n in seen:
            continue
        seen.add(n)
        out.append({"key": n, "description": ""})
    return out
