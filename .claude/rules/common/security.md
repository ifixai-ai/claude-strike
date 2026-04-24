# Security Guidelines

## Pre-commit checklist

- No hardcoded secrets (keys, passwords, tokens)
- All user inputs validated
- Parameterized DB queries (no string concatenation)
- Output escaped (XSS), CSRF protection enabled
- Auth/authz verified
- Rate limiting on endpoints
- Error messages don't leak internals

## Secrets

Use environment variables or a secret manager. Validate required secrets exist at startup. Rotate anything that may have been exposed.

## When in doubt

Use `security-reviewer` (not `code-reviewer`) for auth, crypto, payments, user-data handling, external API boundaries.
