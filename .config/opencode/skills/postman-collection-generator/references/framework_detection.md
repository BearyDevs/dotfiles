# Framework Detection

The script picks a parser based on signals in the project root. This doc explains the exact signals, in priority order.

## Priority order

1. **NestJS** — highest priority because NestJS projects *also* contain Express-ish code underneath (NestJS uses Express or Fastify as a platform adapter). We must detect NestJS first to avoid falling into the Express parser.
2. **FastAPI** — distinct ecosystem from Node, no overlap with above.
3. **Express / Fastify** — catches anything Node that isn't NestJS.
4. **Generic fallback** — if none of the above matched.

## Signals

### NestJS

Any of:

- `package.json` has a dependency on `@nestjs/core`, `@nestjs/common`, or `@nestjs/platform-express`.
- A file named `main.ts` exists and contains `NestFactory.create(`.
- Any `*.controller.ts` file exists under `src/`.

### FastAPI

Any of:

- `requirements.txt` contains a line matching `^fastapi(\b|==|>=)`.
- `pyproject.toml` has `fastapi` under `[tool.poetry.dependencies]` or `[project.dependencies]`.
- Any `.py` file contains `from fastapi import` or `import fastapi`.

### Express / Fastify

Any of:

- `package.json` has `express` or `fastify` as a dependency (and NestJS was NOT detected).
- Any `.js`/`.ts` file contains `require('express')`, `from 'express'`, `require('fastify')`, or `from 'fastify'`.

Fastify and Express share 95% of their decorator shape (`app.get(path, handler)`, `router.post(path, handler)`), so the same parser handles both. The differences (Fastify's schema option, reply.send vs res.send) don't affect route extraction.

### Generic fallback

If the above all miss, the generic parser does a cross-language regex sweep looking for:

- HTTP method decorators in Python (`@app.get`, `@router.post`, `@blueprint.route('/x', methods=['POST'])` for Flask).
- Go Gin / Echo patterns (`r.GET("/path", handler)`, `e.POST(...)`).
- Laravel `Route::get('/x', ...)`.
- Spring `@GetMapping("/x")`.

Accuracy drops to ~60-70% here. If the user lands on this path, tell them explicitly so they know the output is best-effort.

## Monorepo handling

If `--root` contains multiple services, by default we scan everything and attempt to parse each file with whichever parser matches. The script writes one combined collection. If the user wants a collection per service, they should run the script once per sub-path.

## Manual override

If detection is wrong, the user can force a framework with `--framework nestjs|express|fastapi|generic`. When `--framework` is anything other than `auto`, the detection logic is skipped entirely.
