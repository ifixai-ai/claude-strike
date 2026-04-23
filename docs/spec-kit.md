# spec-kit (opt-in, per project)

[`spec-kit`](https://github.com/github/spec-kit) is GitHub's spec-driven
workflow tool for AI coding agents. It is **not bundled** with `claude-harness`
because it belongs per-project, not globally — it writes a `.specify/`
directory and slash commands into whatever repo you run it in.

## When to add it

Add spec-kit to a project when you want spec-first workflow: write a spec,
generate a plan and tasks, then implement. Skip it for quick scripts or
exploratory work.

## How to add it

Run from the repo root, with Claude Code selected as the agent:

```sh
uvx --from git+https://github.com/github/spec-kit.git specify init --here --ai claude
```

Requirements:

- `uv` installed (`brew install uv` or per [the uv docs](https://docs.astral.sh/uv/)).
- The repo must already have a `.git/` (run `git init` first if needed).

After init, spec-kit drops slash commands like `/specify`, `/plan`, `/tasks`
into `.claude/commands/`. Those are additive; they do not conflict with the
agents, rules, or skill this harness installs.

## How it relates to the rest of the harness

- `CLAUDE.md` still wins on behavioral rules.
- ECC agents (`code-reviewer`, `code-architect`, etc.) remain the default
  delegation targets.
- spec-kit is orthogonal — it structures the *work*, not the *review*.

## Uninstalling

`rm -rf .specify .claude/commands` (or cherry-pick whatever spec-kit wrote).
There is no global state to clean up.
