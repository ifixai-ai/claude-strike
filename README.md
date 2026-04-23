# claude-harness

A curated Claude Code harness that merges three upstream systems into one opinionated bundle:

| System | Role in this bundle |
|---|---|
| [Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code) | 13 curated agents + `rules/common` + `rules/python` |
| [`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills) | Rules merged into `CLAUDE.md` |
| [`github/spec-kit`](https://github.com/github/spec-kit) | Initialised automatically on project installs; see [`docs/spec-kit.md`](docs/spec-kit.md) |

Nothing here is novel. The value is the *curation*: one opinionated behavioural contract, the subset of ECC that survives the no-comments / no-hand-waving rules, and a single idempotent installer that applies them globally or per-repo.

## Quickstart

### Homebrew (recommended)

```sh
brew tap n-papaioannou/claude-harness https://github.com/n-papaioannou/claude-harness
brew install --HEAD claude-harness
```

That installs a `claude-harness` command:

```sh
claude-harness                       # global install to ~/.claude/
claude-harness --project             # project install into ./ + spec-kit init
claude-harness --project --no-spec-kit
claude-harness --dry-run             # print what would happen, write nothing
claude-harness --force               # overwrite an existing CLAUDE.md
```

The formula is HEAD-only until a tagged release exists — pin to a version once `v0.1.0` ships.

To upgrade: `brew upgrade --fetch-HEAD claude-harness`. To remove the command (not the `.claude/` files it wrote): `brew uninstall claude-harness`. Use `./uninstall.sh` to reverse the `.claude/` install itself.

### curl + bash

For users without Homebrew, or to script this in CI:

```sh
curl -fsSL https://raw.githubusercontent.com/n-papaioannou/claude-harness/main/setup.sh | bash
```

The script auto-clones into `~/.cache/claude-harness` and runs `install.sh` for you. Pass flags after `bash -s --`:

```sh
# project install — copies agents + CLAUDE.md, then runs `specify init --here`
curl -fsSL https://raw.githubusercontent.com/n-papaioannou/claude-harness/main/setup.sh | bash -s -- --project

# dry-run to see what would happen
curl -fsSL https://raw.githubusercontent.com/n-papaioannou/claude-harness/main/setup.sh | bash -s -- --dry-run
```

For reproducibility, pin the URL to a release tag (e.g. `refs/tags/v0.1.0/setup.sh`) instead of `main` once a tagged release exists.

### Cloned repo

```sh
./setup.sh                           # global install (spec-kit is per-project, so skipped here)
./setup.sh --project                 # project install + spec-kit init here
./setup.sh --project --no-spec-kit   # project install, skip spec-kit
./setup.sh --dry-run                 # print what would happen, write nothing
./setup.sh --force                   # overwrite an existing CLAUDE.md
```

After install, Claude Code automatically picks up:

- `CLAUDE.md` as the behavioural contract,
- the 13 agents in `.claude/agents/` as delegation targets,
- `rules/` as a reference library it can grep on demand.

Both install modes are idempotent. Any file that would be overwritten is first backed up to `<path>.bak.<YYYYMMDD-HHMMSS>`. The installer never overwrites an existing `CLAUDE.md` without `--force` — otherwise it prints a diff hint and skips.

To reverse an install:

```sh
./uninstall.sh           # global
./uninstall.sh --project # project
```

Uninstall reads a manifest the installer wrote and removes exactly those paths — nothing else.

## Bundled agents

Thirteen agents, grouped by role:

**General-purpose**
- `code-reviewer` — general-quality + security pass after writes
- `code-architect` — feature design, implementation blueprints
- `code-simplifier` — reduce complexity without changing behaviour
- `build-error-resolver` — minimal-diff build/type error fixes
- `database-reviewer` — PostgreSQL/Supabase review
- `docs-lookup` — Context7 MCP for up-to-date docs

**Workflow**
- `planner` — implementation planning
- `tdd-guide` — test-first enforcement
- `security-reviewer` — OWASP-grade security pass

**CLAUDE.md rule enforcers**
- `comment-analyzer` — enforces "no comments unless necessary"
- `silent-failure-hunter` — enforces "don't swallow exceptions silently"

**Open-source pipeline**
- `opensource-sanitizer` — scans for secrets/PII/internal refs pre-release
- `opensource-packager` — generates CLAUDE.md, setup.sh, README, LICENSE for a fresh repo

See [`CLAUDE.md`](CLAUDE.md) for the delegation table that tells Claude when to use which.

## What the installer does *not* touch

- `~/.claude/settings.json`, `~/.claude/hooks/`, `~/.claude/plugins/`
- Any skill or agent already in `~/.claude/` that is not in this bundle (e.g. a pre-existing `graphify` skill survives untouched)
- The memory system at `~/.claude/projects/*/memory/`

## Layout

```
claude-harness/
├── README.md
├── LICENSE
├── NOTICE
├── .gitignore
├── .github/workflows/ci.yml           # shellcheck + install round-trip
├── Formula/
│   └── claude-harness.rb              # Homebrew formula (HEAD-only until v0.1.0)
├── install.sh
├── uninstall.sh
├── setup.sh                           # one-shot: clone (if needed) + install + spec-kit init
├── CLAUDE.md                          # merged behavioural contract
├── .claude/
│   ├── agents/                        # 13 ECC agents
│   └── rules/{common,python}/         # ECC rules
└── docs/
    └── spec-kit.md                    # how spec-kit integrates
```

## Behavioural contract

[`CLAUDE.md`](CLAUDE.md) is the source of truth for how Claude Code should behave in any repo touched by this harness. It merges the author's existing project contract with Karpathy's guidelines.

## Language scope

Language-specific rules are bundled only for **Python**, in [`.claude/rules/python/`](.claude/rules/python/). Other stacks inherit the common rules and the general-purpose agents. If you need TypeScript/Go/Rust/etc. rule sets, copy them from upstream ECC — they were intentionally excluded here to keep the harness small and opinionated.

## spec-kit

Project installs (`./setup.sh --project`) initialise spec-kit automatically — this requires [`uv`](https://docs.astral.sh/uv/) on `PATH` and an existing `.git/` in the target directory. Pass `--no-spec-kit` to skip. Global installs don't initialise spec-kit because `.specify/` is per-project. See [`docs/spec-kit.md`](docs/spec-kit.md) for details. When spec-kit is initialised in a repo, `CLAUDE.md` tells Claude to drive non-trivial work through `/specify` → `/plan` → `/tasks`.

## License

MIT — see [`LICENSE`](LICENSE). Upstream attributions are in [`NOTICE`](NOTICE).
