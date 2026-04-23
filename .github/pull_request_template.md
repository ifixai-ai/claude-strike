## What changed

<!-- One-line summary, then bullets if needed. -->

## Why

<!-- The motivation. Link an issue if one exists. -->

## How it was tested

<!-- Commands, not adjectives. For example:
     - `shellcheck install.sh setup.sh uninstall.sh`
     - `./install.sh --dry-run`
     - `./install.sh && ./uninstall.sh && test ! -d ~/.claude/agents/code-reviewer.md`
     - CI round-trip passed locally via `act` (or linked CI run) -->

## Checklist

- [ ] Diff is minimal — no unrelated reformatting, no speculative abstractions.
- [ ] Conventional-commit subject (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `ci:`).
- [ ] If a new file is written by `install.sh`, it is appended to the manifest and removable by `uninstall.sh`.
- [ ] If an upstream source was pulled in, `NOTICE` is updated.
- [ ] If user-visible behavior changed, `README.md` / `docs/` is updated.
- [ ] If a new agent was added or changed, the delegation table in `CLAUDE.md` and the list in `NOTICE` are updated.
- [ ] For non-trivial changes: `code-reviewer` agent run reports no CRITICAL or HIGH findings.
- [ ] CI is green.
