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

is_supported_tool() {
  local candidate="$1"
  local tool
  for tool in "${TOOLS[@]}"; do
    if [ "$tool" = "$candidate" ]; then
      return 0
    fi
  done
  return 1
}

print_usage() {
  cat <<'EOF'
Usage: install.sh [options]

Options:
  --tool <name>     Install only for the given tool (repeatable)
                    Valid: claude, codex, amp, gemini, opencode
  --all             Install for all detected tools (default behavior)
  --interactive     Select install targets interactively
  --dry-run         Show resolved install targets without writing files
  --list-tools      List supported tools and detected status, then exit
  -h, --help        Show this help message
EOF
}

list_tools() {
  local tool
  printf "%bSupported tools%b\n" "$BOLD" "$RESET"
  for tool in "${TOOLS[@]}"; do
    local marker
    local status="not detected"
    marker="$(tool_marker "$tool")"
    if [ -d "$marker" ]; then
      status="detected"
    fi
    printf "  - %-8s %-12s %s\n" "$tool" "[$status]" "$marker"
  done
}

append_unique_tool() {
  local candidate="$1"
  local existing
  for existing in "${SELECTED[@]}"; do
    if [ "$existing" = "$candidate" ]; then
      return 0
    fi
  done
  SELECTED+=("$candidate")
}

select_interactively() {
  if [ "${#DETECTED[@]}" -eq 0 ]; then
    printf "%bError:%b --interactive requires at least one detected tool.\n" "$RED" "$RESET" >&2
    exit 1
  fi

  if [ ! -t 1 ] || [ ! -r /dev/tty ]; then
    printf "%bError:%b --interactive requires an interactive terminal.\n" "$RED" "$RESET" >&2
    exit 1
  fi

  printf "%bInteractive target selection%b\n" "$BOLD" "$RESET"

  if command -v fzf >/dev/null 2>&1; then
    printf "Use Space to toggle, Enter to confirm.\n\n"
    local chosen=()
    local picked
    while IFS= read -r picked; do
      chosen+=("$picked")
    done < <(printf "%s\n" "${DETECTED[@]}" | fzf --multi --prompt "Select install targets > " --height 40% --border --layout=reverse)

    if [ "${#chosen[@]}" -eq 0 ]; then
      printf "%bError:%b no tools selected.\n" "$RED" "$RESET" >&2
      exit 1
    fi

    SELECTED=("${chosen[@]}")
    return 0
  fi

  printf "fzf not found. Falling back to numeric selection.\n"
  printf "Enter comma-separated numbers (example: 1,3).\n\n"

  local i=1
  local tool
  for tool in "${DETECTED[@]}"; do
    printf "  %d) %s\n" "$i" "$(tool_label "$tool")"
    i=$((i + 1))
  done

  printf "\nSelection: "
  local raw_input
  IFS= read -r raw_input </dev/tty
  if [ -z "$raw_input" ]; then
    printf "%bError:%b no tools selected.\n" "$RED" "$RESET" >&2
    exit 1
  fi

  local parts
  IFS=',' read -r -a parts <<<"$raw_input"
  local part
  for part in "${parts[@]}"; do
    local idx
    idx="${part//[[:space:]]/}"

    if [[ ! "$idx" =~ ^[0-9]+$ ]]; then
      printf "%bError:%b invalid selection '%s'.\n" "$RED" "$RESET" "$part" >&2
      exit 1
    fi
    if [ "$idx" -lt 1 ] || [ "$idx" -gt "${#DETECTED[@]}" ]; then
      printf "%bError:%b selection out of range: %s.\n" "$RED" "$RESET" "$idx" >&2
      exit 1
    fi

    append_unique_tool "${DETECTED[$((idx - 1))]}"
  done

  if [ "${#SELECTED[@]}" -eq 0 ]; then
    printf "%bError:%b no tools selected.\n" "$RED" "$RESET" >&2
    exit 1
  fi
}

TOOLS=(claude codex amp gemini opencode)
DETECTED=()
REQUESTED_TOOLS=()
SELECTED=()
USE_ALL=0
INTERACTIVE=0
DRY_RUN=0
LIST_ONLY=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --tool)
      if [ "$#" -lt 2 ]; then
        printf "%bError:%b --tool requires a value.\n" "$RED" "$RESET" >&2
        exit 1
      fi
      REQUESTED_TOOLS+=("$2")
      shift 2
      ;;
    --all)
      USE_ALL=1
      shift
      ;;
    --interactive)
      INTERACTIVE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --list-tools)
      LIST_ONLY=1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      printf "%bError:%b unknown option: %s\n\n" "$RED" "$RESET" "$1" >&2
      print_usage >&2
      exit 1
      ;;
  esac
done

if [ "$LIST_ONLY" -eq 1 ]; then
  for tool in "${TOOLS[@]}"; do
    marker="$(tool_marker "$tool")"
    if [ -d "$marker" ]; then
      DETECTED+=("$tool")
    fi
  done
  list_tools
  exit 0
fi

if [ "$INTERACTIVE" -eq 1 ] && [ "${#REQUESTED_TOOLS[@]}" -gt 0 ]; then
  printf "%bError:%b --interactive cannot be combined with --tool.\n" "$RED" "$RESET" >&2
  exit 1
fi

if [ "$INTERACTIVE" -eq 1 ] && [ "$USE_ALL" -eq 1 ]; then
  printf "%bError:%b --interactive cannot be combined with --all.\n" "$RED" "$RESET" >&2
  exit 1
fi

if [ "$USE_ALL" -eq 1 ] && [ "${#REQUESTED_TOOLS[@]}" -gt 0 ]; then
  printf "%bError:%b --all cannot be combined with --tool.\n" "$RED" "$RESET" >&2
  exit 1
fi

for tool in "${TOOLS[@]}"; do
  marker="$(tool_marker "$tool")"
  if [ -d "$marker" ]; then
    DETECTED+=("$tool")
  fi
done

printf "%bInstalling design-farmer skill%b\n\n" "$BOLD" "$RESET"

if [ "$INTERACTIVE" -eq 1 ]; then
  select_interactively
elif [ "${#REQUESTED_TOOLS[@]}" -gt 0 ]; then
  for tool in "${REQUESTED_TOOLS[@]}"; do
    if ! is_supported_tool "$tool"; then
      printf "%bError:%b unsupported tool '%s'.\n" "$RED" "$RESET" "$tool" >&2
      print_usage >&2
      exit 1
    fi
    append_unique_tool "$tool"
  done
elif [ "$USE_ALL" -eq 1 ] || [ "${#REQUESTED_TOOLS[@]}" -eq 0 ]; then
  SELECTED=("${DETECTED[@]}")
fi

if [ "$DRY_RUN" -eq 1 ] && [ "${#REQUESTED_TOOLS[@]}" -eq 0 ] && [ "$INTERACTIVE" -eq 0 ] && [ "${#SELECTED[@]}" -eq 0 ]; then
  printf "%bDry run%b — no files will be written.\n\n" "$BOLD" "$RESET"
  printf "No supported tools detected. Nothing to install.\n"
  printf "%bDone (dry run).%b\n" "$GREEN" "$RESET"
  exit 0
fi

if [ "${#SELECTED[@]}" -eq 0 ]; then
  printf "%bNo supported tools detected.%b\n" "$YELLOW" "$RESET"
  printf "Install one of these first, then run this script again:\n"
  printf "  - Claude Code:  https://claude.ai/code\n"
  printf "  - Codex CLI:    https://github.com/openai/codex\n"
  printf "  - Amp:          https://ampcode.com\n"
  printf "  - Gemini CLI:   https://github.com/google-gemini/gemini-cli\n"
  printf "  - OpenCode:     https://opencode.ai\n"
  exit 1
fi

if [ "$DRY_RUN" -eq 0 ]; then
  require_command curl
fi

if [ "$DRY_RUN" -eq 1 ]; then
  printf "%bDry run%b — no files will be written.\n\n" "$BOLD" "$RESET"
fi

printf "Selected targets:\n"
for tool in "${SELECTED[@]}"; do
  target_dir="$(tool_skill_dir "$tool")"
  marker="$(tool_marker "$tool")"
  status="detected"
  if [ ! -d "$marker" ]; then
    status="not detected"
  fi
  printf "  - %s (%s) -> %s\n" "$(tool_label "$tool")" "$status" "$target_dir"
done
printf "\n"

if [ "$DRY_RUN" -eq 1 ]; then
  printf "%bDone (dry run).%b\n" "$GREEN" "$RESET"
  exit 0
fi

FAILED=0

for tool in "${SELECTED[@]}"; do
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
