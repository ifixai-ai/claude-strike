# claude-harness

A curated Claude Code harness that merges three upstream systems into one opinionated bundle:

| System | Role in this bundle |
|---|---|
| [Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code) | 13 curated agents + `rules/common` + `rules/python` |
| [`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills) | Rules merged into `CLAUDE.md`; see [`docs/karpathy-diff.md`](docs/karpathy-diff.md) for the audit |
| [`github/spec-kit`](https://github.com/github/spec-kit) | Opt-in per project, documented in [`docs/spec-kit.md`](docs/spec-kit.md) — not bundled |

Nothing here is novel. The value is the *curation*: one opinionated behavioural contract, the subset of ECC that survives the no-comments / no-hand-waving rules, and a single idempotent installer that applies them globally or per-repo.

## Quickstart

**One-liner** (once the repo is public):

```sh
curl -fsSL https://raw.githubusercontent.com/n-papaioannou/claude-harness/main/setup.sh | bash
```

The script auto-clones into `~/.cache/claude-harness` and runs `install.sh` for you. Pass flags after `bash -s --`:

```sh
# project install, plus spec-kit init in the current repo
curl -fsSL https://raw.githubusercontent.com/n-papaioannou/claude-harness/main/setup.sh | bash -s -- --project --spec-kit

# dry-run to see what would happen
curl -fsSL https://raw.githubusercontent.com/n-papaioannou/claude-harness/main/setup.sh | bash -s -- --dry-run
```

**If you've already cloned this repo:**

```sh
./setup.sh                           # global install, no spec-kit
./setup.sh --project                 # project install
./setup.sh --project --spec-kit      # project install + spec-kit init here
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
├── install.sh
├── uninstall.sh
├── setup.sh                           # one-shot: clone (if needed) + install + optional spec-kit
├── CLAUDE.md                          # merged behavioural contract
├── .claude/
│   ├── agents/                        # 13 ECC agents
│   └── rules/{common,python}/         # ECC rules
└── docs/
    ├── karpathy-diff.md               # rule-by-rule audit vs upstream
    └── spec-kit.md                    # opt-in pointer
```

## Behavioural contract

[`CLAUDE.md`](CLAUDE.md) is the source of truth for how Claude Code should behave in any repo touched by this harness. It merges the author's existing project contract with Karpathy's guidelines; see [`docs/karpathy-diff.md`](docs/karpathy-diff.md) for the rule-by-rule mapping.

## Language scope

Language-specific rules are bundled only for **Python**, in [`.claude/rules/python/`](.claude/rules/python/). Other stacks inherit the common rules and the general-purpose agents. If you need TypeScript/Go/Rust/etc. rule sets, copy them from upstream ECC — they were intentionally excluded here to keep the harness small and opinionated.

## spec-kit

Not installed by default. Run `./setup.sh --spec-kit` in a repo to add it, or see [`docs/spec-kit.md`](docs/spec-kit.md) for the manual command. When spec-kit is initialised in a repo, `CLAUDE.md` tells Claude to drive non-trivial work through `/specify` → `/plan` → `/tasks`.

## License

MIT — see [`LICENSE`](LICENSE). Upstream attributions are in [`NOTICE`](NOTICE).
