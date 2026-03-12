# Validation Guide

This document defines how to verify changes in this repository.

## Standard Validation

Preferred full validation:

```bash
make test
make build
```

Adjust these commands to the actual toolchain used by the repository.

## Narrow Changes

If a change is localized, start with targeted checks first, then escalate to the full set if shared behavior may be affected.

Typical examples:

- package-specific unit tests
- linting for a touched module
- one integration test for a changed workflow

## Documentation and Sync Checks

When behavior changes, review whether these need updates:

- user-facing docs
- config examples
- architecture docs
- planning docs

## Completion Rule

Do not claim a task is complete without fresh verification evidence from the relevant commands.
