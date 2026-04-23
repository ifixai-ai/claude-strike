# CLAUDE.md — Behavioral contract

Read fully before acting. When other guidance (subagents, skills, plugin commands) conflicts with this file, this file wins.

**What this assumes is present:**
- The 13 ECC agents in `.claude/agents/`: `build-error-resolver`, `code-architect`, `code-reviewer`, `code-simplifier`, `comment-analyzer`, `database-reviewer`, `docs-lookup`, `opensource-packager`, `opensource-sanitizer`, `planner`, `security-reviewer`, `silent-failure-hunter`, `tdd-guide`.
- ECC rules bundles in `.claude/rules/common/` and `.claude/rules/python/`, readable as reference.
- `spec-kit` is **opt-in per project**, not global. See `docs/spec-kit.md` in the harness repo.

---

## Definitions

**Non-trivial change** — touches more than one file, changes a public function signature, alters a contract or schema, modifies infra/config, or introduces/removes a dependency. Everything else is trivial. Trivial changes may skip plan mode and the verification pass.

---

## Workflow

**Plan before acting.** Enter plan mode for any non-trivial task. If something goes sideways, stop and re-plan — don't keep pushing.

**Spec before non-trivial work.** For any task matching the *Non-trivial change* definition, spec-kit must drive the workflow.

1. Check whether `.specify/` exists at the repo root.
2. If it does **not** exist, stop and tell the user:
   > This task is non-trivial. Initialise spec-kit first:
   > `uvx --from git+https://github.com/github/spec-kit.git specify init --here --ai claude`
   > Then re-ask.
   Do not edit code until they confirm.
3. If it **does** exist, run `/specify` → `/plan` → `/tasks` before any edits. Treat the generated tasks as the work list.

Trivial changes skip this and proceed directly.

**Think before coding.** Don't assume. Don't hide confusion. State assumptions explicitly. When a request is ambiguous, present multiple interpretations — don't pick silently. Push back when a simpler approach exists. Stop and ask when unclear.

**Delegate liberally.** Use subagents to keep the main context clean. One task per subagent, chosen deliberately — not reflexively. Invoke the ECC agent whose specialty matches the task:

| Agent | When |
|---|---|
| `code-reviewer` | Before committing any non-trivial change. |
| `code-architect` | Designing a new module or planning a refactor. |
| `code-simplifier` | A file feels bloated and needs to shrink without behavior change. |
| `build-error-resolver` | The build breaks or type errors appear. |
| `database-reviewer` | Any SQL, schema, or migration change. |
| `docs-lookup` | Current library or API documentation is needed. |
| `planner` | Complex feature or refactor needs an implementation plan. |
| `security-reviewer` | Auth, payments, user data, crypto, or external API boundaries. |
| `tdd-guide` | New feature or bug fix that needs a failing test first. |
| `comment-analyzer` | Before merging — flag rotten or redundant comments. |
| `silent-failure-hunter` | Before merging — catch swallowed errors. |
| `opensource-sanitizer` | Before publishing a repo to GitHub. |
| `opensource-packager` | Generating CLAUDE.md / setup.sh / README for release. |

**`code-reviewer` vs `security-reviewer`** — `code-reviewer` is the always-on quality gate after any non-trivial change; it performs a CRITICAL-level security pass as part of that. `security-reviewer` is for proactive deep dives on auth, payments, crypto, user-data handling, and external API boundaries. Default to `code-reviewer`; add `security-reviewer` only when the diff touches one of those high-risk surfaces.

**Goal-driven execution.** Transform imperative tasks into verifiable goals.

| Instead of... | Transform to... |
|---|---|
| "Add validation" | "Write tests for invalid inputs, then make them pass" |
| "Fix the bug" | "Write a test that reproduces it, then make it pass" |
| "Refactor X" | "Ensure tests pass before and after" |

**Demand elegance.** For non-trivial changes, pause and ask "is there a more elegant way?" If a fix feels hacky, implement the elegant solution. Skip for obvious fixes — don't over-engineer.

**Fix bugs autonomously.** Given a bug report, fix it. Point at logs, errors, failing tests, then resolve them. No hand-holding.

---

## Core principles

- **Simplicity first.** Minimum code that solves the problem. No features beyond what was asked. No abstractions for single-use code. No "flexibility" that wasn't requested. No error handling for impossible scenarios. If 200 lines could be 50, rewrite.
- **Surgical changes.** Touch only what you must. Don't "improve" adjacent code, comments, or formatting. Match existing style even if you'd do it differently. Unrelated dead code gets mentioned, not deleted — but remove imports, variables, and functions that *your* changes orphaned. Every changed line must trace to the user's request.
- **No laziness.** Find root causes. No temporary fixes. Senior developer standards.
- **Search first.** Grep the existing implementation before writing new code. Check dependencies before adding one. Custom code is the last resort, not the first.

---

## Done means done

A change is done when all of the following are true:

1. The user's goal is achieved — verifiable, not "probably works".
2. Tests exist and pass.
3. Every line in the diff traces to the request.
4. No new dead code, unused imports, or speculative abstractions.
5. You can summarise the change in 2–3 sentences.
6. For non-trivial changes: `code-reviewer` has run and reports no CRITICAL or HIGH findings.

Ask: "Would a senior engineer say this is overcomplicated?" If yes, simplify before declaring done.

---

## Self-improvement

After any correction from the user: update `tasks/lessons.md`. Write rules that prevent the same mistake. Review lessons at session start.

Every entry uses this template:

```
### YYYY-MM-DD — <short title>
- **Trigger**: what the user said or what I did that exposed the mistake.
- **Rule**: the single prescriptive sentence I will follow next time.
- **Example**: concrete before/after or file path.
```

Entries without all three fields are notes, not lessons, and belong elsewhere.

---

## Code rules

- **No comments unless absolutely necessary.** Code must be self-explanatory through naming. The only acceptable comment explains *why* a non-obvious decision was made — never *what* the code does. Noise comments, commented-out code, and comments that restate the signature are deleted on sight.
- **No docstrings** on functions, methods, or classes. Module docstrings also forbidden. Names carry the meaning.
- **No nested functions.** Define helpers at module scope with a clear name. No closures-as-helpers, no inner `def`, no inner `async def`. Lambdas are permitted only in expression position and only when the body is a single trivial expression.
- **Self-explanatory names.** A reader must understand a function from its name alone. No vague verbs (`run`, `process`, `handle`, `do`). No abbreviations outside universal ones (`id`, `url`, `http`). Booleans prefix with `is_`, `has_`, or `can_`.
- **Type hints on every signature** — parameters and return.
- **All imports at the top of the file.** No lazy imports inside functions or conditional blocks. No `try/except` around imports. A circular import means the architecture is wrong — fix the architecture.
- **Functions do one thing.** If you describe it with "and", split it. Aim for under 20 lines.
- **0–2 parameters.** If more, group them into a schema or `TypedDict`. No flag arguments — split into two named functions.
- **One level of abstraction per function.** Don't mix high-level orchestration with low-level detail in the same body.
- **Raise typed exceptions.** Don't return `None` from a function typed `T` to signal failure. `Optional[T]` is fine when `None` is a legitimate domain outcome. Don't swallow exceptions silently — log, re-raise, or handle with intent.
- **Structured data is typed.** No hardcoded dicts to represent records. Define a `TypedDict` or Pydantic model.
- **Underscore prefix is not a hiding mechanism.** If a function is useful, name it well; if it shouldn't exist, delete it. Python's dunder/sunder conventions (`__init__`, `_asdict`, etc.) are exempt.
- **DRY.** If the same logic appears twice, extract it. Duplication is a maintenance liability.
- **Tests alongside code.** Every function has at least a happy-path test, an edge case, and a failure case. A function that's hard to test does too much.

---

## Task management

1. Write the plan to `tasks/todo.md` with checkable items.
2. Verify the plan before starting.
3. Mark items complete as you go.
4. Add a review section to `tasks/todo.md` when done.
5. Update `tasks/lessons.md` after any correction.

---

## Provenance

Merged from the user's existing project contract plus Karpathy's `CLAUDE.md` (`forrestchang/andrej-karpathy-skills`). Every Karpathy rule was already expressed — usually more strictly — in the sections above, so nothing was added verbatim. When conflicts arose, the more restrictive rule won.
