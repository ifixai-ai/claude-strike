# Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (framework chosen per language)

## Test-Driven Development

MANDATORY workflow:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Troubleshooting Test Failures

1. Use **tdd-guide** agent
2. Check test isolation
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)

## Agent Support

- **tdd-guide** - Use PROACTIVELY for new features, enforces write-tests-first

## Test Structure (AAA Pattern)

Prefer Arrange-Act-Assert structure for every test:

1. **Arrange** — set up inputs, fixtures, and any preconditions.
2. **Act** — invoke the behaviour under test exactly once.
3. **Assert** — verify the observable outcome.

One logical assertion per test. If you find yourself asserting two unrelated things, split the test.

### Test Naming

Name tests after the behaviour under test, not the function name. A reader should understand the scenario and the expected outcome from the test name alone. Examples:

- `returns empty list when no markets match query`
- `raises error when API key is missing`
- `falls back to substring search when cache is unavailable`

Avoid names like `test_process`, `test_1`, or `test_happy_path` — they carry no information.
