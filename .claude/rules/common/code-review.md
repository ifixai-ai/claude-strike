# Code Review Standards

> Delegation lives in [`agents.md`](./agents.md). This file defines the **severity vocabulary** and **what to look for** — not the workflow.

## Severity levels

| Level | Meaning | Action |
|---|---|---|
| CRITICAL | Security vulnerability or data loss risk | **BLOCK** — must fix before merge |
| HIGH | Bug or significant quality issue | **WARN** — fix before merge |
| MEDIUM | Maintainability concern | Consider fixing |
| LOW | Style or minor suggestion | Optional |

**Approval:** no CRITICAL or HIGH issues. CRITICAL always blocks.

## Use `security-reviewer` (not `code-reviewer`) for

Auth/authz, user input, database queries, file system ops, external API calls, cryptography, payments.

## Common issues to catch

**Security:** hardcoded credentials, SQL injection (string concat in queries), XSS (unescaped output), path traversal, missing CSRF, auth bypass.

**Code quality:** functions >20 lines, files >800 lines, nesting >4 deep, missing error handling, mutation where immutable would do, missing tests, vague function names (`run`, `process`, `handle`, `do`), magic numbers, docstrings on simple functions, comments that restate the code.

**Performance:** N+1 queries, missing pagination, unbounded queries, missing caching on hot paths.
