# ARCHITECTURE.md

This is the architecture landing page for coding agents and contributors.

Replace the placeholders in this file with repository-specific facts once the project structure is known.

## System Purpose

Describe the repository's job in one sentence.

## Core Flow

Document the main runtime flow in 3-5 ordered steps.

## Main Areas

- `cmd/` or equivalent entrypoint directory
- `core/` or equivalent domain logic
- `config/` or equivalent configuration package
- `docs/` for plans, validation rules, and architecture notes

## Key Boundaries

- identify the highest-coupling modules
- define which packages are public interfaces
- note which areas should not depend on each other directly

## Recommended Reading Order

1. [`AGENTS.md`](AGENTS.md)
2. [`docs/VALIDATION.md`](docs/VALIDATION.md)
3. [`docs/TASK_RECIPES.md`](docs/TASK_RECIPES.md)
4. [`docs/generated/repo-index.json`](docs/generated/repo-index.json)
