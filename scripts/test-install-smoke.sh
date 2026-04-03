#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$ROOT_DIR/install.sh"
BASH_BIN="$(command -v bash)"

if [[ ! -f "$INSTALLER" ]]; then
  echo "ERROR: Missing installer script: $INSTALLER"
  exit 1
fi

tool_marker_path() {
  case "$1" in
    claude) echo "$2/.claude" ;;
    codex) echo "$2/.agents" ;;
    amp) echo "$2/.config/agents" ;;
    gemini) echo "$2/.gemini" ;;
    opencode) echo "$2/.config/opencode" ;;
    *)
      echo "ERROR: Unknown tool '$1'" >&2
      exit 1
      ;;
  esac
}

installed_skill_file_path() {
  case "$1" in
    claude) echo "$2/.claude/skills/design-farmer/SKILL.md" ;;
    codex) echo "$2/.agents/skills/design-farmer/SKILL.md" ;;
    amp) echo "$2/.config/agents/skills/design-farmer/SKILL.md" ;;
    gemini) echo "$2/.gemini/skills/design-farmer/SKILL.md" ;;
    opencode) echo "$2/.config/opencode/skills/design-farmer/SKILL.md" ;;
    *)
      echo "ERROR: Unknown tool '$1'" >&2
      exit 1
      ;;
  esac
}

installed_skill_dir_path() {
  case "$1" in
    claude) echo "$2/.claude/skills/design-farmer" ;;
    codex) echo "$2/.agents/skills/design-farmer" ;;
    amp) echo "$2/.config/agents/skills/design-farmer" ;;
    gemini) echo "$2/.gemini/skills/design-farmer" ;;
    opencode) echo "$2/.config/opencode/skills/design-farmer" ;;
    *)
      echo "ERROR: Unknown tool '$1'" >&2
      exit 1
      ;;
  esac
}

assert_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq "$expected" "$file"; then
    echo "ERROR: Expected '$expected' in $file"
    echo "----- $file -----"
    cat "$file"
    echo "-----------------"
    exit 1
  fi
}

write_curl_stub() {
  local stub_bin="$1"
  mkdir -p "$stub_bin"
  cat >"$stub_bin/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

output_file=""
url=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o)
      output_file="$2"
      shift 2
      ;;
    -f|-s|-S|-L|-fsSL)
      shift
      ;;
    *)
      if [[ "$1" != -* ]]; then
        url="$1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$output_file" ]]; then
  echo "missing -o argument" >&2
  exit 2
fi

mkdir -p "$(dirname "$output_file")"

if [[ -n "${SMOKE_CURL_FAIL_MATCH:-}" ]] && [[ "$url" == *"${SMOKE_CURL_FAIL_MATCH}" ]]; then
  exit 22
fi

printf "stub skill content\n" >"$output_file"

if [[ -n "${SMOKE_CURL_LOG:-}" ]]; then
  printf "%s\n" "$url" >>"$SMOKE_CURL_LOG"
fi
EOF
  chmod +x "$stub_bin/curl"
}

test_successful_install_for_tool() {
  local tool="$1"
  local branch="$2"
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  local log_file="$temp_dir/curl-urls.log"

  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "$tool" "$fake_home")"
  write_curl_stub "$fake_bin"

  local stdout_file="$temp_dir/stdout.log"
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" SMOKE_CURL_LOG="$log_file" BRANCH="$branch" \
    "$BASH_BIN" "$INSTALLER" >"$stdout_file" 2>&1

  local installed_file
  installed_file="$(installed_skill_file_path "$tool" "$fake_home")"
  local installed_dir
  installed_dir="$(installed_skill_dir_path "$tool" "$fake_home")"

  if [[ ! -f "$installed_file" ]]; then
    echo "ERROR: Expected installed file not found: $installed_file"
    echo "----- installer output -----"
    cat "$stdout_file"
    echo "----------------------------"
    exit 1
  fi

  assert_contains "$installed_file" "stub skill content"
  assert_contains "$installed_dir/phases/phase-0-preflight.md" "stub skill content"
  assert_contains "$installed_dir/phases/phase-11-readiness-handoff.md" "stub skill content"
  assert_contains "$installed_dir/docs/PHASE-INDEX.md" "stub skill content"
  assert_contains "$stdout_file" "Done!"
  assert_contains "$log_file" "https://raw.githubusercontent.com/ohprettyhak/design-farmer/${branch}/skills/design-farmer/SKILL.md"
  assert_contains "$log_file" "https://raw.githubusercontent.com/ohprettyhak/design-farmer/${branch}/skills/design-farmer/phases/phase-0-preflight.md"
  assert_contains "$log_file" "https://raw.githubusercontent.com/ohprettyhak/design-farmer/${branch}/skills/design-farmer/phases/phase-11-readiness-handoff.md"
  assert_contains "$log_file" "https://raw.githubusercontent.com/ohprettyhak/design-farmer/${branch}/skills/design-farmer/docs/PHASE-INDEX.md"

  rm -rf "$temp_dir"
  trap - RETURN
}

test_no_supported_tools_fails() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"
  write_curl_stub "$fake_bin"

  local output_file="$temp_dir/output.log"
  set +e
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" "$BASH_BIN" "$INSTALLER" >"$output_file" 2>&1
  local exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    echo "ERROR: Installer should fail when no supported tool markers exist"
    cat "$output_file"
    exit 1
  fi

  assert_contains "$output_file" "No supported tools detected."

  rm -rf "$temp_dir"
  trap - RETURN
}

test_missing_curl_fails() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local path_without_curl="$temp_dir/no-curl-bin"
  mkdir -p "$fake_home"
  mkdir -p "$path_without_curl"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"

  local output_file="$temp_dir/output.log"
  set +e
  HOME="$fake_home" PATH="$path_without_curl" "$BASH_BIN" "$INSTALLER" >"$output_file" 2>&1
  local exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    echo "ERROR: Installer should fail when curl is unavailable"
    cat "$output_file"
    exit 1
  fi

  assert_contains "$output_file" "required command not found: curl"

  rm -rf "$temp_dir"
  trap - RETURN
}

test_atomic_install_preserves_existing_on_download_failure() {
  local tool="claude"
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "$tool" "$fake_home")"
  write_curl_stub "$fake_bin"

  local skill_dir
  skill_dir="$(installed_skill_dir_path "$tool" "$fake_home")"
  mkdir -p "$skill_dir/phases"
  mkdir -p "$skill_dir/docs"
  printf "existing root\n" >"$skill_dir/SKILL.md"
  printf "existing p0\n" >"$skill_dir/phases/phase-0-preflight.md"
  printf "existing p11\n" >"$skill_dir/phases/phase-11-readiness-handoff.md"
  printf "existing index\n" >"$skill_dir/docs/PHASE-INDEX.md"

  local output_file="$temp_dir/output.log"
  set +e
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" SMOKE_CURL_FAIL_MATCH="phase-4-architecture.md" BRANCH="smoke-test-branch" \
    "$BASH_BIN" "$INSTALLER" >"$output_file" 2>&1
  local exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    echo "ERROR: Installer should fail when one bundle file download fails"
    cat "$output_file"
    exit 1
  fi

  assert_contains "$output_file" "bundle install failed; rollback attempted"
  assert_contains "$output_file" "Completed with errors."
  assert_contains "$skill_dir/SKILL.md" "existing root"
  assert_contains "$skill_dir/phases/phase-0-preflight.md" "existing p0"
  assert_contains "$skill_dir/phases/phase-11-readiness-handoff.md" "existing p11"
  assert_contains "$skill_dir/docs/PHASE-INDEX.md" "existing index"

  rm -rf "$temp_dir"
  trap - RETURN
}

main() {
  local tool="${1:-}"
  if [[ -z "$tool" ]]; then
    echo "Usage: $0 <tool>"
    echo "Valid tools: claude codex amp gemini opencode"
    exit 1
  fi

  local smoke_branch="smoke-test-branch"

  echo "[smoke] success path for tool: $tool"
  test_successful_install_for_tool "$tool" "$smoke_branch"

  echo "[smoke] failure path: no supported tools"
  test_no_supported_tools_fails

  echo "[smoke] failure path: missing curl prerequisite"
  test_missing_curl_fails

  echo "[smoke] failure path: download error preserves existing bundle"
  test_atomic_install_preserves_existing_on_download_failure

  echo "All installer smoke tests passed for tool=$tool"
}

main "$@"
