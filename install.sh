#!/usr/bin/env bash
set -euo pipefail

REPO="ohprettyhak/design-farmer"
BRANCH="${BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
SKILL_NAME="design-farmer"
SKILL_ROOT="skills/design-farmer"
BUNDLE_FILES=(
  "$SKILL_ROOT/SKILL.md"
  "$SKILL_ROOT/bin/version-check"
  "$SKILL_ROOT/docs/PHASE-INDEX.md"
  "$SKILL_ROOT/docs/QUALITY-GATES.md"
  "$SKILL_ROOT/docs/MAINTENANCE.md"
  "$SKILL_ROOT/docs/EXAMPLES-GALLERY.md"
  "$SKILL_ROOT/phases/operational-notes.md"
  "$SKILL_ROOT/phases/phase-0-preflight.md"
  "$SKILL_ROOT/phases/phase-1-discovery.md"
  "$SKILL_ROOT/phases/phase-2-repo-analysis.md"
  "$SKILL_ROOT/phases/phase-3-pattern-extraction.md"
  "$SKILL_ROOT/phases/phase-3.5-visual-preview.md"
  "$SKILL_ROOT/phases/phase-4-architecture.md"
  "$SKILL_ROOT/phases/phase-4b-theming.md"
  "$SKILL_ROOT/phases/phase-4.5-design-source-of-truth.md"
  "$SKILL_ROOT/phases/phase-5-tokens.md"
  "$SKILL_ROOT/phases/phase-6-components.md"
  "$SKILL_ROOT/phases/phase-7-storybook.md"
  "$SKILL_ROOT/phases/phase-8-review.md"
  "$SKILL_ROOT/phases/phase-8.5-design-review.md"
  "$SKILL_ROOT/phases/phase-9-documentation.md"
  "$SKILL_ROOT/phases/phase-10-integration.md"
  "$SKILL_ROOT/phases/phase-11-readiness-handoff.md"
  "$SKILL_ROOT/examples/DESIGN.md"
)

if [ -t 1 ]; then
  BOLD='\033[1m'
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  RESET='\033[0m'
else
  BOLD=''
  GREEN=''
  RED=''
  YELLOW=''
  RESET=''
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf "%bError:%b required command not found: %s\n" "$RED" "$RESET" "$1" >&2
    exit 1
  fi
}

install_bundle_atomic() {
  local target_dir="$1"
  shift

  local target_parent
  target_parent="$(dirname "$target_dir")"
  mkdir -p "$target_parent"

  local staging_dir
  staging_dir="$(mktemp -d "${target_parent}/.design-farmer-staging.XXXXXX")"
  local backup_dir=""

  for relative_path in "$@"; do
    local staged_path
    staged_path="${staging_dir}/${relative_path#${SKILL_ROOT}/}"
    mkdir -p "$(dirname "$staged_path")"

    if ! curl -fsSL "${RAW_BASE}/${relative_path}" -o "$staged_path" 2>/dev/null; then
      rm -rf "$staging_dir"
      return 1
    fi
  done

  if [ -d "$staging_dir/bin" ]; then
    find "$staging_dir/bin" -type f -exec chmod +x {} +
  fi

  if [ -d "$target_dir" ]; then
    backup_dir="$(mktemp -d "${target_parent}/.design-farmer-backup.XXXXXX")"
    rmdir "$backup_dir"
    if ! mv "$target_dir" "$backup_dir"; then
      rm -rf "$staging_dir"
      return 1
    fi
  fi

  if mv "$staging_dir" "$target_dir"; then
    if [ -n "$backup_dir" ] && [ -d "$backup_dir" ]; then
      rm -rf "$backup_dir"
    fi
    return 0
  fi

  rm -rf "$staging_dir"
  if [ -n "$backup_dir" ] && [ -d "$backup_dir" ]; then
    if ! mv "$backup_dir" "$target_dir"; then
      printf "%bError:%b rollback failed for %s; manual restore required.\n" "$RED" "$RESET" "$target_dir" >&2
    fi
  fi
  return 1
}

tool_marker() {
  case "$1" in
    claude) echo "${HOME}/.claude" ;;
    codex) echo "${HOME}/.agents" ;;
    amp) echo "${HOME}/.config/agents" ;;
    gemini) echo "${HOME}/.gemini" ;;
    opencode) echo "${HOME}/.config/opencode" ;;
  esac
}

tool_skill_dir() {
  case "$1" in
    claude) echo "${HOME}/.claude/skills/${SKILL_NAME}" ;;
    codex) echo "${HOME}/.agents/skills/${SKILL_NAME}" ;;
    amp) echo "${HOME}/.config/agents/skills/${SKILL_NAME}" ;;
    gemini) echo "${HOME}/.gemini/skills/${SKILL_NAME}" ;;
    opencode) echo "${HOME}/.config/opencode/skills/${SKILL_NAME}" ;;
  esac
}

tool_label() {
  case "$1" in
    claude) echo "Claude Code" ;;
    codex) echo "Codex CLI" ;;
    amp) echo "Amp" ;;
    gemini) echo "Gemini CLI" ;;
    opencode) echo "OpenCode" ;;
  esac
}

TOOLS=(claude codex amp gemini opencode)
DETECTED=()

for tool in "${TOOLS[@]}"; do
  marker="$(tool_marker "$tool")"
  if [ -d "$marker" ]; then
    DETECTED+=("$tool")
  fi
done

require_command curl

printf "%bInstalling design-farmer skill%b\n\n" "$BOLD" "$RESET"

if [ "${#DETECTED[@]}" -eq 0 ]; then
  printf "%bNo supported tools detected.%b\n" "$YELLOW" "$RESET"
  printf "Install one of these first, then run this script again:\n"
  printf "  - Claude Code:  https://claude.ai/code\n"
  printf "  - Codex CLI:    https://github.com/openai/codex\n"
  printf "  - Amp:          https://ampcode.com\n"
  printf "  - Gemini CLI:   https://github.com/google-gemini/gemini-cli\n"
  printf "  - OpenCode:     https://opencode.ai\n"
  exit 1
fi

FAILED=0

for tool in "${DETECTED[@]}"; do
  target_dir="$(tool_skill_dir "$tool")"
  label="$(tool_label "$tool")"

  if install_bundle_atomic "$target_dir" "${BUNDLE_FILES[@]}"; then
    printf "  %b✓%b %s\n" "$GREEN" "$RESET" "$label"
  else
    printf "  %b✗%b %s (bundle install failed; rollback attempted)\n" "$RED" "$RESET" "$label"
    FAILED=1
  fi
done

printf "\n"
printf "  %bInstalled%b */skills/%s/\n" "$GREEN" "$RESET" "$SKILL_NAME"
printf "  %bUsage%b: invoke your assistant with the %s skill context\n\n" "$GREEN" "$RESET" "$SKILL_NAME"

if [ "$FAILED" -ne 0 ]; then
  printf "%b  Completed with errors.%b\n" "$YELLOW" "$RESET"
  exit 1
fi

printf "  %bDone!%b\n\n" "$GREEN" "$RESET"
printf "  If you find Design Farmer useful, please consider starring the repository:\n"
printf "  %bhttps://github.com/ohprettyhak/design-farmer%b\n" "$BOLD" "$RESET"
