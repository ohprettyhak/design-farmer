#!/usr/bin/env bash
# Run all Design Farmer skill bundle tests.
#
# Test suites:
#   1. Structural validation (scripts/validate-skill-md.sh)
#      - Phase file existence, router references, orphan detection
#      - Completion status protocol, cross-phase contracts
#      - Discovery interview gating, tool-contract keywords
#
#   2. Semantic consistency (tests/test-semantic-consistency.sh)
#      - Cross-reference section number accuracy
#      - Config field coverage (Phase 0 re-entry vs DESIGN.md template)
#      - Phase flow sequence order
#      - Status message completeness and handoff chain
#      - Docs alignment (PHASE-INDEX, MAINTENANCE, QUALITY-GATES)
#      - Phase 0 re-entry paths, conditional question gates
#      - Phase 4b light-only guard, Phase 6 non-React guardrail
#      - Cross-phase data dependencies, pipeline state tracking
#      - Fix Loop Protocol coverage
#
#   3. version-check behavior (tests/test-version-check.sh)
#      - Releases API primary path (UPGRADE_AVAILABLE / OK)
#      - Fallback to SKILL.md on main when Releases API is unreachable
#      - Silent exit when both upstream sources fail
#
# Usage: bash skills/design-farmer/tests/run-all.sh

set -eo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================="
echo " Design Farmer Skill Bundle — Full Test Suite"
echo "============================================="
echo ""

SUITE_FAIL=0

echo "── Suite 1: Structural Validation ──"
echo ""
if bash "$ROOT_DIR/scripts/validate-skill-md.sh"; then
  echo ""
  echo "Suite 1: PASSED"
else
  echo ""
  echo "Suite 1: FAILED"
  SUITE_FAIL=1
fi

echo ""
echo "── Suite 2: Semantic Consistency ──"
echo ""
if bash "$TESTS_DIR/test-semantic-consistency.sh"; then
  echo ""
  echo "Suite 2: PASSED"
else
  echo ""
  echo "Suite 2: FAILED"
  SUITE_FAIL=1
fi

echo ""
echo "── Suite 3: version-check Behavior ──"
echo ""
if bash "$TESTS_DIR/test-version-check.sh"; then
  echo ""
  echo "Suite 3: PASSED"
else
  echo ""
  echo "Suite 3: FAILED"
  SUITE_FAIL=1
fi

echo ""
echo "============================================="
if [ $SUITE_FAIL -eq 0 ]; then
  echo " ALL SUITES PASSED"
else
  echo " SOME SUITES FAILED"
  exit 1
fi
echo "============================================="
