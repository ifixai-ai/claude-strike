# Agent Orchestration

## Available Agents

The following agents ship with this harness (under `~/.claude/agents/` for global install, `./.claude/agents/` for project install). Do not reference agents that are not in this list.

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| code-reviewer | General code review | Immediately after any non-trivial change |
| code-architect | System design, implementation blueprints | New module, planning a refactor |
| code-simplifier | Reduce complexity without changing behavior | A file feels bloated |
| build-error-resolver | Fix build and type errors with minimal diffs | Build breaks or type errors appear |
| database-reviewer | PostgreSQL / Supabase review | Any SQL, schema, or migration change |
| docs-lookup | Current library/API docs via Context7 MCP | Need up-to-date docs or API reference |
| planner | Implementation planning | Complex features, refactoring |
| security-reviewer | OWASP-grade security review | Auth, payments, user data, crypto |
| tdd-guide | Test-driven development enforcement | New features, bug fixes |
| comment-analyzer | Flag rotten, redundant, or noisy comments | Before shipping a PR |
| silent-failure-hunter | Find swallowed errors and bad fallbacks | Before shipping a PR |
| opensource-sanitizer | Audit for leaked secrets, PII, internal refs | Before publishing a repo |
| opensource-packager | Generate CLAUDE.md, setup.sh, README, LICENSE | Preparing a repo for release |

## Immediate Agent Usage

No user prompt needed:

1. Complex feature requests — use **planner**
2. Code just written or modified — use **code-reviewer**
3. Bug fix or new feature — use **tdd-guide**
4. Architectural decision — use **code-architect**
5. Any security-sensitive code — use **security-reviewer**
6. Preparing the repo for open-source release — use **opensource-sanitizer** then **opensource-packager**

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: parallel execution
Launch 3 agents in parallel:
1. Agent 1: security-reviewer on auth module
2. Agent 2: comment-analyzer on the changed files
3. Agent 3: silent-failure-hunter on the service layer

# BAD: sequential when unnecessary
First agent 1, then agent 2, then agent 3
```

## Multi-Perspective Analysis

For complex problems, use split-role sub-agents in parallel:

- factual reviewer
- senior engineer
- security expert
- consistency reviewer
- redundancy checker
