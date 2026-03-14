---
name: project-bootstrap-from-agents
description: Initialize a repository with AGENTS-style governance entry files and planning directories. Use when a user wants to bootstrap a new project from an AGENTS.md template, create minimal architecture and validation docs, or scaffold docs/plans and docs/exec-plans folders without inventing structure from scratch.
---

# Project Bootstrap From Agents

Initialize a project with a minimal governance skeleton derived from an AGENTS-style workflow, then adapt the generated docs to the target repository.

Use this skill when the user asks to set up a new repository with agent-facing entry files, planning directories, and a basic repo index placeholder, especially when the generated docs should immediately reflect the actual codebase instead of staying as generic templates.

## Workflow

1. Confirm the target directory.
2. Inspect whether governance files already exist, and read enough repository context to understand the real structure before editing docs:
   - `README*`
   - build/runtime manifests such as `pyproject.toml`, `package.json`, `go.mod`, `Cargo.toml`, `Makefile`
   - top-level source, test, scripts, and docs directories
   - any existing architecture or validation docs
3. Run `scripts/init_project_bootstrap.sh <target-dir>` without `--force` first.
4. If the user explicitly wants to replace existing files, rerun with `--force`.
5. Immediately adapt the generated docs to the repository that was initialized. Do not stop at generic placeholders.
6. Summarize which facts were inferred from the codebase and which items still need manual clarification.

## What It Creates

- `AGENTS.md`
- `ARCHITECTURE.md`
- `docs/VALIDATION.md`
- `docs/TASK_RECIPES.md`
- `docs/generated/repo-index.json`
- `docs/plans/`
- `docs/exec-plans/active/`
- `docs/exec-plans/completed/`

## Rules

- Prefer the bundled templates in `assets/` over inventing new governance wording.
- Do not overwrite existing files unless the user asked for replacement.
- Keep initialization minimal. Do not add README files, CI files, or language-specific source scaffolding unless requested separately.
- After generation, replace template placeholders with repository-specific facts whenever those facts can be inferred from the codebase.
- Never leave obviously wrong generic text such as `cmd/`, `core/`, or `make test` if the target repository clearly uses a different structure or toolchain.
- If a fact cannot be inferred safely, mark it as a short explicit placeholder such as `TODO: confirm deployment entrypoint`, instead of inventing details.
- Prefer patching existing generated files over rewriting them from scratch.

## Post-Init Adaptation

After initialization, review and update each generated file against the target repository:

- `AGENTS.md`
  - point readers to the real architecture, validation, planning, and index documents
  - describe the actual change workflow for this repository
  - mention any repo-specific safety rules or critical directories
- `ARCHITECTURE.md`
  - replace generic module names with real entrypoints, packages, services, or apps
  - document the main runtime or developer flow using actual code paths
  - describe real boundaries and high-coupling areas
- `docs/VALIDATION.md`
  - replace placeholder commands with the real validation commands that match the repo toolchain
  - include the narrowest useful checks if the repo already has them
  - keep commands executable as written whenever possible
- `docs/TASK_RECIPES.md`
  - map bugfix, feature, refactor, perf, and docs tasks to real files, modules, and checks
  - use the repository's actual test and build entrypoints
- `docs/generated/repo-index.json`
  - update the placeholder index with the current repository's top-level structure and notable modules
  - keep it minimal but factual; do not invent dependency graphs that were not inspected

## Adaptation Heuristics

- Infer project purpose from `README*`, package metadata, and primary entrypoints.
- Infer validation commands from the repository's existing scripts and manifests before proposing new ones.
- Prefer existing terminology from the codebase when naming modules, layers, and workflows.
- If the repo is very small, keep the generated docs short instead of forcing heavyweight process language.
- If governance docs already exist, merge missing sections and normalize wording rather than duplicating guidance.

## Commands

Initialize into the current directory:

```bash
./scripts/init_project_bootstrap.sh .
```

Initialize another directory:

```bash
./scripts/init_project_bootstrap.sh /path/to/project
```

Force overwrite:

```bash
./scripts/init_project_bootstrap.sh /path/to/project --force
```

## Resources

- `scripts/init_project_bootstrap.sh`: copies the template files and creates the required directories.
- `assets/`: source templates for the generated governance files.
