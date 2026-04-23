# Changelog

All notable changes to this project are documented in this file. The format
is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-23

First public release.

### Added

- Behavioural contract (`CLAUDE.md`) merging the maintainer's project rules
  with ideas from `forrestchang/andrej-karpathy-skills`.
- 13 curated agents from `everything-claude-code` (MIT) under
  `.claude/agents/`: `build-error-resolver`, `code-architect`, `code-reviewer`,
  `code-simplifier`, `comment-analyzer`, `database-reviewer`, `docs-lookup`,
  `opensource-packager`, `opensource-sanitizer`, `planner`, `security-reviewer`,
  `silent-failure-hunter`, `tdd-guide`.
- `rules/common/` and `rules/python/` from ECC.
- `install.sh` — idempotent, manifest-tracked, backup-on-overwrite install to
  `~/.claude/` (global) or `./.claude/` (project).
- `uninstall.sh` — removes exactly what the manifest says was installed.
- `setup.sh` — one-liner bootstrap that clones the repo into
  `~/.cache/claude-harness` and runs `install.sh`.
- `Formula/claude-harness.rb` — HEAD-only Homebrew formula wrapping `setup.sh`.
- Project installs auto-initialise `spec-kit` via `uvx` (opt out with
  `--no-spec-kit`).
- CI (`.github/workflows/ci.yml`): `shellcheck` plus install → idempotent
  re-install → uninstall → assert-clean round-trip, and a project-mode smoke.
- Community files: `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`,
  `.github/ISSUE_TEMPLATE/`, `.github/pull_request_template.md`.

[Unreleased]: https://github.com/n-papaioannou/claude-harness/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/n-papaioannou/claude-harness/releases/tag/v0.1.0
