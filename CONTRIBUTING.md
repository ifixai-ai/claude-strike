# Contributing to claude-harness

Thanks for considering a contribution. This harness is deliberately small and opinionated — please read this file before opening a PR so we can keep it that way.

## Scope

This repo curates three upstream systems into one installable bundle:

- Everything Claude Code (ECC) agents and rules
- Karpathy-style discipline, merged into `CLAUDE.md`
- `github/spec-kit` (referenced, not bundled)

**In scope:** bug fixes in install/uninstall scripts, clarifications to `CLAUDE.md` or agent prompts, documentation fixes, CI improvements, attribution fixes.

**Out of scope by default:** net-new agents, new language rule bundles, or new skills. Open an issue first with the use case — we will probably say no unless it earns its slot.

## Development setup

```sh
git clone https://github.com/n-papaioannou/claude-harness.git
cd claude-harness

# test a global install in an ephemeral HOME
HOME="$(mktemp -d)" ./install.sh --dry-run
HOME="$(mktemp -d)" ./install.sh

# or test a project install in a scratch dir
work="$(mktemp -d)"; cp -r . "$work/h"; cd "$work/h" && ./install.sh --project
```

Run the same round-trip CI runs locally before pushing:

```sh
shellcheck install.sh uninstall.sh setup.sh
```

## Making a change

1. Open an issue describing the change and confirm scope before coding.
2. Branch off `main`.
3. Keep the diff minimal — match existing style, don't reformat neighbours.
4. If the change is non-trivial (per the definition in `CLAUDE.md`), run the `code-reviewer` agent against your branch before requesting review.
5. Update `docs/` if behaviour visible to users changes.
6. Update `NOTICE` if you pull in any new upstream content.

## Install-script rules

The scripts in this repo run on users' machines with their credentials. Treat them as security-sensitive.

- **No unconditional writes.** Every destructive action must be guarded by an explicit flag or an idempotency check.
- **Manifest-tracked.** If `install.sh` creates a file, it must append to `.claude-harness-manifest` so `uninstall.sh` can remove it.
- **Backups before overwrite.** Any file that would be overwritten is first copied to `<path>.bak.<YYYYMMDD-HHMMSS>`.
- **POSIX-sh friendly where feasible.** Scripts run on macOS (bash 3.2) and Linux (bash 5+). Test on both.

## Adding or changing an agent

1. Agent files live in `.claude/agents/` as Markdown with frontmatter.
2. The `description` field must include clear trigger conditions — readers should know exactly when to invoke it.
3. Cross-check the delegation table in `CLAUDE.md`: add the agent there and in the `NOTICE` list.
4. Update the CI assertion in `.github/workflows/ci.yml` if needed.
5. Verify no overlap with an existing agent — if there is overlap, extend the existing one instead.

## Commit and PR style

- Conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `ci:`).
- One logical change per PR.
- PR description must include: what changed, why, and how it was tested (commands, not adjectives).
- CI must be green before review.

## License

By contributing, you agree that your contribution is licensed under the MIT license in `LICENSE`.
