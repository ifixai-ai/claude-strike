# Security Policy

## Scope

`claude-harness` ships three shell scripts that write into `$HOME/.claude/` (or
a project directory), plus a Homebrew formula that wraps `setup.sh`. The
attack surface worth worrying about is:

- `install.sh`, `setup.sh`, `uninstall.sh` — arbitrary file writes under the
  user's home directory and, with `setup.sh`, a `git clone` from a
  user-overridable URL.
- `Formula/claude-harness.rb` — installs into a Homebrew prefix and exposes
  the `claude-harness` command.
- `.claude/agents/*.md` — prompt content executed by Claude Code. A malicious
  prompt in this directory could coerce a user's agent into unsafe actions.

Supply-chain risks in upstream projects (`everything-claude-code`, `spec-kit`)
are **out of scope** — report those directly to the upstream maintainers.

## Reporting a vulnerability

**Do not open a public issue for a suspected vulnerability.**

Use GitHub's private disclosure flow:

1. Go to the repo's **Security** tab → **Report a vulnerability**.
2. Include: affected file(s), reproduction steps, observed vs. expected
   behavior, and your assessment of impact.

If private disclosure is unavailable, email the maintainer at the address on
the maintainer's GitHub profile with a subject line starting
`[claude-harness security]`.

## Response expectations

This is a one-maintainer project. Acknowledgement within one week;
severity-dependent fix timeline. Critical issues (arbitrary code execution,
credential exposure, destructive filesystem writes outside `$HOME/.claude` or
the project's `.claude/`) will be prioritized.

## Supported versions

Only the most recent release is supported. There is no backport policy.

## What is not a vulnerability

- `setup.sh` running `git clone` / `git pull` against its default repo URL.
  That is how the installer bootstraps. Override with `CLAUDE_HARNESS_REPO` or
  `--repo-url=` to pin elsewhere.
- The installer writing into `~/.claude/` or a project's `.claude/`. That is
  the product.
- Behavior governed by an upstream agent's prompt. Report those upstream.
