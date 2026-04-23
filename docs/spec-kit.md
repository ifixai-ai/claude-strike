# spec-kit

[`spec-kit`](https://github.com/github/spec-kit) is GitHub's spec-driven
workflow tool for AI coding agents. It writes a `.specify/` directory and
slash commands into whatever repo you run it in, which is why it is
installed **per-project, not globally**.

## How claude-harness wires it in

`./setup.sh --project` runs `specify init --here --ai claude` automatically
after copying the agents and `CLAUDE.md`. Pass `--no-spec-kit` to skip.
Global installs (`./setup.sh` without `--project`) never initialise spec-kit,
because `.specify/` only makes sense inside a specific repo.

Requirements for auto-init:

- `uv` on `PATH` (`brew install uv` or per [the uv docs](https://docs.astral.sh/uv/)).
  Missing `uv` prints a warning and continues — agents and `CLAUDE.md` still install.
- The target directory has a `.git/` (run `git init` first if needed).

After init, spec-kit drops slash commands like `/specify`, `/plan`, `/tasks`
into `.claude/commands/`. Those are additive; they do not conflict with the
agents, rules, or skill this harness installs.

## Initialising manually

If you skipped spec-kit at setup time and want it later:

```sh
uvx --from git+https://github.com/github/spec-kit.git specify init --here --ai claude
```

## How it relates to the rest of the harness

- `CLAUDE.md` still wins on behavioral rules.
- ECC agents (`code-reviewer`, `code-architect`, etc.) remain the default
  delegation targets.
- spec-kit is orthogonal — it structures the *work*, not the *review*.

## Uninstalling

`rm -rf .specify .claude/commands` (or cherry-pick whatever spec-kit wrote).
There is no global state to clean up.
