# Agent Orchestration

## Available Agents

The following agents ship with this harness (under `~/.claude/agents/` for global install, `./.claude/agents/` for project install). Do not reference agents that are not in this list.

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| code-reviewer | General code review | Immediately after any non-trivial change |
| code-architect | System design, implementation blueprints, and implementation planning | New module, complex feature, or refactor |
| code-simplifier | Reduce complexity without changing behavior | A file feels bloated |
| security-reviewer | OWASP-grade security review | Auth, payments, user data, crypto |
| tdd-guide | Test-driven development enforcement | New features, bug fixes |

## Immediate Agent Usage

No user prompt needed:

1. Complex feature requests, new modules, or refactors — use **code-architect**
2. Code just written or modified — use **code-reviewer**
3. Bug fix or new feature — use **tdd-guide**
4. Any security-sensitive code — use **security-reviewer**

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: parallel execution
Launch 3 agents in parallel:
1. Agent 1: security-reviewer on auth module
2. Agent 2: code-reviewer on the changed files
3. Agent 3: code-simplifier on the bloated module

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
