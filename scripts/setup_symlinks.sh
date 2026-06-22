#!/bin/bash
# scripts/setup_symlinks.sh
# Builds merged OpenCode instructions and deploys them to each repo.
#
# Deployment strategy:
#   - AGENTS.md  → symlink (mklink on Windows, ln -sfn on Unix)
#   - .opencode/ → cp -a    (directory merge; preserves user files like local overrides)
#   - specs/     → mklink /J junction on Windows, ln -sfn on Unix

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BLUEPRINT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_ROOT="$(cd "$BLUEPRINT_ROOT/.." && pwd)"

REPOS=("Backend" "Frontend" "iob.pme.playwrite.automation")
MERGED_ROOT="$BLUEPRINT_ROOT/merged"
VERBOSE="${1:-}"

# Returns space-separated list of shared context files to include for a given repo.
# Shared files are merged between global and repo-specific content, giving every
# project that references Backend the necessary API consumption context.
get_repo_shared() {
  case "$1" in
    Backend|Frontend|iob.pme.playwrite.automation)
      echo "shared/Backend.md"
      ;;
    *)
      echo ""
      ;;
  esac
}

log() {
  [ "$VERBOSE" != "--verbose" ] || echo "  $1"
}

# Deploy a file as a symlink.
# On Windows we require mklink support so repos keep a single AGENTS.md source.
deploy_file_link() {
  local src_file="$1"
  local dst_path="$2"
  [ -f "$src_file" ] || return 0

  rm -f "$dst_path"

  # Try Windows file symlink via cmd.exe.
  if command -v cygpath >/dev/null 2>&1; then
    local win_src win_dst
    win_src="$(cygpath -w "$src_file" 2>/dev/null || true)"
    win_dst="$(cygpath -w "$dst_path" 2>/dev/null || true)"
    if [ -n "$win_src" ] && [ -n "$win_dst" ]; then
      if cmd //c mklink "$win_dst" "$win_src" >/dev/null 2>&1; then
        log "Symlink: $dst_path -> $src_file"
        return
      fi

      echo "ERROR: failed to create file symlink $dst_path -> $src_file" >&2
      echo "Enable Windows Developer Mode or run with symlink permission." >&2
      return 1
    fi
  fi

  if ln -sfn "$src_file" "$dst_path" 2>/dev/null; then
    log "Symlink: $dst_path -> $src_file"
    return
  fi

  echo "ERROR: failed to create file symlink $dst_path -> $src_file" >&2
  return 1
}

# Merge a blueprint directory into a repo directory.
# Uses copy so user-specific files (settings.local.json, etc.) are preserved.
# Cleans up any incorrectly nested target dirs from prior failed runs.
deploy_dir() {
  local src_dir="$1"
  local dst_dir="$2"
  [ -d "$src_dir" ] || return 0

  # Clean up wrong nesting created by ln -sfn when target was an existing dir
  local basename
  basename="$(basename "$dst_dir")"
  [ -d "$dst_dir/$basename" ] && rm -rf "$dst_dir/$basename" && log "Cleaned nested $basename inside $dst_dir"

  mkdir -p "$dst_dir"
  cp -a "$src_dir/." "$dst_dir/"
  log "Merged dir: $dst_dir"
}

# Deploy a shared (specs) directory: tries Windows junction first, falls back to ln -sfn.
# Junctions on Windows work without admin rights and behave like symlinks for directories.
deploy_shared_dir() {
  local src_dir="$1"
  local dst_path="$2"
  [ -d "$src_dir" ] || return 0

  # Try Windows junction via cmd.exe (Git Bash exposes cmd as cmd.exe or cmd)
  if command -v cygpath >/dev/null 2>&1; then
    local win_src win_dst
    win_src="$(cygpath -w "$src_dir" 2>/dev/null || true)"
    win_dst="$(cygpath -w "$dst_path" 2>/dev/null || true)"
    if [ -n "$win_src" ] && [ -n "$win_dst" ]; then
      # Remove existing junction or directory before recreating
      [ -L "$dst_path" ] && rm "$dst_path"
      [ -d "$dst_path" ] && cmd //c rmdir "$win_dst" >/dev/null 2>&1 || true
      if cmd //c mklink /J "$win_dst" "$win_src" >/dev/null 2>&1; then
        log "Junction: $dst_path → $src_dir"
        return
      fi
    fi
  fi

  # Unix fallback: symlink
  [ -L "$dst_path" ] && rm "$dst_path"
  ln -sfn "$src_dir" "$dst_path" 2>/dev/null || true
  log "Linked: $dst_path → $src_dir"
}

ensure_gitignore_entry() {
  local repo_path="$1"
  local entry="$2"
  local gitignore_path="$repo_path/.gitignore"

  if [ ! -f "$gitignore_path" ]; then
    touch "$gitignore_path"
  fi

  if ! grep -Fxq "$entry" "$gitignore_path"; then
    printf "\n%s\n" "$entry" >> "$gitignore_path"
    log "Added to .gitignore: $entry"
  fi
}

merge_blueprint() {
  local repo_name="$1"
  local merged_dir="$MERGED_ROOT/$repo_name"
  local merged_opencode_dir="$merged_dir/.opencode"
  local global_opencode_dir="$BLUEPRINT_ROOT/global/.opencode"
  local repo_opencode_dir="$BLUEPRINT_ROOT/$repo_name/.opencode"
  local global_agents_file="$BLUEPRINT_ROOT/global/AGENTS.md"
  local repo_agents_file="$BLUEPRINT_ROOT/$repo_name/AGENTS.md"
  local merged_agents_file="$merged_dir/AGENTS.md"

  rm -rf "$merged_dir"
  mkdir -p "$merged_opencode_dir"

  if [ -d "$global_opencode_dir" ]; then
    cp -a "$global_opencode_dir/." "$merged_opencode_dir/"
  fi

  if [ -d "$repo_opencode_dir" ]; then
    cp -a "$repo_opencode_dir/." "$merged_opencode_dir/"
  fi

  : > "$merged_agents_file"
  if [ -f "$global_agents_file" ]; then
    cat "$global_agents_file" >> "$merged_agents_file"
  fi

  # Include shared context files for this repo (between global and repo-specific)
  IFS=' ' read -ra _shared <<< "$(get_repo_shared "$repo_name")"
  for _sf in "${_shared[@]}"; do
    [ -z "$_sf" ] && continue
    if [ -f "$BLUEPRINT_ROOT/$_sf" ]; then
      printf "\n\n" >> "$merged_agents_file"
      cat "$BLUEPRINT_ROOT/$_sf" >> "$merged_agents_file"
    fi
  done

  if [ -f "$repo_agents_file" ]; then
    if [ -s "$merged_agents_file" ]; then
      printf "\n\n" >> "$merged_agents_file"
    fi
    cat "$repo_agents_file" >> "$merged_agents_file"
  fi
}

merge_workspace() {
  local merged_dir="$MERGED_ROOT/workspace"
  local merged_opencode_dir="$merged_dir/.opencode"
  local global_opencode_dir="$BLUEPRINT_ROOT/global/.opencode"
  local global_agents_file="$BLUEPRINT_ROOT/global/AGENTS.md"
  local merged_agents_file="$merged_dir/AGENTS.md"
  local r

  rm -rf "$merged_dir"
  mkdir -p "$merged_opencode_dir"

  # Base: global .opencode
  if [ -d "$global_opencode_dir" ]; then
    cp -a "$global_opencode_dir/." "$merged_opencode_dir/"
  fi

  # Overlay every repo's .opencode (later repos win on filename conflict)
  for r in "${REPOS[@]}"; do
    local repo_opencode_dir="$BLUEPRINT_ROOT/$r/.opencode"
    if [ -d "$repo_opencode_dir" ]; then
      cp -a "$repo_opencode_dir/." "$merged_opencode_dir/"
    fi
  done

  # Build merged AGENTS.md: global first, then shared files, then each repo
  : > "$merged_agents_file"
  if [ -f "$global_agents_file" ]; then
    cat "$global_agents_file" >> "$merged_agents_file"
  fi

  # Include shared context files (deduplicated, before per-repo content)
  while IFS= read -r _sf; do
    [ -z "$_sf" ] && continue
    [ -f "$BLUEPRINT_ROOT/$_sf" ] || continue
    printf "\n\n" >> "$merged_agents_file"
    cat "$BLUEPRINT_ROOT/$_sf" >> "$merged_agents_file"
  done < <(for r in "${REPOS[@]}"; do get_repo_shared "$r"; done | grep -v '^$' | sort -u)

  for r in "${REPOS[@]}"; do
    local repo_agents_file="$BLUEPRINT_ROOT/$r/AGENTS.md"
    if [ -f "$repo_agents_file" ]; then
      if [ -s "$merged_agents_file" ]; then
        printf "\n\n" >> "$merged_agents_file"
      fi
      cat "$repo_agents_file" >> "$merged_agents_file"
    fi
  done
}

echo "Setting up OpenCode workspace assets..."

mkdir -p "$MERGED_ROOT"
REPOS_PROCESSED=0
REPOS_SKIPPED=0

for repo in "${REPOS[@]}"; do
  repo_path="$WORKSPACE_ROOT/$repo"

  if [ ! -d "$repo_path" ]; then
    log "Skipping $repo (not found)"
    REPOS_SKIPPED=$((REPOS_SKIPPED + 1))
    continue
  fi

  merge_blueprint "$repo"

  deploy_dir      "$MERGED_ROOT/$repo/.opencode" "$repo_path/.opencode"
  deploy_file_link "$MERGED_ROOT/$repo/AGENTS.md" "$repo_path/AGENTS.md"
  deploy_shared_dir "$BLUEPRINT_ROOT/specs" "$repo_path/specs"

  ensure_gitignore_entry "$repo_path" ".opencode"
  ensure_gitignore_entry "$repo_path" "AGENTS.md"
  ensure_gitignore_entry "$repo_path" "specs"

  bash scripts/setup_precommit_hook.sh "$repo_path" "$VERBOSE"
  ensure_gitignore_entry "$repo_path" ".githooks"

  REPOS_PROCESSED=$((REPOS_PROCESSED + 1))
done

merge_workspace
deploy_dir  "$MERGED_ROOT/workspace/.opencode" "$WORKSPACE_ROOT/.opencode"
deploy_file_link "$MERGED_ROOT/workspace/AGENTS.md" "$WORKSPACE_ROOT/AGENTS.md"

echo "✓ Setup complete: $REPOS_PROCESSED repos configured"
if [ "$VERBOSE" = "--verbose" ]; then
  [ "$REPOS_SKIPPED" -gt 0 ] && echo "  $REPOS_SKIPPED repos skipped"
  echo "  Run 'make setup-verbose' for detailed output"
fi
