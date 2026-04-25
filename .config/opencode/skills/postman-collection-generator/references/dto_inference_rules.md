# DTO / Schema → Example Body Inference

The goal of body inference is to produce an example JSON that the user can send immediately. If the server returns a validation error, the error should be about *values*, not about *shape*. Shape must be right.

## Type → value table

| Source type / decorator | Example value |
|---|---|
| `string`, `str` | `"string"` |
| `string` + `@IsEmail` / `EmailStr` / field name matches `/email/i` | `"user@example.com"` |
| `string` + `@IsUUID` / `UUID` / field name matches `/(^id$|_id$|uuid)/i` | `"00000000-0000-0000-0000-000000000000"` |
| `string` + `@IsDateString` / `datetime` / `date` / field name matches `/(date|_at$|At$)/` | `"2025-01-01T00:00:00.000Z"` |
| `string` + `@IsUrl` / `HttpUrl` / field name matches `/url/i` | `"https://example.com"` |
| `string` + `@IsPhoneNumber` / field name matches `/phone/i` | `"+10000000000"` |
| `string` + `@IsEnum(E)` / `Literal[...]` / `Enum` | first value of the enum |
| `number`, `int`, `float`, `decimal` | `0` |
| `boolean`, `bool` | `false` |
| `X[]`, `list[X]`, `Array<X>` | `[<one recursive example of X>]` |
| nested object / class / `BaseModel` | recurse into its fields |
| `Record<string, X>`, `dict[str, X]` | `{ "key": <example of X> }` |
| `any`, `unknown`, `object`, `dict` | `{}` |
| `null` / `None` (union with null) | use the other type's example |
| Optional (`?`, `@IsOptional`, `Optional[X]`, `X | None`) | include the field anyway with default example value; user deletes if not wanted |
| Unknown custom type that can't be resolved | `null` with a comment `// unresolved type: <name>` |

## Why include optional fields

We include optional fields (rather than omitting them) because most API consumers want to *see* the full shape of the request. It's easier to delete a field in Postman than to remember it exists. The single exception is deprecated fields marked with `@deprecated` in JSDoc/docstring — those are omitted.

## Field name heuristics

We use field name patterns as a tiebreaker when the type alone is ambiguous (e.g., `string` could be anything). These heuristics are conservative — they fire only when the type is *exactly* `string` and no more specific decorator/type is present.

| Name pattern (case-insensitive) | Example |
|---|---|
| `email` | `"user@example.com"` |
| `phone`, `phoneNumber`, `mobile` | `"+10000000000"` |
| `url`, `website`, `link` | `"https://example.com"` |
| `password`, `pwd` | `"Password123!"` |
| `id`, `*_id`, `*Id` | `"00000000-0000-0000-0000-000000000000"` |
| `name`, `firstName`, `lastName` | `"string"` (plain) |
| `date`, `*_at`, `*At` | `"2025-01-01T00:00:00.000Z"` |
| `token`, `secret`, `apiKey` | `"string"` (plain — don't bake a fake token) |

## Resolving DTOs across files

The parsers handle imports for the common case:

- **NestJS / Express (TypeScript):** follows `import { CreateUserDto } from './dto/create-user.dto';` by resolving the relative path. Supports `tsconfig.json` paths (`@/dto/...`) if a tsconfig is present at the project root.
- **FastAPI:** follows `from app.schemas.user import CreateUserSchema` via standard Python import resolution, rooted at the project directory.

Not supported:

- Barrel file re-exports across more than two hops (`index.ts` that imports from another `index.ts`). The parser gives up after 2 levels.
- Generated DTOs from tools like Prisma / TypeORM model inference. Those should be converted to explicit classes or the user should accept `{}` bodies.
- DTOs defined inline at the handler signature (e.g., `@Body() dto: { foo: string }`). Those *are* handled — they're easier because no import resolution is needed.

## Enums

Enums are resolved by reading the enum definition:

- TypeScript: `export enum UserRole { Admin = 'admin', Member = 'member' }` → first value `"admin"`.
- Python: `class UserRole(str, Enum): ADMIN = 'admin'` → first value `"admin"`.
- Zod: `z.enum(['a', 'b'])` → `"a"`.

If the enum is numeric, the first numeric value is used.

## Defaults explicitly declared

When a DTO field has an explicit default (e.g., `age: number = 18` in TypeScript, or `age: int = 18` in Python), we use the default. This is a stronger signal than our generic type-based guess.
