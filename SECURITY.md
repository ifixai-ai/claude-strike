# Security

## What this ships

- `bootstrap.sh` — shell script you run in your repo. It clones claude-strike, copies files, and runs `uvx specify init`. Existing files are backed up before being overwritten.
- `.claude/agents/*.md` — prompts run by Claude Code. A bad prompt could make an agent do something unsafe.

Bugs in upstream projects (spec-kit, agents sourced from others) should be reported to them.

## Report a vulnerability

**Do not open a public issue.**

Use GitHub's private flow: repo **Security** tab → **Report a vulnerability**. Include the affected file, steps to reproduce, and what you expected vs. what happened.

If that is not available, email the maintainer at the address on their GitHub profile with subject `[claude-strike security]`.

## Response

One maintainer. Expect a reply within a week. Priority goes to arbitrary code execution, leaked credentials, and writes outside your repo's `.claude/` or `CLAUDE.md`.

## Not a vulnerability

- `bootstrap.sh` cloning from its default URL when run outside a checkout — that is how the one-line install works. Override with `CLAUDE_STRIKE_REPO`.
- `bootstrap.sh` running `uvx specify init` — that is the documented spec-kit install. Pin the ref with `CLAUDE_STRIKE_SPEC_KIT_REF` or skip with `CLAUDE_STRIKE_SKIP_SPEC_KIT=1`.
- `bootstrap.sh` writing `CLAUDE.md` or `.claude/` in your repo — that is the product.
