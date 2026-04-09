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
    section_fail_marker=$(mktemp "${TMPDIR:-/tmp}/df_test_section_XXXXXX")
    rm -f "$section_fail_marker"
    while IFS= read -r section; do
      if ! grep -qE "^## $section " "$PHASES_DIR/phase-4b-theming.md"; then
        echo "  ✗ Phase 4 handoff references §$section but it doesn't exist in phase-4b-theming.md"
        touch "$section_fail_marker"
      fi
    done <<< "$referenced_sections"
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
# TEST 9: Phase 0 — Re-Entry Paths
# High-risk: re-entry has broken in multiple PRs.
# ---------------------------------------------------------------------------
echo "=== TEST 9: Phase 0 — Re-Entry Paths ==="

if grep -q '^If user chose \*\*B\*\*:' "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Re-entry path A: Option B delimiter exists for block boundary parsing"
else
  fail "Re-entry path A: missing Option B delimiter for block boundary parsing"
fi

phase0_option_a_block=$(awk '/^If user chose \*\*A\*\*:/{found=1; next} found && /^If user chose \*\*B\*\*:/{exit} found' "$PHASES_DIR/phase-0-preflight.md")

if [ -z "$phase0_option_a_block" ]; then
  fail "Re-entry path A: Option A block boundaries are not parseable"
fi

if grep -qE 'Use it as context|design reference' "$PHASES_DIR/phase-0-preflight.md" &&
   echo "$phase0_option_a_block" | grep -qE 'Continue to Phase 1' &&
   echo "$phase0_option_a_block" | grep -qE 'Do NOT skip critical decision gates'; then
  pass "Re-entry path A: context import continues to Phase 1 with required gates"
else
  fail "Re-entry path A: missing context-import continuation and decision-gate guard"
fi

# Path A must parse Config YAML from DESIGN.md
if grep -q "packageManager" "$PHASES_DIR/phase-0-preflight.md" &&
   grep -q "designMaturity" "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Re-entry path A: Config YAML field parsing present"
else
  fail "Re-entry path A: missing Config YAML field parsing"
fi

if grep -q "bootstrap fields are still missing" "$PHASES_DIR/phase-0-preflight.md" &&
   grep -q "Phase 1 is responsible for confirming those design decisions" "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Re-entry path A: only bootstrap fields block context import"
else
  fail "Re-entry path A: Phase 0 still over-blocks design decisions before Phase 1"
fi

# Path B/C: continue to Phase 1 normally
if grep -q 'chose.*B.*or.*C.*continue to Phase 1' "$PHASES_DIR/phase-0-preflight.md" ||
   grep -q 'continue to Phase 1.*Discovery Interview.*as normal' "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Re-entry path B/C: continues to Phase 1 normally"
else
  fail "Re-entry path B/C: missing continuation to Phase 1"
fi

if grep -qE 'reentryMode' "$PHASES_DIR/phase-1-discovery.md" &&
   grep -qE 'design-context' "$PHASES_DIR/phase-1-discovery.md" &&
   grep -qE 'Do NOT auto-accept' "$PHASES_DIR/phase-1-discovery.md"; then
  pass "Re-entry path A: Phase 1 handles reentryMode design-context"
else
  fail "Re-entry path A: Phase 1 missing reentryMode design-context handling"
fi

if ! grep -qE 'Phase 0[[:space:]]*→[[:space:]]*Phase 5[[:space:]]*shortcut' "$PHASES_DIR/phase-4.5-design-source-of-truth.md" &&
   ! grep -qE 'Phase 0[[:space:]]*→[[:space:]]*Phase 5[[:space:]]*shortcut' "$EXAMPLES_DIR/DESIGN.md" &&
   ! grep -qE 'before jumping to Phase[[:space:]]*5' "$PHASES_DIR/operational-notes.md" &&
   ! grep -qE 'Phase 0[[:space:]]*→[[:space:]]*Phase 5[[:space:]]*shortcut' "$ROOT_DIR/docs/project-design-farmer.md" &&
   ! grep -qE 'parse Config YAML[[:space:]]+.*Phase[[:space:]]*5' "$ROOT_DIR/docs/project-design-farmer.md"; then
  pass "Re-entry docs/templates align with context-first contract"
else
  fail "Re-entry docs/templates contain stale Phase 0→5 shortcut wording"
fi

echo ""

# ---------------------------------------------------------------------------
# TEST 10: Phase 1 — Conditional Question Gates
# High-risk: wrong gating causes skipped questions or broken config.
# ---------------------------------------------------------------------------
echo "=== TEST 10: Phase 1 — Conditional Question Gates ==="

# Q3-1 (Headless Library): only if componentScope != foundation
if grep -q "Skip if user chose A.*Foundation only" "$PHASES_DIR/phase-1-discovery.md"; then
  pass "Q3-1: correctly gated on componentScope (skip for foundation)"
else
  fail "Q3-1: missing or incorrect conditional gate"
fi

# Q5-1 (Dark Mode Library): only if themeStrategy includes dark
if grep -q "Skip if user chose B.*Light only" "$PHASES_DIR/phase-1-discovery.md"; then
  pass "Q5-1: correctly gated on themeStrategy (skip for light-only)"
else
  fail "Q5-1: missing or incorrect conditional gate"
fi

echo ""

# ---------------------------------------------------------------------------
# TEST 11: Phase 4b — Light-Only Guard
# High-risk: has broken in multiple PRs.
# ---------------------------------------------------------------------------
echo "=== TEST 11: Phase 4b — Light-Only Guard ==="

if grep -q "Skip 4b.2 ThemeProvider" "$PHASES_DIR/phase-4b-theming.md" &&
   grep -q "Skip 4b.3 Scoped Theming" "$PHASES_DIR/phase-4b-theming.md" &&
   grep -q "Skip 4b.4 Dark Mode Checklist" "$PHASES_DIR/phase-4b-theming.md" &&
   grep -q "Proceed to 4b.5 Styling Approach" "$PHASES_DIR/phase-4b-theming.md"; then
  pass "Phase 4b light-only: skips 4b.2-4b.4, jumps to 4b.5"
else
  fail "Phase 4b light-only: missing skip/jump instructions"
fi

echo ""

# ---------------------------------------------------------------------------
# TEST 12: Phase 6 — Non-React Framework Guardrail
# High-risk: wrong guardrail breaks entire component phase.
# ---------------------------------------------------------------------------
echo "=== TEST 12: Phase 6 — Non-React Framework Guardrail ==="

# Non-React + foundation → skip to Phase 8
if grep -q "SKIP component implementation.*tokens only" "$PHASES_DIR/phase-6-components.md" ||
   grep -q "Jump to Phase 8" "$PHASES_DIR/phase-6-components.md"; then
  pass "Phase 6: non-React + foundation skips to Phase 8"
else
  fail "Phase 6: missing non-React + foundation skip path"
fi

# Non-React + non-foundation → NEEDS_CONTEXT
if grep -q "NEEDS_CONTEXT" "$PHASES_DIR/phase-6-components.md"; then
  pass "Phase 6: non-React + non-foundation triggers NEEDS_CONTEXT"
else
  fail "Phase 6: missing non-React + non-foundation NEEDS_CONTEXT"
fi

echo ""

# ---------------------------------------------------------------------------
# TEST 13: Cross-Phase Data Dependencies
# Verifies critical config fields flow through the correct phases.
# ---------------------------------------------------------------------------
echo "=== TEST 13: Cross-Phase Data Dependencies ==="

# designMaturity: Phase 2 → 3, 3.5, 6
if grep -q "designMaturity" "$PHASES_DIR/phase-3-pattern-extraction.md" &&
   grep -q "designMaturity" "$PHASES_DIR/phase-3.5-visual-preview.md" &&
   grep -q "designMaturity" "$PHASES_DIR/phase-6-components.md"; then
  pass "designMaturity: flows through Phases 3, 3.5, 6"
else
  fail "designMaturity: broken flow chain"
fi

# DESIGN.md: referenced in Phases 5, 6, 8 as source of truth
if grep -q "DESIGN.md" "$PHASES_DIR/phase-5-tokens.md" &&
   grep -q "DESIGN.md" "$PHASES_DIR/phase-6-components.md" &&
   grep -q "DESIGN.md" "$PHASES_DIR/phase-8-review.md"; then
  pass "DESIGN.md: referenced in Phases 5, 6, 8"
else
  fail "DESIGN.md: not consistently referenced"
fi

echo ""

# ---------------------------------------------------------------------------
# TEST 14: Pipeline State Tracking
# Verifies completedPhases/createdAt tracking across phases.
# ---------------------------------------------------------------------------
echo "=== TEST 14: Pipeline State Tracking ==="

# completedPhases defined in Phase 1 interface
if grep -q "completedPhases" "$PHASES_DIR/phase-1-discovery.md"; then
  pass "Phase 1: completedPhases defined in DesignFarmerConfig"
else
  fail "Phase 1: missing completedPhases in DesignFarmerConfig"
fi

# Phase 0 displays completedPhases and createdAt on re-entry
if grep -q "completedPhases" "$PHASES_DIR/phase-0-preflight.md" &&
   grep -q "createdAt" "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Phase 0: displays completedPhases and createdAt on re-entry"
else
  fail "Phase 0: missing completedPhases/createdAt display"
fi

# SKILL.md centralizes completedPhases tracking
if grep -q "completedPhases" "$SKILL_FILE"; then
  pass "SKILL.md: documents completedPhases contract"
else
  fail "SKILL.md: missing completedPhases contract"
fi

echo ""

echo "=== TEST 15: Control Size Ladder Consistency ==="

PHASE45_FILE="$PHASES_DIR/phase-4.5-design-source-of-truth.md"
EXAMPLE_DESIGN_FILE="$EXAMPLES_DIR/DESIGN.md"
PHASE6_FILE="$PHASES_DIR/phase-6-components.md"
PHASE7_FILE="$PHASES_DIR/phase-7-storybook.md"

if grep -q "| x-small | 28px" "$PHASE45_FILE" &&
   grep -q "| small | 32px" "$PHASE45_FILE" &&
   grep -q "| medium | 36px" "$PHASE45_FILE" &&
   grep -q "| large | 40px" "$PHASE45_FILE"; then
  pass "Phase 4.5 Button size ladder is 28/32/36/40"
else
  fail "Phase 4.5 Button size ladder is not 28/32/36/40"
fi

if grep -q "Recommended control size mapping (align Button/Input/Select for visual consistency)" "$PHASE45_FILE"; then
  pass "Phase 4.5 defines shared Button/Input/Select mapping"
else
  fail "Phase 4.5 missing shared Button/Input/Select size mapping guidance"
fi

if grep -q "| x-small | 28px" "$EXAMPLE_DESIGN_FILE" &&
   grep -q "| small | 32px" "$EXAMPLE_DESIGN_FILE" &&
   grep -q "| medium | 36px" "$EXAMPLE_DESIGN_FILE" &&
   grep -q "| large | 40px" "$EXAMPLE_DESIGN_FILE"; then
  pass "Example DESIGN.md size ladder matches 28/32/36/40"
else
  fail "Example DESIGN.md size ladder does not match 28/32/36/40"
fi

if grep -qi "align control sizes across Button/Input/Select" "$PHASE6_FILE"; then
  pass "Phase 6 recommends aligned Button/Input/Select size ladder"
else
  fail "Phase 6 missing shared ladder guidance"
fi

if grep -q "\['x-small', 'small', 'medium', 'large'\]" "$PHASE7_FILE"; then
  pass "Phase 7 story size axis includes x-small/small/medium/large"
else
  fail "Phase 7 story size axis missing one or more canonical sizes"
fi

echo ""

echo "=== TEST 16: Radius Tone Contract Consistency ==="

PHASE0_FILE="$PHASES_DIR/phase-0-preflight.md"
PHASE1_FILE="$PHASES_DIR/phase-1-discovery.md"

if grep -q "radiusTone" "$PHASE0_FILE" &&
   grep -q "radiusTone" "$PHASE1_FILE" &&
   grep -q "radiusTone" "$PHASE45_FILE" &&
   grep -q "radiusTone" "$EXAMPLE_DESIGN_FILE"; then
  pass "radiusTone propagates through Phase 0, Phase 1, Phase 4.5, and example DESIGN.md"
else
  fail "radiusTone propagation is incomplete across required contracts"
fi

if grep -q 'rounded → sm:' "$PHASE45_FILE" &&
   grep -q 'md: `8px`' "$PHASE45_FILE" &&
   grep -q 'lg: `12px`' "$PHASE45_FILE"; then
  pass "Phase 4.5 defines rounded radius mapping as 4/8/12"
else
  fail "Phase 4.5 missing rounded radius mapping 4/8/12"
fi

if grep -q 'For `radiusTone: rounded`, medium control radius resolves to `8px`' "$EXAMPLE_DESIGN_FILE" &&
   grep -q -- '- Border-radius: `8px` (`--button-radius`)' "$EXAMPLE_DESIGN_FILE"; then
  pass "Example DESIGN.md aligns rounded tone with 8px medium control radius"
else
  fail "Example DESIGN.md radius values drift from rounded 8px medium control contract"
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
