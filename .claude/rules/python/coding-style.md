---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python Coding Style

The general code rules live in the project's `CLAUDE.md`. This file adds Python specifics.

## Rules

- **PEP 8** conventions.
- **Type annotations** on every function signature — parameters and return.
- **Comments limited.** Only the *why* of a non-obvious decision. Delete noise comments, commented-out code, and comments that restate the signature.
- **Self-explanatory names.** No vague verbs (`run`, `process`, `handle`, `do`). Booleans prefix with `is_`, `has_`, or `can_`.
- **No docstrings unless the function is genuinely complex.** If the name and signature don't make behaviour obvious, split the function. Exception: framework-consumed docstrings (FastAPI/Flask routes, Pydantic field descriptions, click/typer help, Sphinx API references, pytest fixtures).
- **No magic numbers or strings.** Named constants at module scope for non-obvious literals. Inline is fine for `0`, `1`, `-1`, obvious indices, and universal values like HTTP status codes.

## Immutability

Prefer immutable data structures:

```python
from dataclasses import dataclass
from typing import NamedTuple

@dataclass(frozen=True)
class User:
    name: str
    email: str

class Point(NamedTuple):
    x: float
    y: float
```

## Formatting

- **black** for code formatting
- **isort** for import sorting
- **ruff** for linting
