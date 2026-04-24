# Development Workflow

> Commit format and PR mechanics live in [`git-workflow.md`](./git-workflow.md). Agent delegation lives in [`agents.md`](./agents.md). This file covers what happens *before* those.

## Research & Reuse (before any new implementation)

1. **GitHub code search first.** `gh search repos` / `gh search code` — find existing implementations, templates, patterns.
2. **Library docs second.** Context7 or primary vendor docs to confirm API behavior and version specifics.
3. **Exa only when the above are insufficient** — broader web research or discovery.
4. **Check package registries** (npm, PyPI, crates.io, etc.) before writing utility code. Prefer battle-tested libraries.
5. **Search for adaptable implementations** — open-source projects that solve 80%+ of the problem and can be forked, ported, or wrapped.

Prefer adopting or porting a proven approach over writing net-new code.

## Feature pipeline

1. Plan → `code-architect`
2. Test → `tdd-guide` (RED → GREEN → refactor, 80%+ coverage)
3. Review → `code-reviewer` (and `security-reviewer` for security-sensitive diffs)
4. Commit & PR → see [`git-workflow.md`](./git-workflow.md)
