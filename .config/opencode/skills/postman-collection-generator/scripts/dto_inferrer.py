"""Map type/DTO descriptions to example JSON values.

The inferrer does NOT fully parse TypeScript or Python; it consumes structured
"field descriptors" already extracted by the framework parsers. Each field
descriptor is a dict of the form:

    {
        "name": "email",
        "type": "string",           # canonicalized: string | number | boolean | array | object | enum | unknown
        "item_type": <descriptor>,  # only if type == "array"
        "fields": [<descriptor>],   # only if type == "object"
        "enum_values": [...],       # only if type == "enum"
        "format": "email" | "uuid" | "date-time" | "url" | "phone" | None,
        "default": <value or None>,
        "optional": bool,
        "deprecated": bool,
    }

Keeping this layer isolated lets each framework parser worry only about
extraction, not about what example value to emit.
"""

from __future__ import annotations

import re
from typing import Any


EMAIL_NAME = re.compile(r"email", re.IGNORECASE)
UUID_NAME = re.compile(r"(^id$|_id$|uuid)", re.IGNORECASE)
DATE_NAME = re.compile(r"(date|_at$|At$|timestamp)")
URL_NAME = re.compile(r"url|website|link", re.IGNORECASE)
PHONE_NAME = re.compile(r"phone|mobile", re.IGNORECASE)
PASSWORD_NAME = re.compile(r"password|pwd|secret", re.IGNORECASE)


def example_for_field(field: dict[str, Any]) -> Any:
    """Return an example value for a single field descriptor."""
    if field.get("deprecated"):
        return _marker_deprecated()
    if field.get("default") is not None:
        return field["default"]

    t = field.get("type", "unknown")
    fmt = field.get("format")
    name = field.get("name", "")

    if t == "string":
        return _string_example(name, fmt)
    if t == "number":
        return 0
    if t == "boolean":
        return False
    if t == "array":
        item = field.get("item_type") or {"type": "unknown", "name": name}
        return [example_for_field(item)]
    if t == "object":
        return {
            f["name"]: example_for_field(f)
            for f in field.get("fields", [])
            if not f.get("deprecated")
        }
    if t == "enum":
        values = field.get("enum_values") or []
        return values[0] if values else "string"
    return None  # unknown


def example_for_body(fields: list[dict[str, Any]]) -> dict[str, Any]:
    """Produce the top-level body example object from a list of field descriptors."""
    return {f["name"]: example_for_field(f) for f in fields if not f.get("deprecated")}


# ---------- internal helpers ----------


def _string_example(name: str, fmt: str | None) -> str:
    if fmt == "email":
        return "user@example.com"
    if fmt == "uuid":
        return "00000000-0000-0000-0000-000000000000"
    if fmt == "date-time" or fmt == "date":
        return "2025-01-01T00:00:00.000Z"
    if fmt == "url":
        return "https://example.com"
    if fmt == "phone":
        return "+10000000000"

    # Fall back to name-based heuristics when type is plain string.
    if EMAIL_NAME.search(name):
        return "user@example.com"
    if UUID_NAME.search(name):
        return "00000000-0000-0000-0000-000000000000"
    if DATE_NAME.search(name):
        return "2025-01-01T00:00:00.000Z"
    if URL_NAME.search(name):
        return "https://example.com"
    if PHONE_NAME.search(name):
        return "+10000000000"
    if PASSWORD_NAME.search(name):
        return "Password123!"
    return "string"


def _marker_deprecated() -> None:
    # Deprecated fields are stripped at the caller level; returning None is
    # never reached because example_for_body filters them out first.
    return None
