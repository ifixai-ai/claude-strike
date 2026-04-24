# claude-strike

**Spec-driven Claude Code, dropped into your repo in one command.**

For developers using [Claude Code](https://docs.claude.com/claude-code) who want an opinionated starting point: a strict `CLAUDE.md`, five focused subagents (review, architect, simplify, TDD, security), and [spec-kit](https://github.com/github/spec-kit) wired up so non-trivial work goes through `/specify` → `/plan` → `/tasks` before code is written.

Works on macOS, Linux, and Windows (Git Bash or WSL).

## Install

From inside the repo you want to set up:

```sh
curl -fsSL https://raw.githubusercontent.com/n-papaioannou/claude-strike/main/bootstrap.sh | bash
```

What it does:

- Clones `claude-strike` into `~/.cache/claude-strike` (or `$CLAUDE_STRIKE_CACHE`).
- Copies files into your repo.
- Runs `specify init --here --ai claude` to add spec-kit.

Re-running is safe. Existing files are backed up to `<path>.bak.<timestamp>` before being overwritten.

### From a local checkout

```sh
git clone https://github.com/n-papaioannou/claude-strike.git /tmp/claude-strike
cd ~/your-project
bash /tmp/claude-strike/bootstrap.sh
```

### Requirements

- A git repo — run `git init` first if needed.
- `uv` on your PATH — see [docs](https://docs.astral.sh/uv/). If missing, files still install and spec-kit is skipped with a warning.

### What gets written

- `CLAUDE.md`
- `.claude/agents/`
- `.claude/rules/`
- `.specify/` and spec-kit commands

## Agents

- `code-reviewer` — quality and security pass after writes.
- `code-architect` — feature design and planning.
- `code-simplifier` — cut complexity without changing behaviour.
- `tdd-guide` — write tests first.
- `security-reviewer` — deep security pass for auth, crypto, payments, user data.

See [`CLAUDE.md`](CLAUDE.md) for when to use each one.

## Languages

Python has its own rules in [`.claude/rules/python/`](.claude/rules/python/). Other languages use the common rules.

## Security

See [SECURITY.md](SECURITY.md) to report a vulnerability.

## License

MIT — see [`LICENSE`](LICENSE). Upstream credits in [`NOTICE`](NOTICE).
