---
name: commit-message
description: >
  Generates professional commit messages following Commitizen convention by reading
  staged (or all) git changes and the current branch name. Use this skill whenever
  the user says "commit", "commit message", "generate commit", "commit this",
  "what should I commit", "stage and commit", "create a commit", or any context
  where the user wants to produce a well-formatted commit message from their
  current changes. Also triggers when the user asks to review changes before
  committing, or says things like "what did I change" in the context of preparing
  a commit.
---

# Commit Message Generator

Generate clear, professional commit messages from git changes using Commitizen convention.
All commit output is in English regardless of conversation language.

---

## Workflow

### Step 1 — Gather context

Run these commands to understand the current state:

1. **Branch name**: `git branch --show-current`
2. **Staged changes**: `git diff --staged --stat` and `git diff --staged`
3. **If nothing is staged**, default to staging everything:
   - Run `git add -A`
   - Then read the staged diff as above
   - Inform the user: "Nothing was staged — I've staged all changes."

If there are truly no changes at all (clean working tree), tell the user there is nothing to commit and stop.

### Step 2 — Analyze the diff

Read the full staged diff carefully. Identify:

- **What changed** — new files, modified files, deleted files
- **Why it changed** — infer intent from the nature of the changes (new feature, bug fix, refactor, etc.)
- **Logical groups** — cluster related changes into topics (e.g., "Database", "API", "UI", "Config")
- **Scope** — determine the primary module or area affected (used for the `scope` in the commit title)

### Step 3 — Determine the commit type

Choose the most accurate Commitizen type based on the changes:

| Type       | When to use                                    |
|------------|------------------------------------------------|
| `feat`     | New feature or capability                      |
| `fix`      | Bug fix                                        |
| `refactor` | Code restructure, no behavior change           |
| `perf`     | Performance improvement                        |
| `test`     | Adding or updating tests                       |
| `docs`     | Documentation only                             |
| `chore`    | Build, config, tooling, dependencies           |
| `style`    | Formatting, whitespace, no logic change        |
| `ci`       | CI/CD pipeline changes                         |
| `revert`   | Reverting a previous commit                    |

If changes span multiple types, use the dominant one. If truly mixed with no dominant type, consider whether the changes should be split into separate commits — suggest this to the user.

### Step 4 — Compose the commit message

Follow these rules strictly:

**Title line**: `type(scope): subject`
- Maximum 50 characters total
- Lowercase, imperative mood ("add", not "added" or "adds")
- No period at the end
- Scope is the primary affected area (e.g., `auth`, `api`, `ui`, `db`, `config`)

**Blank line** after the title.

**Body**: organized by topic
- Each line wraps at 72 characters maximum
- Group changes by logical topic with a short prefix
- Use `- Topic: description` format
- Focus on *what* and *why*, not line numbers or file paths
- Keep it concise — one line per meaningful change, not per file

### Step 5 — Display the result

Output the branch name, then the commit message in a fenced code block with language `git commit`.

**Example:**

Branch: `feature/user-auth`

```git commit
feat(auth): add JWT refresh token support

- Token: add refresh token generation on login
- Database: store hashed refresh token with expiry
- API: add /auth/refresh endpoint for rotation
- Security: invalidate old token on use
```

---

## Rules

- The title MUST be 50 characters or fewer. If the first draft exceeds 50, shorten it — abbreviate the scope or rephrase the subject. Count the characters.
- Body lines MUST wrap at 72 characters. If a line is longer, break it.
- Never include line-level diffs ("changed line 42 from X to Y") — that is noise.
- Never include file paths in the body unless the file itself is the point of the change (e.g., "add .dockerignore").
- If the diff is very large, summarize by topic rather than listing every single change.
- Always use imperative mood in the title ("add", "fix", "remove" — not "added", "fixes", "removing").
- The commit message is always in English.

---

## Multiple commits

If the staged changes contain clearly unrelated work (e.g., a bug fix and a new feature mixed together), suggest splitting into separate commits. Present each proposed commit message separately, and explain how to stage them incrementally:

```
I recommend splitting this into 2 commits:
```

Then show each commit message block, followed by the git commands to stage each group selectively.

---

## Edge cases

- **Merge commits**: If the diff looks like a merge, generate a merge commit message: `merge: branch-name into target-branch`
- **Single file, trivial change**: Still follow the format, but the body can be a single line or omitted if the title is self-explanatory.
- **Only deleted files**: Use the appropriate type (usually `chore` or `refactor`) and note what was removed and why.
- **Only dependency updates**: Use `chore(deps): update X to vY.Z`
