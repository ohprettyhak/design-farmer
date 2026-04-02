#!/usr/bin/env bash
set -euo pipefail

REPO="ohprettyhak/design-farmer"
BRANCH="${BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
SKILL_NAME="design-farmer"
SKILL_ROOT="skills/design-farmer"
BUNDLE_FILES=(
  "$SKILL_ROOT/SKILL.md"
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
  "$SKILL_ROOT/phases/phase-4.5-design-source-of-truth.md"
  "$SKILL_ROOT/phases/phase-5-tokens.md"
  "$SKILL_ROOT/phases/phase-6-components.md"
  "$SKILL_ROOT/phases/phase-7-storybook.md"
  "$SKILL_ROOT/phases/phase-8-review.md"
  "$SKILL_ROOT/phases/phase-8.5-design-review.md"
  "$SKILL_ROOT/phases/phase-9-documentation.md"
  "$SKILL_ROOT/phases/phase-10-integration.md"
  "$SKILL_ROOT/phases/phase-11-readiness-handoff.md"
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
  mkdir -p "$target_dir"

  tool_failed=0
  for relative_path in "${BUNDLE_FILES[@]}"; do
    target_path="${target_dir}/${relative_path#${SKILL_ROOT}/}"
    mkdir -p "$(dirname "$target_path")"

    if ! curl -fsSL "${RAW_BASE}/${relative_path}" -o "$target_path" 2>/dev/null; then
      tool_failed=1
      printf "  %b✗%b %s (%s download failed)\n" "$RED" "$RESET" "$label" "$relative_path"
      break
    fi
  done

  if [ "$tool_failed" -eq 0 ]; then
    printf "  %b✓%b %s\n" "$GREEN" "$RESET" "$label"
  else
    FAILED=1
  fi
done

printf "\n"
printf "Installed skill path: */skills/%s/\n" "$SKILL_NAME"
printf "Usage: invoke your assistant with the %s skill context\n" "$SKILL_NAME"

if [ "$FAILED" -ne 0 ]; then
  printf "%bCompleted with errors.%b\n" "$YELLOW" "$RESET"
  exit 1
fi

printf "%bDone!%b\n" "$GREEN" "$RESET"
