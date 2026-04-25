---
name: mr-details-document
description: >
  Generates a comprehensive MR/PR detail document and stores it in the project's vault.
  Use this skill whenever the user says "MR details", "MR document", "PR details", "PR document",
  "branch report", "create MR", "write MR", or when a feature branch is complete and needs
  a summary for reviewers. Also triggers when the user asks to document what changed on a branch,
  or wants a detailed report of all commits and modifications for a merge/pull request.
  This skill produces a rich, visual document — not a simple commit list.
---

# MR Details Document

Generate a comprehensive, visually rich MR/PR document that serves as a permanent record
of what changed on a feature branch. The document is written in English, stored in the
project's vault (not committed to git), and designed to be immediately understandable
by any team member — even those unfamiliar with the project.

The key insight: an MR document is not a diff summary. It is a **technical document** that
explains the architecture, decisions, and impact of the changes. A reviewer reading it should
understand the *why* and *what* without needing to read every line of code.

---

## When This Skill Triggers

- User says "MR details", "PR details", "MR document", "PR document"
- User asks to summarize or document a branch's changes
- A feature branch is complete and ready for review
- User wants a report of all modifications for a merge request

---

## Step 1 — Gather Context

Before writing anything, collect the raw data from git:

```bash
# Current branch and base
git branch --show-current
git log --oneline -5

# All commits on this branch (from divergence point)
git log origin/main..HEAD --oneline
# or if no remote:
git log main..HEAD --oneline

# Full diff summary
git diff main..HEAD --stat

# Detailed diff (read, don't display)
git diff main..HEAD
```

Also read any relevant files to understand the architecture:
- New files created
- Modified files (understand what changed and why)
- Test files (what is covered)
- Configuration changes
- Docker/infrastructure changes

---

## Step 2 — Determine Vault Location

The MR document goes in the project's vault under an `mr/` directory:

```
vaults/{ProjectName}/mr/{branch-name}.md
```

Convert the branch name to a filename: replace `/` with `-`.

Example: `feature/celery-worker-scheduling` → `feature-celery-worker-scheduling.md`

Create the `mr/` directory if it does not exist.

**Important:** Do NOT add MR documents to git. They live in the vault only.

---

## Step 3 — Write the Document

The document MUST be in **English** — it serves as documentation for the team.

### Required Structure

Every MR document follows this structure. Adapt the depth of each section
to match the size of the changes — a 2-file bugfix needs less detail than
a 14-file feature.

```markdown
---
type: mr
branch: {branch-name}
base: {base-branch}
commit: {short-hash}
tags: [mr, ...relevant-tags]
---

# MR: {branch-name} → {base-branch}

## Overview
## Scope
## Architecture
## Changes
## API Documentation (if endpoints changed)
## Testing
## Configuration Reference (if applicable)
## Notes for Reviewer
```

---

### Section Guidelines

#### Overview (1-3 sentences)

A concise summary of what the MR does and why. A busy reviewer should be able
to read just this and know whether the MR is relevant to them.

#### Scope (mindmap)

Use a **Mermaid mindmap** to show the full scope of changes at a glance.
This is the single most useful visual in the document — it lets reviewers
see the breadth of changes before diving into details.

```markdown
```mermaid
mindmap
  root((Feature Name))
    Area 1
      Detail A
      Detail B
    Area 2
      Detail C
    Area 3
      Detail D
      Detail E
```​
```

#### Architecture (flowcharts and sequence diagrams)

Use **Mermaid diagrams** to show how the system works after the changes.
Choose the right diagram type for the situation:

| Diagram Type | When to Use |
|---|---|
| `flowchart` | System topology, service relationships, data flow |
| `sequenceDiagram` | Request lifecycle, multi-step interactions |
| `flowchart LR` | Pipeline or transformation chain |

Include **before/after** diagrams if the architecture changed significantly.

Do NOT use diagrams for trivial changes — a table is better for small scope.

#### Changes (tables + details)

Group changes by logical area (not by file). Each area gets:

1. **A brief explanation** of what changed and why
2. **A table of affected files** with type (New/Modified) and description
3. **Code examples** for new API endpoints or configuration
4. **Sub-diagrams** if the area has complex flow (e.g., chord pattern)

File table format:

```markdown
| File | Type | Description |
|------|------|-------------|
| `path/to/file.py` | **New** | What this file does |
| `path/to/other.py` | Modified | What changed |
```

**Important rules:**
- Do NOT include line counts, line numbers, or detailed diffs
- Do NOT include dates in the changes section
- Focus on *what* and *why*, not *how many lines*

#### API Documentation (if endpoints changed)

The single most important section for any MR that changes API surface. A reviewer
must be able to understand every endpoint — its contract, payload shape, and
error behavior — without leaving the document. This section uses **collapsible
`<details>` blocks** so the document scrolls naturally while every endpoint is
one click away from full request/response demos.

##### When to include

- MR adds, modifies, or removes any HTTP endpoint, gRPC method, or public SDK surface
- Skip for internal refactors that do not change the contract

##### Scope of what to document

Document **every endpoint the MR touches** — both newly added and modified.
Do NOT re-document untouched endpoints from other MRs (this is an MR doc, not
a service-wide reference).

##### Required sub-sections (in this order)

1. **Table of Contents** — include when the section has more than 8 endpoints
   or spans multiple modules/resources. Use anchor links to each resource.
2. **Base URL & Authentication** — only when new or changed
3. **Response Format** — envelope templates: `DataResponse` (single item),
   `ListResponse` (list + pagination), error response, and any special
   diagnostic shapes (e.g. 403 permission diagnostic). Each gets a JSON example.
4. **Common Query Parameters** — table of `page`, `limit`, `sort`, `search`
   when those repeat across endpoints
5. **Shared Response Fields** — table of fields common to many resources
   (e.g. `id`, `company_id`, `source_updated_at`, `last_synced_at`) — avoids
   repeating field descriptions in every endpoint
6. **Endpoint Summary** — optional flat overview table:
   `Method | Path | Auth | Description`
7. **Per-resource sections** — one `###` heading per resource

##### Per-resource section template

```markdown
### N. {Resource Name}

**Base path:** `/api/v1/{resource}`
**Table:** `{table_name}`
**Description:** {what this resource represents}
**Auth:** {scope name / authentication-only / Bearer Token}

<details>
<summary><code>GET /api/v1/{resource}/</code> — list all</summary>

**Auth:** Bearer Token
**Query Parameters:** `page`, `limit`, `sort`, `search`

**Response 200:**
​```json
{
  "code": "SUCCESS",
  "message": "ดำเนินการสำเร็จ",
  "data": [ { "id": "550e8400-...", "code": "...", "name": "..." } ],
  "pagination": { "total": 10, "page": 1, "page_size": 100, "total_pages": 1, "has_next": false, "has_previous": false, "next_page": null, "previous_page": null }
}
​```

</details>

<details>
<summary><code>GET /api/v1/{resource}/{id}</code> — get one</summary>

**Path Parameters:** `id` (UUID)

**Response 200:**
​```json
{ "code": "SUCCESS", "message": "...", "data": { /* same shape as list item */ } }
​```

**Response 404:**
​```json
{ "code": "FAILED", "message": "ไม่พบข้อมูลที่ต้องการ", "data": null }
​```

</details>

<!-- POST / PUT / PATCH / DELETE follow, in this order -->
```

##### CRUD ordering

Inside each resource section, order endpoints as:
`GET list → GET by ID → POST → PUT → PATCH → DELETE`

This matches reader expectations and makes diff-against-other-resources trivial.

##### State Machine for stateful resources

When a resource has a workflow (e.g. `DRAFT → SUBMITTED → APPROVED → LOCKED`),
place the diagram **once at the top of the resource section**, not inside each
endpoint. Use the format that fits:

| Diagram type | When to pick |
|---|---|
| ASCII state diagram | Simple linear flows, copy-pastable to terminals |
| Mermaid `stateDiagram-v2` | Branches, guards, multiple terminal states |

Both formats are acceptable — pick by complexity.

After the diagram, list business guards as a short bullet block:

```markdown
> **Edit guard:** modifications allowed only in `DRAFT` or `UNLOCKED`
> **Submit guard:** `submit` requires `DRAFT` or `UNLOCKED` → transitions to `SUBMITTED`
```

Do NOT repeat these guards in every endpoint's `<details>` block.

##### Collapsible block rules

- **Every endpoint** lives inside `<details><summary>...</summary>...</details>`
- Summary line MUST be: `<code>METHOD /full/path</code> — short description`
- Inside the block: **Auth**, **Path Parameters**, **Query Parameters**,
  **Request Body**, **Response 200/201/204**, error responses — only the ones
  that apply
- For PUT/PATCH where response shape matches GET-by-ID, write
  `**Response 200:** เหมือน GET by ID` (or `same as GET by ID`) instead of
  re-pasting the JSON

##### Demo data rules

- **Realistic UUIDs** — `550e8400-e29b-41d4-a716-446655440001`, NOT `"uuid"` or `"string"`
- **Domain-realistic values** — actual names, codes, dates the API would return
- **Match the production language** — if the API returns Thai messages
  (`"ดำเนินการสำเร็จ"`), the JSON demo MUST be Thai. The reviewer needs to see
  what they will actually receive. Surrounding prose, headings, and tables
  remain English.
- **Happy path only** for success responses — no edge case combinations
- **One error example per endpoint** — pick the most informative (404, 422, 403)
- **PATCH bodies must be partial** — show 1–2 fields, not the full record
- **Validation rules** — list with bullets when not obvious from the body
  (e.g. unique constraints, required combinations)

#### Testing (table)

Show test coverage with a clear table:

| Suite | File | Tests | Coverage |
|-------|------|-------|----------|
| Unit | `test_foo.py` | 15 | What is tested |
| E2E | `test_e2e.py` | 8 | What is tested |
| **Total** | | **184** | **All passing** |

#### Configuration Reference (table, if applicable)

If new environment variables or configuration was added:

| Variable | Default | Description |
|----------|---------|-------------|
| `NEW_VAR` | `value` | What it controls |

#### Notes for Reviewer

Bullet list of things the reviewer should pay attention to:
- Backward compatibility status
- Security considerations (secrets, .env, auth)
- Prerequisites or dependencies
- Known limitations or follow-up work
- Anything unusual or non-obvious

---

## Visual Elements — Decision Guide

Use this table to decide which visual element to use:

| Situation | Use | Avoid |
|-----------|-----|-------|
| Show overall scope of MR | Mermaid mindmap | Long bullet lists |
| Show system topology | Mermaid flowchart | ASCII art |
| Show request lifecycle | Mermaid sequence diagram | Prose descriptions |
| Show before/after architecture | Two flowcharts side by side | Inline diff |
| List files changed | Table | Bullet list |
| Quick endpoint overview | Summary table (Method/Path/Auth/Description) | Prose |
| Full endpoint reference with demos | Collapsible `<details>` per endpoint with request/response JSON | Flat list without drill-down |
| Show resource workflow | ASCII or Mermaid state diagram once per resource | Repeating guards in every endpoint |
| Show config variables | Table | Code blocks with comments |
| Show test results | Table with pass/fail | Prose summary |
| Show design decisions | Table with Decision/Rationale | Long paragraphs |

**General rules:**
- Every MR document MUST have at least one mindmap (Scope) and one table (Changes)
- Use diagrams only when they add clarity — not for decoration
- Prefer tables over bullet lists for structured data
- Keep code examples short — show the happy path, not every edge case
- If the MR adds or modifies any endpoint, the **API Documentation** section is
  mandatory and every endpoint must have its own collapsible `<details>` block
- Shared envelopes (`DataResponse`, `ListResponse`, error) must be defined once
  in `## Response Format`, not repeated per endpoint

---

## Frontmatter

Every MR document starts with YAML frontmatter:

```yaml
---
type: mr
branch: feature/my-feature
base: main
commit: abc1234
tags: [mr, feature-area, ...]
---
```

- `commit`: short hash of the latest (or merge) commit
- `tags`: include `mr` plus relevant domain tags
- Do NOT include dates — git has that information

---

## Tone and Style

- **English for prose, headings, and tables** — the document is for the whole team
- **JSON demo values match the production language** — if the API returns Thai
  in real responses, the JSON examples are Thai. Reviewers must see actual
  payload shape, not a translated version.
- **Professional but readable** — avoid jargon where possible
- **Concise** — respect the reviewer's time
- **Visual first** — if something can be a diagram or table, make it one
- **No filler** — every sentence should add information
- **No line-level diffs** — that is what `git diff` is for
- **No dates in content** — only in frontmatter if needed
