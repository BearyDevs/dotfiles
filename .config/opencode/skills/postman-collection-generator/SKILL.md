---
name: postman-collection-generator
description: Scans a backend codebase for every HTTP API endpoint and generates a Postman Collection v2.1 JSON (plus a matching environment file) ready to import into Postman, Insomnia, or Bruno. Supports NestJS, Express/Fastify, and FastAPI, with an auto-detect fallback for other frameworks. Use this skill whenever the user says "generate postman collection", "export APIs to postman", "create postman import", "postman json for my backend", "scan routes for postman", "postman from controllers", "build a postman file", or mentions needing an importable API collection for QA, frontend handoff, or API documentation — even if they don't explicitly say the word "skill". Prefer this skill over hand-writing JSON when the user has a backend project with multiple routes.
---

# Postman Collection Generator

## Purpose

This skill turns a backend codebase into an importable Postman Collection v2.1 JSON file. It reads the project, discovers every HTTP endpoint, infers request bodies from DTOs/schemas, detects auth requirements, groups requests by controller/module, and writes two files:

- `./postman/<project>.postman_collection.json`
- `./postman/<project>.postman_environment.json`

The generated collection uses `{{baseUrl}}` and `{{token}}` variables so the user can switch environments in Postman without editing every request.

## When to use this skill

Trigger on any of these intents:

- "Give me a postman collection for my API."
- "Export all my routes to postman."
- "I need a JSON I can import into postman."
- "Generate postman file for QA."
- "Document my endpoints for the frontend team."

If the user is asking you to *hand-write* a single request in JSON, this skill is overkill — just write the JSON. But the moment multiple endpoints or a whole project is involved, use the skill.

## How this skill works (why it's built this way)

We deliberately bundle a Python script (`scripts/build_postman.py`) instead of relying on the LLM to emit JSON by hand. Three reasons:

1. **Determinism.** A codebase with 80 routes produces the same collection twice in a row. Hand-writing JSON across dozens of endpoints drifts.
2. **Speed + tokens.** Parsing is local and cheap. The LLM's job is to *orchestrate, disambiguate, and report* — not to type thousands of lines of JSON.
3. **Re-runnability.** The user will regenerate after every new endpoint. A script makes that a one-liner.

Your role as the agent is to (a) detect the framework correctly, (b) run the script with sane flags, (c) inspect the output, and (d) fix any ambiguities the script flagged.

## Workflow

Follow these steps in order. Don't skip ahead.

### Step 1 — Detect the framework

Look at the project root:

| Signal | Framework |
|---|---|
| `package.json` contains `@nestjs/core` | NestJS |
| `package.json` contains `express` or `fastify` and no NestJS | Express / Fastify |
| `requirements.txt` / `pyproject.toml` contains `fastapi` | FastAPI |
| None of the above | Generic fallback |

See `references/framework_detection.md` for the full signal matrix (including monorepos where multiple frameworks coexist).

If you're unsure, pass `--framework auto` and let the script guess. Don't ask the user — the detection is almost always right, and wrong detections are obvious from the output.

### Step 2 — Run the bundled script

From the project root (i.e. the backend repo, not this skill folder):

```bash
python3 "<skill-path>/scripts/build_postman.py" \
  --root . \
  --out ./postman \
  --name "<project-name>" \
  --framework auto
```

Useful flags:

- `--base-url http://localhost:3000` — sets the default `baseUrl` env var. If omitted, the script tries to detect the port from common locations (`main.ts`, `main.py`, `.env`, `config/*`). Falls back to `http://localhost:3000`.
- `--include-scripts` — adds a basic `pm.test('Status is 2xx')` block to every request. Off by default, per user preference for clean output.
- `--dry-run` — prints stats only, writes nothing. Use this first on large repos to sanity-check the endpoint count before committing files.
- `--verbose` — prints per-file parse decisions. Use when debugging missing endpoints.

### Step 3 — Sanity-check the output

The script prints a summary like:

```
Detected framework: nestjs
Scanned 42 files, found 87 endpoints across 12 folders.
Auth: 64 bearer, 3 apiKey, 20 none.
Skipped 2 endpoints (see warnings above).
Wrote: ./postman/myapi.postman_collection.json
Wrote: ./postman/myapi.postman_environment.json
```

Verify:

- Endpoint count roughly matches what the user expects (ask them if it seems off by a lot).
- "Skipped" endpoints — read the warning and decide whether to patch the parser or leave them.
- Folder names match controller/module names. If they all collapse into one folder, framework detection probably failed.

### Step 4 — Handle skipped or ambiguous endpoints

The script emits warnings for things it can't confidently parse (e.g., a dynamically registered route, a handler defined inside a factory function, a DTO imported via a barrel file with a custom alias). For each warning:

- If there are fewer than ~5, patch them by editing the collection JSON manually or by adding an override file (see `references/overrides.md` if it exists in the user's repo).
- If there are many, report back to the user with the list and ask whether a custom parser pattern is warranted.

Don't silently hide warnings. The user needs to know what wasn't captured.

### Step 5 — Report back

Give the user a short summary:

- Files written (absolute paths).
- Endpoint + folder counts.
- Auth breakdown.
- Anything skipped.
- Next step: "Import `<file>.postman_collection.json` into Postman, then import the environment file and select it."

## Framework-specific notes

### NestJS

- Look for files ending in `.controller.ts` / `.controller.js`.
- The base path comes from `@Controller('prefix')`; routes from `@Get`, `@Post`, `@Put`, `@Patch`, `@Delete`, `@All`, `@Options`, `@Head`.
- Body DTOs come from the `@Body() dto: SomeDto` parameter; resolve `SomeDto` to find its class, then read `class-validator` decorators (`@IsString`, `@IsOptional`, `@IsEnum`, `@ValidateNested`) for field types.
- Query + path params come from `@Query()` and `@Param()`.
- Auth: `@UseGuards(JwtAuthGuard)` / `@UseGuards(AuthGuard('jwt'))` → bearer. `@UseGuards(ApiKeyGuard)` or custom names containing "ApiKey" → header `x-api-key`.
- Global prefix: check `main.ts` for `app.setGlobalPrefix('api')` and prepend it to every route.
- Module = folder. If the controller lives in `src/users/users.controller.ts`, the folder in Postman is "Users".

### Express / Fastify

- Scan for `router.METHOD(path, ...)` and `app.METHOD(path, ...)` where METHOD ∈ {get, post, put, patch, delete, options, head, all}.
- Base path comes from wherever the router is mounted: `app.use('/api/users', usersRouter)`.
- Body examples are harder — Express has no native DTO concept. The script looks for:
  - Zod schemas (`z.object({...})`) used in the handler or middleware.
  - Joi schemas (`Joi.object({...})`).
  - class-validator classes if TypeScript.
  - JSDoc `@body` / `@param` tags.
  - Falls back to `{}` with a `// TODO` comment.
- Auth: middleware named `auth`, `authenticate`, `requireAuth`, `jwt*`, `passport.authenticate('jwt')` → bearer. Middleware containing `apiKey` / `api_key` / `x-api-key` → apiKey header.
- Folder = router file name. `routes/users.routes.ts` → "Users" folder.

### FastAPI

- Scan for `@app.METHOD(...)` and `@router.METHOD(...)` decorators.
- Routers with `prefix="/users"` contribute that prefix; mounted with `app.include_router(router, prefix="/api")` adds another layer. The script resolves both.
- Body: the first parameter typed as a `BaseModel` subclass is the body. Resolve the class, read its fields and their Python types (including `Optional[X]`, `list[X]`, nested `BaseModel`).
- Path + query params: inferred from function signature and path string.
- Auth: `Depends(get_current_user)`, `Depends(oauth2_scheme)`, `Depends(verify_token)` → bearer. `Depends(api_key_header)` or `APIKeyHeader` → apiKey.
- Folder = router module. `app/routers/users.py` → "Users".

### Generic fallback

If detection fails, the script runs a regex scan across common patterns and produces a best-effort collection. Expect reduced accuracy on:

- Request body examples (will mostly be `{}`).
- Auth (flagged as `none` unless obvious header checks are found).

Tell the user explicitly when this path is taken.

## DTO / schema → example body inference

Full table in `references/dto_inference_rules.md`. Short version:

| Type | Example value |
|---|---|
| string | `"string"` (or the first enum value if enum) |
| string with `@IsEmail` / `EmailStr` | `"user@example.com"` |
| string with `@IsUUID` / `UUID` | `"00000000-0000-0000-0000-000000000000"` |
| string with `@IsDateString` / `datetime` | `"2025-01-01T00:00:00.000Z"` |
| number / int / float | `0` |
| boolean / bool | `false` |
| array `X[]` / `list[X]` | `[<one example of X>]` |
| nested object | recurse |
| optional | field included, value is the default for its type (Postman users can delete it) |

The goal is a body that the user can *immediately send* without filling anything in and get a sensible 4xx validation error, so they know the request shape is right.

## Output contract

Collection file structure:

```
Collection: <project>
├── Users (folder, from UsersController / users router)
│   ├── GET /users
│   ├── GET /users/:id
│   ├── POST /users
│   ├── PATCH /users/:id
│   └── DELETE /users/:id
├── Auth (folder)
│   ├── POST /auth/login
│   └── POST /auth/refresh
└── ...
```

- Collection-level auth is `bearer` with `{{token}}`. Per-request auth overrides it when the endpoint needs something different (e.g., `apiKey` header) or nothing at all (`noauth` on public routes).
- URL is always `{{baseUrl}}/the/path`.
- Path params are expressed as Postman path variables: `/users/:id` becomes `{{baseUrl}}/users/:id` with a `variable` entry.
- Query params are listed disabled-by-default so the user can enable the ones they want.

Environment file:

```json
{
  "name": "<project> local",
  "values": [
    { "key": "baseUrl", "value": "http://localhost:3000", "enabled": true },
    { "key": "token", "value": "", "enabled": true }
  ]
}
```

## Troubleshooting

**"Only a handful of endpoints found, I have way more."**
Framework detection probably misfired, or the project uses a non-standard structure. Re-run with `--framework <explicit>` and `--verbose` to see what the scanner is skipping.

**"Request bodies are all `{}`."**
The DTO/schema resolver couldn't follow imports. Common causes: barrel files (`index.ts` re-exports), path aliases (`@/dto/...`), or DTOs defined in a separate package in a monorepo. Point the script at the right directory with `--dto-root <path>` (if your version supports it), or patch the JSON manually.

**"Auth is wrong on every endpoint."**
The guard/middleware name isn't in the default recognized list. Add custom patterns via `--auth-bearer-pattern <regex>` and `--auth-apikey-pattern <regex>`.

**"Duplicate requests."**
Usually caused by a route being registered twice (e.g., both in a module and a global router). Real bug in the codebase 90% of the time — worth telling the user.

## Example

A minimal NestJS controller:

```ts
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  @Get()
  findAll(@Query('limit') limit: number) { /* ... */ }

  @Post()
  create(@Body() dto: CreateUserDto) { /* ... */ }
}

export class CreateUserDto {
  @IsEmail() email: string;
  @IsString() name: string;
  @IsOptional() @IsInt() age?: number;
}
```

Produces (abbreviated):

```json
{
  "info": { "name": "myapi", "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json" },
  "auth": { "type": "bearer", "bearer": [{ "key": "token", "value": "{{token}}", "type": "string" }] },
  "item": [
    {
      "name": "Users",
      "item": [
        {
          "name": "GET /users",
          "request": {
            "method": "GET",
            "url": { "raw": "{{baseUrl}}/users?limit=", "host": ["{{baseUrl}}"], "path": ["users"], "query": [{ "key": "limit", "value": "", "disabled": true }] }
          }
        },
        {
          "name": "POST /users",
          "request": {
            "method": "POST",
            "header": [{ "key": "Content-Type", "value": "application/json" }],
            "body": { "mode": "raw", "raw": "{\n  \"email\": \"user@example.com\",\n  \"name\": \"string\",\n  \"age\": 0\n}" },
            "url": { "raw": "{{baseUrl}}/users", "host": ["{{baseUrl}}"], "path": ["users"] }
          }
        }
      ]
    }
  ]
}
```

That's the shape you're aiming for.

## File references

- `scripts/build_postman.py` — entry point. Read this if the user asks what the script does.
- `scripts/parsers/` — per-framework parsers.
- `scripts/dto_inferrer.py` — type-to-example logic.
- `scripts/emit_collection.py` — JSON writer.
- `references/framework_detection.md` — full detection signals.
- `references/dto_inference_rules.md` — complete type table.
- `references/postman_v2.1_schema.md` — the fields we actually use, with examples.
- `assets/collection_template.json` — the empty skeleton we clone before filling.
