---
name: project-bootstrap-from-agents
description: Initialize a repository with AGENTS-style governance entry files and planning directories. Use when a user wants to bootstrap a new project from an AGENTS.md template, create minimal architecture and validation docs, or scaffold docs/plans and docs/exec-plans folders without inventing structure from scratch.
---

# Project Bootstrap From Agents

Initialize a project with a minimal governance skeleton derived from an AGENTS-style workflow.

Use this skill when the user asks to set up a new repository with agent-facing entry files, planning directories, and a basic repo index placeholder.

## Workflow

1. Confirm the target directory.
2. Inspect whether governance files already exist.
3. Run `scripts/init_project_bootstrap.sh <target-dir>` without `--force` first.
4. If the user explicitly wants to replace existing files, rerun with `--force`.
5. Review generated files and adapt obvious project-specific placeholders.

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
- After generation, call out remaining placeholders that require project-specific edits.

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
