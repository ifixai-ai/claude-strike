# Karpathy → `CLAUDE.md` rule mapping

[`CLAUDE.md`](../CLAUDE.md) claims every rule from [`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills) was already expressed, usually more strictly. This document is the audit.

Source: the `CLAUDE.md` at the root of the upstream Karpathy skills repo (15 distinct rules).

| # | Karpathy rule | Where it lives in this `CLAUDE.md` | Stricter here? |
|---|---|---|---|
| 1 | Surface assumptions explicitly; don't hide confusion | "Think before coding" — "State assumptions explicitly" | equal |
| 2 | Present multiple interpretations when ambiguous | "Think before coding" — "present multiple interpretations — don't pick silently" | equal |
| 3 | Propose simpler approaches; challenge overcomplicated designs | "Think before coding" ("Push back when a simpler approach exists") + "Demand elegance" | **stricter** — demands elegance on every non-trivial change |
| 4 | Stop when confused | "Think before coding" — "Stop and ask when unclear" | equal |
| 5 | Write minimal code | "Core principles → Simplicity first" | **stricter** — adds "If 200 lines could be 50, rewrite" |
| 6 | Reject unnecessary abstractions | "Simplicity first" ("No abstractions for single-use code") | equal |
| 7 | Omit impossible-scenario handling | "Simplicity first" ("No error handling for impossible scenarios") | equal |
| 8 | Rewrite if too long | "Simplicity first" + function/file size limits under "Code rules" | **stricter** — concrete limits (<20 lines, <800 files) |
| 9 | Make surgical edits | "Core principles → Surgical changes" | equal |
| 10 | Preserve existing style | "Surgical changes" ("Match existing style even if you'd do it differently") | equal |
| 11 | Flag unrelated issues, don't delete | "Surgical changes" ("Unrelated dead code gets mentioned, not deleted") | equal |
| 12 | Remove only your orphans | "Surgical changes" (second half of same rule) | equal |
| 13 | Define success criteria first | "Goal-driven execution" table | **stricter** — provides templates for test-first restatement |
| 14 | Use multi-step plans | "Workflow → Plan before acting" and "Task management" | **stricter** — requires `tasks/todo.md` for non-trivial work |
| 15 | Loop until verified | "Done means done" checklist | **stricter** — adds `code-reviewer` CRITICAL/HIGH gate |

## Summary

- Every Karpathy rule has a home in this `CLAUDE.md`.
- 6 of 15 rules are strictly stricter here (adds thresholds, templates, or mandatory checks).
- 9 of 15 are expressed at equivalent strength, just reworded.
- No Karpathy rule is dropped or weakened.

Because nothing is lost, no Karpathy file is copied into the bundle. If upstream adds new rules later, re-run this diff and update `CLAUDE.md` + this table.
