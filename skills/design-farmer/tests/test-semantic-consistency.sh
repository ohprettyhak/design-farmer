#!/usr/bin/env bash
# Semantic consistency tests for the Design Farmer skill bundle.
# These complement scripts/validate-skill-md.sh (structural checks) with
# deeper content-level validation: cross-references, config coverage,
# phase flow, and status messages.
#
# Compatible with bash 3.2+ (macOS default).
#
# Usage: bash skills/design-farmer/tests/test-semantic-consistency.sh

set -eo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SKILL_DIR="$ROOT_DIR/skills/design-farmer"
PHASES_DIR="$SKILL_DIR/phases"
DOCS_DIR="$SKILL_DIR/docs"
EXAMPLES_DIR="$SKILL_DIR/examples"
SKILL_FILE="$SKILL_DIR/SKILL.md"

PASS=0
FAIL=0
WARN=0

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }
warn() { WARN=$((WARN + 1)); echo "  ⚠ $1"; }

# ---------------------------------------------------------------------------
# TEST 1: Cross-Reference Section Number Validation
# Verifies that handoff messages reference section numbers that exist in target files.
# ---------------------------------------------------------------------------
echo "=== TEST 1: Cross-Reference Section Numbers ==="

# Phase 4 → Phase 4b handoff
handoff_line=$(grep -n "Continue in.*phase-4b" "$PHASES_DIR/phase-4-architecture.md" || true)
if [ -n "$handoff_line" ]; then
  # Extract referenced section numbers (e.g., 4b.1, 4b.2, ...)
  referenced_sections=$(echo "$handoff_line" | grep -oE '\(4b\.[0-9]+\)' | tr -d '()' || true)
  if [ -z "$referenced_sections" ]; then
    fail "Phase 4 handoff references non-4b section numbers (possible stale reference to old numbering)"
  else
    all_match=true
    section_fail_marker=$(mktemp "${TMPDIR:-/tmp}/df_test_section_XXXXXX")
    rm -f "$section_fail_marker"
    echo "$referenced_sections" | while IFS= read -r section; do
      if ! grep -qE "^## $section " "$PHASES_DIR/phase-4b-theming.md"; then
        echo "  ✗ Phase 4 handoff references §$section but it doesn't exist in phase-4b-theming.md"
        touch "$section_fail_marker"
      fi
    done
    if [ -f "$section_fail_marker" ]; then
      rm -f "$section_fail_marker"
      FAIL=$((FAIL + 1))
    else
      pass "Phase 4 → 4b handoff section numbers all valid"
    fi
  fi
else
  fail "No Phase 4 → 4b handoff found in phase-4-architecture.md"
fi

# Phase 4b status → Phase 4.5 handoff
if grep -q "Proceed to Phase 4.5" "$PHASES_DIR/phase-4b-theming.md"; then
  pass "Phase 4b status correctly points to Phase 4.5"
else
  fail "Phase 4b status doesn't mention Phase 4.5 as next step"
fi

# Verify no stale "(4.5)" that could be confused with Phase 4.5 in the handoff line
if echo "$handoff_line" | grep -qE '\(4\.5\)'; then
  fail "Phase 4 handoff contains '(4.5)' — ambiguous with Phase 4.5 (DESIGN.md)"
else
  pass "No ambiguous '(4.5)' in Phase 4 handoff line"
fi

echo ""

# ---------------------------------------------------------------------------
# TEST 2: Config Field Coverage
# Phase 0 re-entry must parse all fields that appear in the DESIGN.md Config template.
# ---------------------------------------------------------------------------
echo "=== TEST 2: Config Field Coverage (Phase 0 Re-Entry) ==="

# Extract fields from Phase 4.5 Config YAML template
template_fields=$(sed -n '/^```yaml/,/^```/p' "$PHASES_DIR/phase-4.5-design-source-of-truth.md" \
  | grep -oE '^[a-zA-Z]+:' | sed 's/://' | sort -u)

# Extract fields mentioned in Phase 0 re-entry parsing list
phase0_section=$(awk '/Parse it to reconstruct/,/^$/' "$PHASES_DIR/phase-0-preflight.md")
phase0_fields=""
for field in $template_fields; do
  if echo "$phase0_section" | grep -qF "$field"; then
    phase0_fields="$phase0_fields $field"
  fi
done

missing_fields=""
for field in $template_fields; do
  if ! echo "$phase0_fields" | grep -qw "$field"; then
    missing_fields="$missing_fields $field"
  fi
done

if [ -z "$missing_fields" ]; then
  field_count=$(echo "$template_fields" | wc -w | tr -d ' ')
  pass "Phase 0 re-entry parses all $field_count Config YAML fields"
else
  fail "Phase 0 re-entry missing fields:$missing_fields"
fi

# Cross-check: DesignFarmerConfig interface in Phase 1 should include all template fields
config_section=$(awk '/interface DesignFarmerConfig/,/^}/' "$PHASES_DIR/phase-1-discovery.md")
missing_in_interface=""
for field in $template_fields; do
  if ! echo "$config_section" | grep -qF "$field"; then
    missing_in_interface="$missing_in_interface $field"
  fi
done

if [ -z "$missing_in_interface" ]; then
  pass "DesignFarmerConfig interface includes all Config YAML fields"
else
  warn "DesignFarmerConfig interface may be missing:$missing_in_interface"
fi

# Cross-check: examples/DESIGN.md Config block uses same fields
if [ -f "$EXAMPLES_DIR/DESIGN.md" ]; then
  example_fields=$(sed -n '/^```yaml/,/^```/p' "$EXAMPLES_DIR/DESIGN.md" \
    | grep -oE '^[a-zA-Z]+:' | sed 's/://' | sort -u)
  template_sorted=$(echo "$template_fields" | tr ' ' '\n' | sort)
  example_sorted=$(echo "$example_fields" | tr ' ' '\n' | sort)
  if [ "$template_sorted" = "$example_sorted" ]; then
    pass "Example DESIGN.md Config fields match Phase 4.5 template exactly"
  else
    warn "Example DESIGN.md Config fields differ from template"
  fi
fi

echo ""

# ---------------------------------------------------------------------------
# TEST 3: Phase Flow Sequence
# The Phase Sequence diagram in SKILL.md must match the actual phase file ordering.
# ---------------------------------------------------------------------------
echo "=== TEST 3: Phase Flow Sequence ==="

# Extract phase sequence from SKILL.md code block diagram
# The diagram is inside ``` block after "### Phase Sequence"
sequence_phases=$(awk '/^### Phase Sequence/{found=1; next} found && /^### /{exit} found' "$SKILL_FILE" \
  | grep -oE 'Phase [0-9]+[a-z]?(\.[0-9]+)?' \
  | sed 's/Phase //' || true)

# Expected canonical order
expected_order="0 1 2 3 3.5 4 4b 4.5 5 6 7 8 8.5 9 10 11"

actual_order=$(echo "$sequence_phases" | tr '\n' ' ' | sed 's/ $//')

if [ "$actual_order" = "$expected_order" ]; then
  pass "Phase Sequence diagram order matches expected: $expected_order"
else
  fail "Phase Sequence order mismatch"
  echo "    Expected: $expected_order"
  echo "    Actual:   $actual_order"
fi

# Verify phase table in SKILL.md has matching entries
table_phases=$(grep -oE '^\| [0-9]+[a-z]?\.?[0-9]* \|' "$SKILL_FILE" \
  | grep -oE '[0-9]+[a-z]?\.?[0-9]*' | tr '\n' ' ' | sed 's/ $//')

if [ "$table_phases" = "$expected_order" ]; then
  pass "Phase table order matches expected sequence"
else
  fail "Phase table order mismatch"
  echo "    Expected: $expected_order"
  echo "    Actual:   $table_phases"
fi

echo ""

# ---------------------------------------------------------------------------
# TEST 4: Status Message Completeness
# Every phase file must end with a **Status: DONE** (or similar) pattern.
# ---------------------------------------------------------------------------
echo "=== TEST 4: Status Message Completeness ==="

for phase_file in "$PHASES_DIR"/phase-*.md; do
  basename_file=$(basename "$phase_file")

  if grep -qE '\*\*Status: (DONE|BLOCKED|DONE_WITH_CONCERNS|NEEDS_CONTEXT)\*\*' "$phase_file"; then
    pass "$basename_file has completion status"
  else
    fail "$basename_file missing completion status pattern"
  fi
done

echo ""

# ---------------------------------------------------------------------------
# TEST 5: Phase Handoff Chain Continuity
# Each phase's status message should reference the correct next phase.
# Uses parallel arrays for bash 3.2 compatibility (no associative arrays).
# ---------------------------------------------------------------------------
echo "=== TEST 5: Phase Handoff Chain ==="

handoff_sources=(
  "phase-0-preflight.md"
  "phase-1-discovery.md"
  "phase-2-repo-analysis.md"
  "phase-3-pattern-extraction.md"
  "phase-3.5-visual-preview.md"
  "phase-4-architecture.md"
  "phase-4b-theming.md"
  "phase-4.5-design-source-of-truth.md"
  "phase-5-tokens.md"
  "phase-6-components.md"
  "phase-7-storybook.md"
  "phase-8-review.md"
  "phase-8.5-design-review.md"
  "phase-9-documentation.md"
  "phase-10-integration.md"
)

handoff_targets=(
  "Phase 1"
  "Phase 2"
  "Phase 3"
  "Phase 3.5"
  "Phase 4"
  "Phase 4b"
  "Phase 4.5"
  "Phase 5"
  "Phase 6"
  "Phase 7"
  "Phase 8"
  "Phase 8.5"
  "Phase 9"
  "Phase 10"
  "Phase 11"
)

i=0
while [ $i -lt ${#handoff_sources[@]} ]; do
  src="${handoff_sources[$i]}"
  expected="${handoff_targets[$i]}"
  full_path="$PHASES_DIR/$src"

  if [ ! -f "$full_path" ]; then
    fail "$src not found"
    i=$((i + 1))
    continue
  fi

  # Check last 5 lines for the next phase reference
  status_area=$(tail -5 "$full_path")

  if echo "$status_area" | grep -qF "$expected"; then
    pass "$src → $expected"
  else
    fail "$src should reference '$expected' in status but doesn't"
  fi

  i=$((i + 1))
done

echo ""

# ---------------------------------------------------------------------------
# TEST 6: SKILL.md Cross-Phase Contracts Accuracy
# Verify specific contract claims against actual phase file contents.
# ---------------------------------------------------------------------------
echo "=== TEST 6: Cross-Phase Contract Claims ==="

# Contract: "Phase 4b is a continuation of Phase 4"
if grep -qF "Phase 4b" "$SKILL_FILE" && grep -qF "continuation of Phase 4" "$SKILL_FILE"; then
  pass "SKILL.md documents Phase 4b as continuation of Phase 4"
else
  fail "SKILL.md missing Phase 4b continuation contract"
fi

# Contract: "DESIGN.md (from Phase 4.5) is the persistent design source of truth for Phases 5-11"
if grep -qF "DESIGN.md" "$SKILL_FILE" && grep -qF "source of truth" "$SKILL_FILE"; then
  pass "SKILL.md documents DESIGN.md as source of truth"
else
  fail "SKILL.md missing DESIGN.md source of truth contract"
fi

# Contract: Phase 5 reads targetPlatforms from config
if grep -qF "targetPlatforms" "$PHASES_DIR/phase-5-tokens.md"; then
  pass "Phase 5 references targetPlatforms field"
else
  fail "Phase 5 doesn't reference targetPlatforms"
fi

# Contract: Phase 6 reads framework from config
if grep -qF "framework" "$PHASES_DIR/phase-6-components.md" && grep -qF "config.json" "$PHASES_DIR/phase-6-components.md"; then
  pass "Phase 6 reads framework from config"
else
  fail "Phase 6 doesn't read framework from config"
fi

echo ""

# ---------------------------------------------------------------------------
# TEST 7: Docs Alignment (PHASE-INDEX, MAINTENANCE, QUALITY-GATES)
# ---------------------------------------------------------------------------
echo "=== TEST 7: Docs Alignment ==="

# PHASE-INDEX must mention all phases including 4b
for phase_id in "Phase 0" "Phase 1" "Phase 2" "Phase 3:" "Phase 3.5" "Phase 4:" "Phase 4b" "Phase 4.5" "Phase 5" "Phase 6" "Phase 7" "Phase 8:" "Phase 8.5" "Phase 9" "Phase 10" "Phase 11"; do
  if grep -qF "$phase_id" "$DOCS_DIR/PHASE-INDEX.md"; then
    pass "PHASE-INDEX.md mentions $phase_id"
  else
    fail "PHASE-INDEX.md missing $phase_id"
  fi
done

# MAINTENANCE.md file structure must list all phase files
phase_file_count=$(find "$PHASES_DIR" -maxdepth 1 -name 'phase-*.md' | wc -l | tr -d ' ')
maintenance_refs=$(grep -c 'phase-.*\.md' "$DOCS_DIR/MAINTENANCE.md" || true)

if [ "$maintenance_refs" -ge "$phase_file_count" ]; then
  pass "MAINTENANCE.md lists at least $phase_file_count phase file references"
else
  fail "MAINTENANCE.md lists $maintenance_refs phase refs but $phase_file_count phase files exist"
fi

# QUALITY-GATES.md must mention all sub-phases
for sub in "Phase 3.5" "Phase 4b" "Phase 4.5" "Phase 8.5"; do
  if grep -qF "$sub" "$DOCS_DIR/QUALITY-GATES.md"; then
    pass "QUALITY-GATES.md mentions $sub"
  else
    fail "QUALITY-GATES.md missing $sub"
  fi
done

echo ""

# ---------------------------------------------------------------------------
# TEST 8: Fix Loop Protocol Coverage
# Verify that implementation phases reference the Fix Loop Protocol.
# ---------------------------------------------------------------------------
echo "=== TEST 8: Fix Loop Protocol Coverage ==="

# operational-notes.md must define the protocol
if grep -qF "Fix Loop Protocol" "$PHASES_DIR/operational-notes.md"; then
  pass "operational-notes.md defines Fix Loop Protocol"
else
  fail "operational-notes.md missing Fix Loop Protocol definition"
fi

# Implementation phases must reference the protocol
for phase_file in "phase-5-tokens.md" "phase-6-components.md" "phase-7-storybook.md" "phase-9-documentation.md" "phase-10-integration.md" "phase-11-readiness-handoff.md"; do
  if grep -qF "Fix Loop" "$PHASES_DIR/$phase_file"; then
    pass "$phase_file references Fix Loop Protocol"
  else
    fail "$phase_file missing Fix Loop Protocol reference"
  fi
done

# SKILL.md cross-phase contracts must mention Fix Loop
if grep -qF "Fix Loop Protocol" "$SKILL_FILE"; then
  pass "SKILL.md cross-phase contracts mention Fix Loop Protocol"
else
  fail "SKILL.md missing Fix Loop Protocol in cross-phase contracts"
fi

echo ""

# ---------------------------------------------------------------------------
# SUMMARY
# ---------------------------------------------------------------------------
echo "==========================================="
echo "RESULTS: $PASS passed, $FAIL failed, $WARN warnings"
echo "==========================================="

if [ $FAIL -gt 0 ]; then
  exit 1
fi
