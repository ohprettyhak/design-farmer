#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$ROOT_DIR/install.sh"
UNINSTALLER="$ROOT_DIR/uninstall.sh"
BASH_BIN="$(command -v bash)"

if [[ ! -f "$INSTALLER" ]]; then
  echo "ERROR: Missing installer script: $INSTALLER"
  exit 1
fi

if [[ ! -f "$UNINSTALLER" ]]; then
  echo "ERROR: Missing uninstaller script: $UNINSTALLER"
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
  if ! grep -Fq -- "$expected" "$file"; then
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

test_selective_tool_install_only_writes_requested_target() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"
  mkdir -p "$(tool_marker_path "codex" "$fake_home")"
  write_curl_stub "$fake_bin"

  local output_file="$temp_dir/output.log"
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" BRANCH="smoke-test-branch" \
    "$BASH_BIN" "$INSTALLER" --tool codex >"$output_file" 2>&1

  local codex_file
  codex_file="$(installed_skill_file_path "codex" "$fake_home")"
  local claude_file
  claude_file="$(installed_skill_file_path "claude" "$fake_home")"

  if [[ ! -f "$codex_file" ]]; then
    echo "ERROR: Expected codex install target was not written"
    cat "$output_file"
    exit 1
  fi

  if [[ -f "$claude_file" ]]; then
    echo "ERROR: Unexpected claude install target was written"
    cat "$output_file"
    exit 1
  fi

  assert_contains "$output_file" "Selected targets:"
  assert_contains "$output_file" "Codex CLI"

  rm -rf "$temp_dir"
  trap - RETURN
}

test_selective_tool_install_deduplicates_requested_targets() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"
  write_curl_stub "$fake_bin"

  local output_file="$temp_dir/output.log"
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" BRANCH="smoke-test-branch" \
    "$BASH_BIN" "$INSTALLER" --tool claude --tool claude >"$output_file" 2>&1

  local claude_file
  claude_file="$(installed_skill_file_path "claude" "$fake_home")"

  if [[ ! -f "$claude_file" ]]; then
    echo "ERROR: Expected claude install target was not written"
    cat "$output_file"
    exit 1
  fi

  local target_line_count
  target_line_count="$(grep -Ec '^  - Claude Code \(' "$output_file")"
  if [[ "$target_line_count" -ne 1 ]]; then
    echo "ERROR: Expected Claude Code to appear exactly once in installer output"
    cat "$output_file"
    exit 1
  fi

  rm -rf "$temp_dir"
  trap - RETURN
}

test_dry_run_does_not_write_files() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"

  local output_file="$temp_dir/output.log"
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" \
    "$BASH_BIN" "$INSTALLER" --tool claude --dry-run >"$output_file" 2>&1

  local claude_dir
  claude_dir="$(installed_skill_dir_path "claude" "$fake_home")"
  if [[ -d "$claude_dir" ]]; then
    echo "ERROR: dry-run should not create skill directory"
    cat "$output_file"
    exit 1
  fi

  assert_contains "$output_file" "Dry run"
  assert_contains "$output_file" "Done (dry run)."

  rm -rf "$temp_dir"
  trap - RETURN
}

test_dry_run_without_detected_tools_succeeds() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"

  local output_file="$temp_dir/output.log"
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" \
    "$BASH_BIN" "$INSTALLER" --dry-run >"$output_file" 2>&1

  assert_contains "$output_file" "No supported tools detected. Nothing to install."
  assert_contains "$output_file" "Done (dry run)."

  rm -rf "$temp_dir"
  trap - RETURN
}

test_list_tools_reports_status_and_exits() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"

  local output_file="$temp_dir/output.log"
  HOME="$fake_home" PATH="/usr/bin:/bin" \
    "$BASH_BIN" "$INSTALLER" --list-tools >"$output_file" 2>&1

  assert_contains "$output_file" "Supported tools"
  assert_contains "$output_file" "claude"
  assert_contains "$output_file" "[detected]"
  assert_contains "$output_file" "codex"

  rm -rf "$temp_dir"
  trap - RETURN
}

test_conflicting_flags_fail() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"

  local output_file="$temp_dir/output.log"
  set +e
  HOME="$fake_home" PATH="/usr/bin:/bin" \
    "$BASH_BIN" "$INSTALLER" --all --tool claude >"$output_file" 2>&1
  local exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    echo "ERROR: Installer should fail for conflicting flags"
    cat "$output_file"
    exit 1
  fi

  assert_contains "$output_file" "--all cannot be combined with --tool"

  rm -rf "$temp_dir"
  trap - RETURN
}

test_interactive_requires_terminal() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"

  local output_file="$temp_dir/output.log"
  set +e
  HOME="$fake_home" PATH="/usr/bin:/bin" \
    "$BASH_BIN" "$INSTALLER" --interactive >"$output_file" 2>&1
  local exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    echo "ERROR: Installer should fail for --interactive without TTY"
    cat "$output_file"
    exit 1
  fi

  assert_contains "$output_file" "--interactive requires an interactive terminal"

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

test_uninstall_removes_only_requested_target() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"
  mkdir -p "$(tool_marker_path "codex" "$fake_home")"
  write_curl_stub "$fake_bin"

  local install_output="$temp_dir/install.log"
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" BRANCH="smoke-test-branch" \
    "$BASH_BIN" "$INSTALLER" --tool claude --tool codex >"$install_output" 2>&1

  local claude_dir
  claude_dir="$(installed_skill_dir_path "claude" "$fake_home")"
  local codex_dir
  codex_dir="$(installed_skill_dir_path "codex" "$fake_home")"

  if [[ ! -d "$claude_dir" ]] || [[ ! -d "$codex_dir" ]]; then
    echo "ERROR: Expected both claude and codex bundles to be installed before uninstall"
    cat "$install_output"
    exit 1
  fi

  local uninstall_output="$temp_dir/uninstall.log"
  HOME="$fake_home" PATH="/usr/bin:/bin" \
    "$BASH_BIN" "$UNINSTALLER" --tool codex >"$uninstall_output" 2>&1

  if [[ ! -d "$claude_dir" ]]; then
    echo "ERROR: Uninstall removed unrequested claude target"
    cat "$uninstall_output"
    exit 1
  fi

  if [[ -d "$codex_dir" ]]; then
    echo "ERROR: Uninstall did not remove requested codex target"
    cat "$uninstall_output"
    exit 1
  fi

  assert_contains "$uninstall_output" "Selected targets:"
  assert_contains "$uninstall_output" "Codex CLI"
  assert_contains "$uninstall_output" "Done!"

  rm -rf "$temp_dir"
  trap - RETURN
}

test_uninstall_deduplicates_requested_targets() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"
  mkdir -p "$(installed_skill_dir_path "claude" "$fake_home")"
  printf "installed\n" >"$(installed_skill_file_path "claude" "$fake_home")"

  local output_file="$temp_dir/output.log"
  HOME="$fake_home" PATH="/usr/bin:/bin" \
    "$BASH_BIN" "$UNINSTALLER" --tool claude --tool claude >"$output_file" 2>&1

  local claude_dir
  claude_dir="$(installed_skill_dir_path "claude" "$fake_home")"
  if [[ -d "$claude_dir" ]]; then
    echo "ERROR: Expected claude uninstall target was not removed"
    cat "$output_file"
    exit 1
  fi

  local target_line_count
  target_line_count="$(grep -Ec '^  - Claude Code \(' "$output_file")"
  if [[ "$target_line_count" -ne 1 ]]; then
    echo "ERROR: Expected Claude Code to appear exactly once in uninstaller output"
    cat "$output_file"
    exit 1
  fi

  rm -rf "$temp_dir"
  trap - RETURN
}

test_uninstall_dry_run_does_not_delete_files() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"
  write_curl_stub "$fake_bin"

  local install_output="$temp_dir/install.log"
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" BRANCH="smoke-test-branch" \
    "$BASH_BIN" "$INSTALLER" --tool claude >"$install_output" 2>&1

  local claude_dir
  claude_dir="$(installed_skill_dir_path "claude" "$fake_home")"
  if [[ ! -d "$claude_dir" ]]; then
    echo "ERROR: Precondition failed; claude install target missing"
    cat "$install_output"
    exit 1
  fi

  local uninstall_output="$temp_dir/uninstall.log"
  HOME="$fake_home" PATH="/usr/bin:/bin" \
    "$BASH_BIN" "$UNINSTALLER" --tool claude --dry-run >"$uninstall_output" 2>&1

  if [[ ! -d "$claude_dir" ]]; then
    echo "ERROR: uninstall dry-run should not delete installed target"
    cat "$uninstall_output"
    exit 1
  fi

  assert_contains "$uninstall_output" "Dry run"
  assert_contains "$uninstall_output" "Done (dry run)."

  rm -rf "$temp_dir"
  trap - RETURN
}

test_uninstall_absent_target_is_noop_success() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"

  local output_file="$temp_dir/uninstall.log"
  HOME="$fake_home" PATH="/usr/bin:/bin" \
    "$BASH_BIN" "$UNINSTALLER" --tool claude >"$output_file" 2>&1

  assert_contains "$output_file" "already absent"
  assert_contains "$output_file" "Done!"

  rm -rf "$temp_dir"
  trap - RETURN
}

test_uninstall_no_detected_tools_is_noop_success() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  mkdir -p "$fake_home"

  local output_file="$temp_dir/uninstall.log"
  HOME="$fake_home" PATH="/usr/bin:/bin" \
    "$BASH_BIN" "$UNINSTALLER" >"$output_file" 2>&1

  assert_contains "$output_file" "No supported tools detected. Nothing to uninstall."

  rm -rf "$temp_dir"
  trap - RETURN
}

test_uninstall_conflicting_flags_fail() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"

  local output_file="$temp_dir/output.log"
  set +e
  HOME="$fake_home" PATH="/usr/bin:/bin" \
    "$BASH_BIN" "$UNINSTALLER" --all --tool claude >"$output_file" 2>&1
  local exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    echo "ERROR: Uninstaller should fail for conflicting flags"
    cat "$output_file"
    exit 1
  fi

  assert_contains "$output_file" "--all cannot be combined with --tool"

  rm -rf "$temp_dir"
  trap - RETURN
}

test_uninstall_interactive_requires_terminal() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"

  local output_file="$temp_dir/output.log"
  set +e
  HOME="$fake_home" PATH="/usr/bin:/bin" \
    "$BASH_BIN" "$UNINSTALLER" --interactive >"$output_file" 2>&1
  local exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    echo "ERROR: Uninstaller should fail for --interactive without TTY"
    cat "$output_file"
    exit 1
  fi

  assert_contains "$output_file" "--interactive requires an interactive terminal"

  rm -rf "$temp_dir"
  trap - RETURN
}

make_fake_marketplace_cache() {
  local fake_home="$1"
  # Mirror the actual Claude Code marketplace cache layout:
  # $HOME/.claude/plugins/cache/<marketplace>/<plugin>/<version>/<plugin>
  local cache_path="$fake_home/.claude/plugins/cache/design-farmer/design-farmer/9.9.9/design-farmer"
  mkdir -p "$cache_path"
  printf "fake marketplace copy\n" >"$cache_path/SKILL.md"
}

test_install_warns_on_marketplace_cache_collision_for_claude() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"
  write_curl_stub "$fake_bin"
  make_fake_marketplace_cache "$fake_home"

  local output_file="$temp_dir/output.log"
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" BRANCH="smoke-test-branch" \
    "$BASH_BIN" "$INSTALLER" --tool claude >"$output_file" 2>&1

  assert_contains "$output_file" "Claude Code marketplace install of design-farmer was detected"
  assert_contains "$output_file" "marketplace cache :"
  assert_contains "$output_file" "curl install path :"
  assert_contains "$output_file" "install from"
  assert_contains "$output_file" "Done!"

  local claude_file
  claude_file="$(installed_skill_file_path "claude" "$fake_home")"
  if [[ ! -f "$claude_file" ]]; then
    echo "ERROR: Install should still succeed alongside the warning"
    cat "$output_file"
    exit 1
  fi

  rm -rf "$temp_dir"
  trap - RETURN
}

test_install_does_not_warn_without_marketplace_cache() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"
  write_curl_stub "$fake_bin"

  local output_file="$temp_dir/output.log"
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" BRANCH="smoke-test-branch" \
    "$BASH_BIN" "$INSTALLER" --tool claude >"$output_file" 2>&1

  if grep -Fq "Claude Code marketplace install of design-farmer was detected" "$output_file"; then
    echo "ERROR: Marketplace collision warning fired without any cache present"
    cat "$output_file"
    exit 1
  fi

  assert_contains "$output_file" "Done!"

  rm -rf "$temp_dir"
  trap - RETURN
}

test_install_does_not_warn_for_non_claude_target() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "codex" "$fake_home")"
  write_curl_stub "$fake_bin"
  # Cache is present, but claude is not a selected target — the warning
  # should not fire because the user is only installing for codex.
  make_fake_marketplace_cache "$fake_home"

  local output_file="$temp_dir/output.log"
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" BRANCH="smoke-test-branch" \
    "$BASH_BIN" "$INSTALLER" --tool codex >"$output_file" 2>&1

  if grep -Fq "Claude Code marketplace install of design-farmer was detected" "$output_file"; then
    echo "ERROR: Marketplace collision warning fired for non-claude target"
    cat "$output_file"
    exit 1
  fi

  rm -rf "$temp_dir"
  trap - RETURN
}

test_uninstall_warns_on_marketplace_cache_collision_for_claude() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  local fake_home="$temp_dir/home"
  local fake_bin="$temp_dir/bin"
  mkdir -p "$fake_home"
  mkdir -p "$(tool_marker_path "claude" "$fake_home")"
  write_curl_stub "$fake_bin"

  # Install the curl copy first, then seed the marketplace cache so the
  # uninstaller sees the collision when it runs.
  local install_output="$temp_dir/install.log"
  HOME="$fake_home" PATH="$fake_bin:/usr/bin:/bin" BRANCH="smoke-test-branch" \
    "$BASH_BIN" "$INSTALLER" --tool claude >"$install_output" 2>&1

  make_fake_marketplace_cache "$fake_home"

  local uninstall_output="$temp_dir/uninstall.log"
  HOME="$fake_home" PATH="/usr/bin:/bin" \
    "$BASH_BIN" "$UNINSTALLER" --tool claude >"$uninstall_output" 2>&1

  assert_contains "$uninstall_output" "Claude Code marketplace install of design-farmer was detected"
  assert_contains "$uninstall_output" "removes ONLY the curl-installed copy"
  assert_contains "$uninstall_output" "Done!"

  local claude_dir
  claude_dir="$(installed_skill_dir_path "claude" "$fake_home")"
  if [[ -d "$claude_dir" ]]; then
    echo "ERROR: Curl install should be removed by uninstall even with warning"
    cat "$uninstall_output"
    exit 1
  fi

  local cache_dir
  cache_dir="$fake_home/.claude/plugins/cache/design-farmer/design-farmer/9.9.9/design-farmer"
  if [[ ! -d "$cache_dir" ]]; then
    echo "ERROR: Uninstaller must not touch the marketplace cache"
    cat "$uninstall_output"
    exit 1
  fi

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

  echo "[smoke] selective path: --tool installs only requested target"
  test_selective_tool_install_only_writes_requested_target

  echo "[smoke] selective path: duplicate --tool arguments stay deduplicated"
  test_selective_tool_install_deduplicates_requested_targets

  echo "[smoke] dry-run path: no files are written"
  test_dry_run_does_not_write_files

  echo "[smoke] dry-run path: no detected tools still succeeds"
  test_dry_run_without_detected_tools_succeeds

  echo "[smoke] info path: --list-tools reports statuses"
  test_list_tools_reports_status_and_exits

  echo "[smoke] parser path: conflicting flags fail"
  test_conflicting_flags_fail

  echo "[smoke] interactive path: requires terminal in CI"
  test_interactive_requires_terminal

  echo "[smoke] failure path: no supported tools"
  test_no_supported_tools_fails

  echo "[smoke] failure path: missing curl prerequisite"
  test_missing_curl_fails

  echo "[smoke] failure path: download error preserves existing bundle"
  test_atomic_install_preserves_existing_on_download_failure

  echo "[smoke] uninstall path: --tool removes only requested target"
  test_uninstall_removes_only_requested_target

  echo "[smoke] uninstall path: duplicate --tool arguments stay deduplicated"
  test_uninstall_deduplicates_requested_targets

  echo "[smoke] uninstall path: --dry-run does not delete files"
  test_uninstall_dry_run_does_not_delete_files

  echo "[smoke] uninstall path: absent target is noop success"
  test_uninstall_absent_target_is_noop_success

  echo "[smoke] uninstall path: no detected tools is noop success"
  test_uninstall_no_detected_tools_is_noop_success

  echo "[smoke] uninstall parser path: conflicting flags fail"
  test_uninstall_conflicting_flags_fail

  echo "[smoke] uninstall interactive path: requires terminal in CI"
  test_uninstall_interactive_requires_terminal

  echo "[smoke] install path: warns on marketplace cache collision for claude"
  test_install_warns_on_marketplace_cache_collision_for_claude

  echo "[smoke] install path: silent when no marketplace cache is present"
  test_install_does_not_warn_without_marketplace_cache

  echo "[smoke] install path: silent when marketplace cache exists but claude is not targeted"
  test_install_does_not_warn_for_non_claude_target

  echo "[smoke] uninstall path: warns on marketplace cache collision for claude"
  test_uninstall_warns_on_marketplace_cache_collision_for_claude

  echo "All install/uninstall smoke tests passed for tool=$tool"
}

main "$@"
