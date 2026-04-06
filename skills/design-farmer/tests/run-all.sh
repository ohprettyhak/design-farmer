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
#
#   3. Exhaustive simulation (tests/test-exhaustive-simulation.sh)
#      - All execution path combinations (1152 paths)
#      - Conditional question flows, maturity branches
#      - Framework guardrails, skip/jump path validity
#      - Cross-phase data dependency chain integrity
#      - Fallback registry, Fix Loop activation, risk regulation
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
echo "── Suite 3: Exhaustive Simulation ──"
echo ""
if bash "$TESTS_DIR/test-exhaustive-simulation.sh"; then
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
