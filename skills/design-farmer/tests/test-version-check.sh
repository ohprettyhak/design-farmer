#!/usr/bin/env bash
# Behavioral smoke tests for bin/version-check.
#
# Covers:
#   - Primary path (Releases API) reports UPGRADE_AVAILABLE for a newer tag
#   - Primary path returns OK when the tag matches the local version
#   - Primary path returns OK when the local version is ahead of the tag
#   - Malformed / empty Releases API response falls back to main SKILL.md
#   - Both sources unreachable exits silently
#
# Usage: bash skills/design-farmer/tests/test-version-check.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
REAL_SCRIPT="${REPO_ROOT}/skills/design-farmer/bin/version-check"

if [[ ! -x "$REAL_SCRIPT" ]]; then
  echo "version-check script missing or not executable at $REAL_SCRIPT" >&2
  exit 1
fi

PASS=0
FAIL=0
FAILED_TESTS=()

setup_sandbox() {
  SANDBOX=$(mktemp -d)
  # Fake skill bundle layout
  mkdir -p "${SANDBOX}/skill/bin" "${SANDBOX}/home"
  cp "$REAL_SCRIPT" "${SANDBOX}/skill/bin/version-check"
  chmod +x "${SANDBOX}/skill/bin/version-check"
  cat > "${SANDBOX}/skill/SKILL.md" <<'SKILL_EOF'
---
name: design-farmer
version: 0.0.6
description: test skill
---

# Test skill
SKILL_EOF
  export HOME="${SANDBOX}/home"
}

teardown_sandbox() {
  if [[ -n "${SANDBOX:-}" ]] && [[ -d "$SANDBOX" ]]; then
    rm -rf "$SANDBOX"
  fi
  unset SANDBOX
}

run_check() {
  # Run the sandboxed copy of version-check, isolating HOME and passing URL
  # overrides. Returns stdout so tests can assert on format.
  "${SANDBOX}/skill/bin/version-check" 2>/dev/null || true
}

assert_output() {
  local label=$1
  local expected=$2
  local actual=$3
  if [[ "$actual" == "$expected" ]]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label"
    echo "    expected: '$expected'"
    echo "    got:      '$actual'"
    FAIL=$((FAIL + 1))
    FAILED_TESTS+=("$label")
  fi
}

echo "=== version-check behavioral tests ==="
echo ""

# Test 1: Primary path, newer release tag → UPGRADE_AVAILABLE
echo "Test 1: Primary path reports UPGRADE_AVAILABLE for a newer tag"
setup_sandbox
cat > "${SANDBOX}/release.json" <<'EOF'
{"tag_name":"v9.9.9","name":"Release 9.9.9","draft":false,"prerelease":false}
EOF
out=$(DF_RELEASES_API_URL="file://${SANDBOX}/release.json" DF_FALLBACK_RAW_URL="file://${SANDBOX}/does-not-exist" run_check)
assert_output "primary newer tag → UPGRADE_AVAILABLE 0.0.6 9.9.9" "UPGRADE_AVAILABLE 0.0.6 9.9.9" "$out"
teardown_sandbox

# Test 2: Primary path, tag equals local → silent OK
echo "Test 2: Primary path is silent when tag matches local version"
setup_sandbox
cat > "${SANDBOX}/release.json" <<'EOF'
{"tag_name":"v0.0.6","name":"Release 0.0.6"}
EOF
out=$(DF_RELEASES_API_URL="file://${SANDBOX}/release.json" DF_FALLBACK_RAW_URL="file://${SANDBOX}/does-not-exist" run_check)
assert_output "primary equal tag → silent" "" "$out"
teardown_sandbox

# Test 3: Primary path, tag older than local → silent OK
echo "Test 3: Primary path is silent when local is ahead of the released tag"
setup_sandbox
cat > "${SANDBOX}/release.json" <<'EOF'
{"tag_name":"v0.0.1","name":"Release 0.0.1"}
EOF
out=$(DF_RELEASES_API_URL="file://${SANDBOX}/release.json" DF_FALLBACK_RAW_URL="file://${SANDBOX}/does-not-exist" run_check)
assert_output "primary older tag → silent" "" "$out"
teardown_sandbox

# Test 4: Malformed Releases API response falls back to main SKILL.md
echo "Test 4: Malformed Releases API response falls back to main SKILL.md"
setup_sandbox
printf '%s\n' '<html>403 rate-limited</html>' > "${SANDBOX}/release.json"
cat > "${SANDBOX}/main-skill.md" <<'EOF'
---
name: design-farmer
version: 9.9.9
description: main ahead of tag
---
EOF
out=$(DF_RELEASES_API_URL="file://${SANDBOX}/release.json" DF_FALLBACK_RAW_URL="file://${SANDBOX}/main-skill.md" run_check)
assert_output "malformed API → fallback to main → UPGRADE_AVAILABLE 0.0.6 9.9.9" "UPGRADE_AVAILABLE 0.0.6 9.9.9" "$out"
teardown_sandbox

# Test 5: Both sources unreachable → silent exit
echo "Test 5: Both sources unreachable exits silently"
setup_sandbox
out=$(DF_RELEASES_API_URL="file://${SANDBOX}/missing-a" DF_FALLBACK_RAW_URL="file://${SANDBOX}/missing-b" run_check)
assert_output "both missing → silent" "" "$out"
teardown_sandbox

echo ""
echo "==========================================="
echo "RESULTS: ${PASS} passed, ${FAIL} failed"
echo "==========================================="

if (( FAIL > 0 )); then
  echo "Failed tests:"
  for name in "${FAILED_TESTS[@]}"; do
    echo "  - $name"
  done
  exit 1
fi

exit 0
