---
name: project-bootstrap-from-agents
description: Initialize a repository with AGENTS-style governance entry files and planning directories. Use when a user wants to bootstrap a new project from an AGENTS.md template, create minimal architecture and validation docs, or scaffold docs/plans and docs/exec-plans folders without inventing structure from scratch.
---

# Project Bootstrap From Agents

## 1. Goal

Initialize a repository with an AGENTS-style governance skeleton, then immediately adapt the generated files to the real repository.

Required output scope:

- `AGENTS.md`
- `ARCHITECTURE.md`
- `docs/VALIDATION.md`
- `docs/TASK_RECIPES.md`
- `docs/generated/repo-index.json`
- `docs/plans/`
- `docs/exec-plans/active/`
- `docs/exec-plans/completed/`

Use bundled templates in `assets/` and the bootstrap script in `scripts/init_project_bootstrap.sh`. Do not invent extra governance artifacts.

## 2. When to Use

Use this skill when the user wants to:

- bootstrap a repository with AGENTS-style governance files
- add missing governance files to an existing project
- normalize a repo onto the provided templates, then adapt them to repository-specific facts
- scaffold planning directories without inventing custom structure

Do not use this skill for:

- language/framework source scaffolding
- CI setup
- deployment setup
- rewriting unrelated docs outside the governance scope

## 3. Inputs

Required inputs:

- `target_dir`: repository or project root to initialize
- `overwrite_mode`: `none` | `merge` | `force`
- `bootstrap_style`: `minimal` | `standard`

Optional input:

- `user_constraints`: extra user instructions that limit scope, wording, or allowed changes

Input handling rules:

- Default `overwrite_mode` to `none` if not specified.
- Treat `merge` as: initialize missing files without force, then patch existing governance docs in place.
- Treat `force` as: rerun bootstrap with `--force`, then adapt files to repository facts.
- Treat `bootstrap_style` as a verbosity control only. Do not change the output file set.
- Apply `user_constraints` only when they do not conflict with this protocol's hard rules.

## 4. Preconditions

Before execution, confirm all of the following:

- `target_dir` exists.
- `target_dir` is the repository root or intended project root.
- `scripts/init_project_bootstrap.sh` exists and is executable or runnable with `bash`.
- `assets/` exists.

Existing-file safety rules:

- If governance files already exist and `overwrite_mode` is not `force`, do not replace whole files through bootstrap overwrite.
- If governance files already exist and `overwrite_mode` is `merge`, patch missing or incorrect sections only.
- If `target_dir` is invalid, stop and report the reason.
- If `scripts/init_project_bootstrap.sh` is missing or unusable, stop and report the reason.

## 5. Inspection Budget

Use the minimum context required to infer repository facts. Do not default to a full repository scan.

Read in this order:

1. `README*` at the repo root, if present
2. one primary manifest or build file:
   - `pyproject.toml`
   - `package.json`
   - `go.mod`
   - `Cargo.toml`
   - `Makefile`
   - equivalent primary manifest
3. top-level directory listing
4. existing governance docs, if present:
   - `AGENTS.md`
   - `ARCHITECTURE.md`
   - `docs/VALIDATION.md`
   - `docs/TASK_RECIPES.md`
5. only if still needed, read 1 to 2 primary entrypoint files

Inspection limits:

- Do not scan the whole tree by default.
- Do not read more files once repository purpose, structure, and validation evidence are clear.
- Prefer manifest-backed facts over inferred narrative.

## 6. Decision Flow

Follow this branch logic exactly:

1. Validate preconditions.
   - If any precondition fails, stop and report the failure.
2. Check whether governance files already exist.
3. Choose bootstrap mode:
   - No governance files present: run bootstrap without `--force`.
   - Governance files present and `overwrite_mode = none`: run bootstrap without `--force`; allow script-level skips; then adapt only newly created files and safe in-place patches.
   - Governance files present and `overwrite_mode = merge`: run bootstrap without `--force`; patch existing governance files in place; do not whole-file replace.
   - Governance files present and `overwrite_mode = force`: run bootstrap with `--force`; then adapt all governed files to repository facts.
4. Check repository fact quality after minimal inspection.
   - If facts are sufficient, replace template placeholders with repository-specific facts.
   - If facts are insufficient, keep docs minimal and insert explicit `TODO` markers for unknowns.
5. Validate claimed commands and structure.
   - If a command cannot be supported by repository evidence, do not claim it as real.

Stop conditions:

- invalid `target_dir`
- missing bootstrap script
- target is not a repository or project root and the user did not request creation there
- required repository facts cannot be verified and the task depends on them being exact

Degrade instead of guessing:

- If purpose is unclear, describe the repo minimally.
- If validation commands are unclear, write `TODO: confirm validation command`.
- If architecture boundaries are unclear, document only observed top-level modules and entrypoints.

## 7. Execution Steps

1. Resolve inputs.
2. Check preconditions.
3. Inspect the minimum repository context under the inspection budget.
4. Run `scripts/init_project_bootstrap.sh <target_dir>` without `--force` unless `overwrite_mode = force`.
5. If `overwrite_mode = force`, rerun with `--force`.
6. Adapt each output file to repository facts.
7. Merge or patch existing governance docs according to the adaptation rules.
8. Validate all documented commands against repository evidence.
9. Produce a fixed-structure report.

Per-file adaptation requirements:

- `AGENTS.md`
  - point to the real architecture, validation, planning, and index docs
  - describe the actual repo workflow using observed terminology
  - preserve existing repo-specific safety rules when present
- `ARCHITECTURE.md`
  - replace generic module names with observed modules, services, packages, or apps
  - document only observed entrypoints, boundaries, and high-coupling areas
  - keep small repositories brief
- `docs/VALIDATION.md`
  - include only commands supported by manifest, scripts, Makefile, README, or existing docs
  - use `TODO: confirm validation command` where evidence is missing
- `docs/TASK_RECIPES.md`
  - map bugfix, feature, refactor, perf, and docs tasks to observed files, modules, and checks
  - keep recipes aligned with the actual toolchain
- `docs/generated/repo-index.json`
  - record the observed top-level structure and notable modules only
  - keep the index minimal and factual

## 8. Adaptation Rules

Apply these rules to every generated or patched file:

- Use templates from `assets/` as the base wording.
- Replace template placeholders only with observed repository facts.
- Preserve repository terminology. Do not force template terminology over existing local terms.
- Do not leave obviously wrong generic text in place.
- Do not invent build, test, lint, deploy, benchmark, or release commands.
- Prefer patching existing docs over whole-file replacement.
- If a repository already has repo-specific governance policy, retain it and add missing structure around it.
- Keep small repositories lightweight. Do not add heavyweight process language to a tiny codebase.
- If a fact is uncertain, mark it with a short explicit `TODO` instead of guessing.
- Avoid duplicate guidance across governance docs when an existing section can be extended.

Merge rules for existing files:

- `overwrite_mode = none`
  - create missing files only
  - do not rewrite existing governance files wholesale
  - allow narrow corrective patches if needed to remove obvious template errors introduced by the bootstrap process
- `overwrite_mode = merge`
  - preserve the existing file
  - add missing sections
  - update stale template text
  - keep repo-specific policy and wording where compatible
- `overwrite_mode = force`
  - full reinitialization is allowed
  - adaptation to repository facts is still mandatory immediately after bootstrap

## 9. Validation Rules

Validation commands written into `docs/VALIDATION.md` must be traceable to repository evidence.

Allowed evidence sources:

- package or build manifests
- `scripts/`
- `Makefile`
- `README*`
- existing repository docs

Validation rules:

- Only write a command as supported if an evidence source implies or states it.
- Prefer the narrowest correct validation commands over generic full-suite commands.
- If no command can be confirmed, write:
  - `TODO: confirm validation command`
- Do not output plausible-but-unverified commands such as `make test` unless the repo actually supports them.
- Do not claim validation was run unless it was actually run.

## 10. Output Files

This skill manages only these outputs:

- `AGENTS.md`
- `ARCHITECTURE.md`
- `docs/VALIDATION.md`
- `docs/TASK_RECIPES.md`
- `docs/generated/repo-index.json`
- `docs/plans/`
- `docs/exec-plans/active/`
- `docs/exec-plans/completed/`

No extra files should be created unless the user explicitly requests them.

## 11. Report Format

End with this exact report structure:

- `created_files`
- `updated_files`
- `skipped_overwrites`
- `inferred_repo_facts`
- `unresolved_todos`
- `detected_validation_commands`

Report rules:

- Include only files actually created or updated.
- List skipped files when overwrite was intentionally avoided.
- Separate verified facts from unresolved items.
- List only validation commands that were actually detected from evidence.
- If no items exist for a field, return an empty list for that field.

## 12. Commands

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

Operational notes:

- For `overwrite_mode = none` or `merge`, do not pass `--force`.
- For `overwrite_mode = force`, pass `--force`.
- Adapt generated files after bootstrap in all modes.

## 13. Resources

- `scripts/init_project_bootstrap.sh`: initializes the governance scaffold and creates the required directories.
- `assets/`: source templates for the generated governance files.
- `assets/dirs.manifest`: canonical directory list for scaffold creation.
