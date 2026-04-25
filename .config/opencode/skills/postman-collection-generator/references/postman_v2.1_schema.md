# Postman Collection v2.1 — Fields We Use

Full spec: https://schema.postman.com/collection/json/v2.1.0/draft-07/collection.json

This is a trimmed reference of the fields the generator actually emits. The schema is large; most of it we don't need.

## Top-level

```json
{
  "info": {
    "name": "string",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
    "description": "string (optional)"
  },
  "auth": { ... see Auth ... },
  "item": [ ... Folders or Requests ... ],
  "variable": [ { "key": "baseUrl", "value": "http://localhost:3000" } ]
}
```

- `info.name`: human-readable collection name. We use the project name.
- `info.schema`: must be exactly the v2.1 URL above for Postman to recognize the format.
- `auth`: collection-level auth, overridable per request.
- `item`: an array of folders or requests (can mix, but we always use folders at the top).
- `variable`: collection-scoped variables. We prefer putting `baseUrl` in the environment file, but declaring it at the collection level too makes the collection importable and usable even without the env file.

## Folder

```json
{
  "name": "Users",
  "description": "string (optional)",
  "item": [ ... nested requests or folders ... ]
}
```

## Request

```json
{
  "name": "POST /users",
  "request": {
    "method": "POST",
    "header": [
      { "key": "Content-Type", "value": "application/json" }
    ],
    "auth": { ... see Auth ... optional, overrides collection auth ... },
    "body": {
      "mode": "raw",
      "raw": "{ \"email\": \"user@example.com\" }",
      "options": {
        "raw": { "language": "json" }
      }
    },
    "url": {
      "raw": "{{baseUrl}}/users/:id?limit=",
      "host": ["{{baseUrl}}"],
      "path": ["users", ":id"],
      "query": [
        { "key": "limit", "value": "", "disabled": true }
      ],
      "variable": [
        { "key": "id", "value": "" }
      ]
    }
  },
  "response": []
}
```

### Method

One of: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`, `OPTIONS`.

### URL — the single tricky field

Postman parses the URL in multiple ways:

- `raw` is the display string. Must include `{{baseUrl}}` and the full path, plus query string if any.
- `host` is an array split on `.`. For `{{baseUrl}}` we use `["{{baseUrl}}"]`.
- `path` is an array split on `/`. Each path variable is written as `:name`.
- `query` is an array of key/value objects. We mark them `disabled: true` so the user opts in.
- `variable` maps each `:name` in the path to an initial value.

Getting this wrong (e.g., forgetting to split the path) results in broken requests that Postman silently shows as `{{baseUrl}}` with no path — a common support issue.

### Body modes

- `raw` + `options.raw.language = "json"` for JSON bodies (our default).
- `formdata` for multipart (we detect this when the handler uses `@UploadedFile`, `UploadFile`, `multer`, etc.).
- `urlencoded` for `application/x-www-form-urlencoded` (rarely emitted).
- `none` for GET/DELETE or methods without a body.

### Headers

We always add `Content-Type: application/json` for requests with a JSON body. We do NOT bake auth tokens into the header — those go through the `auth` block so Postman's variables work correctly.

## Auth

```json
{ "type": "bearer", "bearer": [{ "key": "token", "value": "{{token}}", "type": "string" }] }
```

```json
{ "type": "apikey", "apikey": [
  { "key": "key", "value": "x-api-key", "type": "string" },
  { "key": "value", "value": "{{apiKey}}", "type": "string" },
  { "key": "in", "value": "header", "type": "string" }
]}
```

```json
{ "type": "noauth" }
```

Collection-level auth defaults to `bearer` with `{{token}}`. Public endpoints override with `noauth`. API-key endpoints override with `apikey`.

## What we intentionally skip

- `events` (pre-request / test scripts) — off by default to keep output clean. Enabled with `--include-scripts`.
- `response` examples — leaving as `[]`. Populating realistic responses would require running the actual server.
- `protocolProfileBehavior` — defaults are fine.
- `cookie` auth — rarely used in API-only backends. Users can add manually.
