# Task Recipes

This document maps common task types to the real files and checks used in this repository.

Customize the file paths and validation commands once the repository structure stabilizes.

## Bugfix Task

Read first:

- `AGENTS.md`
- `ARCHITECTURE.md`
- `docs/VALIDATION.md`

Typical files:

- the failing module
- adjacent tests
- related config or docs if behavior changes

Minimum verification:

- focused test covering the fix
- broader package test if shared flow is affected

## Feature Task

Read first:

- `AGENTS.md`
- `ARCHITECTURE.md`
- `docs/generated/repo-index.json`

Typical files:

- new or changed feature modules
- tests
- user-facing docs

Minimum verification:

- focused tests
- integration or end-to-end checks if the feature crosses module boundaries
- build verification

## Refactor Task

Read first:

- `ARCHITECTURE.md`
- current plans in `docs/exec-plans/active/`

Minimum verification:

- unchanged behavior through existing tests
- broader validation if shared wiring moved

## Perf Task

Read first:

- `ARCHITECTURE.md`
- `docs/VALIDATION.md`

Minimum verification:

- benchmark before and after
- regression checks on correctness

## Docs or Analysis Task

Read first:

- `AGENTS.md`
- relevant docs in `docs/`

Minimum verification:

- review links and paths
- run repo-wide checks only if workflow guidance changed
