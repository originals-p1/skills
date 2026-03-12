#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: init_project_bootstrap.sh <target-dir> [--force]

Create a minimal AGENTS-style governance scaffold:
  AGENTS.md
  ARCHITECTURE.md
  docs/VALIDATION.md
  docs/TASK_RECIPES.md
  docs/generated/repo-index.json
  docs/plans/
  docs/exec-plans/active/
  docs/exec-plans/completed/

By default, existing files are preserved. Use --force to overwrite them.
EOF
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

target_dir=$1
force_flag=${2:-}

if [[ "$target_dir" == "--force" ]]; then
  usage
  exit 1
fi

force=0
if [[ -n "$force_flag" ]]; then
  if [[ "$force_flag" != "--force" ]]; then
    usage
    exit 1
  fi
  force=1
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
skill_dir=$(cd "$script_dir/.." && pwd)
assets_dir="$skill_dir/assets"

mkdir -p "$target_dir"
target_dir=$(cd "$target_dir" && pwd)

while IFS= read -r rel_dir; do
  [[ -z "$rel_dir" ]] && continue
  mkdir -p "$target_dir/$rel_dir"
done < "$assets_dir/dirs.manifest"

copy_template() {
  local src=$1
  local rel=$2
  local dst="$target_dir/$rel"

  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && $force -ne 1 ]]; then
    printf 'skip  %s (exists)\n' "$rel"
    return
  fi
  cp "$src" "$dst"
  printf 'write %s\n' "$rel"
}

copy_template "$assets_dir/AGENTS.md" "AGENTS.md"
copy_template "$assets_dir/ARCHITECTURE.md" "ARCHITECTURE.md"
copy_template "$assets_dir/docs/VALIDATION.md" "docs/VALIDATION.md"
copy_template "$assets_dir/docs/TASK_RECIPES.md" "docs/TASK_RECIPES.md"
copy_template "$assets_dir/docs/generated/repo-index.json" "docs/generated/repo-index.json"

printf 'done  initialized %s\n' "$target_dir"
