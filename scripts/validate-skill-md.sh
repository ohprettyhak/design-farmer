#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$ROOT_DIR/skills/design-farmer"
SKILL_FILE="$SKILL_DIR/SKILL.md"
PHASE_INDEX_FILE="$SKILL_DIR/docs/PHASE-INDEX.md"
QUALITY_GATES_FILE="$SKILL_DIR/docs/QUALITY-GATES.md"
MAINTENANCE_FILE="$SKILL_DIR/docs/MAINTENANCE.md"
EXAMPLES_FILE="$SKILL_DIR/docs/EXAMPLES-GALLERY.md"
OP_NOTES_FILE="$SKILL_DIR/phases/operational-notes.md"

if [[ ! -f "$SKILL_FILE" ]]; then
  echo "ERROR: Missing skill file: $SKILL_FILE"
  exit 1
fi

for required_file in "$PHASE_INDEX_FILE" "$QUALITY_GATES_FILE" "$MAINTENANCE_FILE" "$EXAMPLES_FILE" "$OP_NOTES_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    echo "ERROR: Missing required bundle file: $required_file"
    exit 1
  fi
done

required_phase_specs=(
  "Phase 0: Pre-flight|phases/phase-0-preflight.md"
  "Phase 1: Discovery Interview|phases/phase-1-discovery.md"
  "Phase 2: Repository Analysis|phases/phase-2-repo-analysis.md"
  "Phase 3: Design Pattern Extraction & OKLCH Conversion|phases/phase-3-pattern-extraction.md"
  "Phase 3.5: Visual Preview|phases/phase-3.5-visual-preview.md"
  "Phase 4: Architecture Design|phases/phase-4-architecture.md"
  "Phase 4.5: Design Source of Truth (DESIGN.md)|phases/phase-4.5-design-source-of-truth.md"
  "Phase 5: Token Implementation|phases/phase-5-tokens.md"
  "Phase 6: Component Implementation|phases/phase-6-components.md"
  "Phase 7: Storybook Integration|phases/phase-7-storybook.md"
  "Phase 8: Multi-Reviewer Verification|phases/phase-8-review.md"
  "Phase 8.5: Design Review (Live Visual QA)|phases/phase-8.5-design-review.md"
  "Phase 9: Documentation & Completion|phases/phase-9-documentation.md"
  "Phase 10: App Integration|phases/phase-10-integration.md"
  "Phase 11: Release Readiness & Handoff|phases/phase-11-readiness-handoff.md"
)

echo "Validating router references and phase bundle..."
required_phase_paths=()
for spec in "${required_phase_specs[@]}"; do
  phase="${spec%%|*}"
  relative_path="${spec##*|}"
  phase_file="$SKILL_DIR/$relative_path"
  required_phase_paths+=("$relative_path")

  if [[ ! -f "$phase_file" ]]; then
    echo "ERROR: Missing phase file: $phase_file"
    exit 1
  fi

  if ! grep -Fq "$phase" "$SKILL_FILE"; then
    echo "ERROR: Missing phase label in SKILL.md router: $phase"
    exit 1
  fi

  if ! grep -Fq "$relative_path" "$SKILL_FILE"; then
    echo "ERROR: Missing phase path reference in SKILL.md router: $relative_path"
    exit 1
  fi

  if ! grep -Fq "# $phase" "$phase_file"; then
    echo "ERROR: Phase file header mismatch in $relative_path: expected '# $phase'"
    exit 1
  fi

  if ! grep -Fq "$phase" "$PHASE_INDEX_FILE"; then
    echo "ERROR: Missing phase label in PHASE-INDEX.md: $phase"
    exit 1
  fi
done

echo "Validating no orphan phase files..."
while IFS= read -r phase_path; do
  rel="${phase_path#$SKILL_DIR/}"
  matched=0
  for required_path in "${required_phase_paths[@]}"; do
    if [[ "$rel" == "$required_path" ]]; then
      matched=1
      break
    fi
  done

  if [[ $matched -eq 0 ]]; then
    echo "ERROR: Orphan phase file not referenced by router: $rel"
    exit 1
  fi
done < <(find "$SKILL_DIR/phases" -maxdepth 1 -type f -name 'phase-*.md' | sort)

echo "Validating companion phase index alignment..."
if ! grep -Fq "Bundle Integrity Gate" "$SKILL_FILE"; then
  echo "ERROR: Router missing bundle integrity gate"
  exit 1
fi

echo "Validating PHASE-INDEX.md has no extra phases..."
while IFS= read -r index_phase; do
  matched=0
  for spec in "${required_phase_specs[@]}"; do
    phase="${spec%%|*}"
    if [[ "$index_phase" == "$phase" ]]; then
      matched=1
      break
    fi
  done
  if [[ $matched -eq 0 ]]; then
    echo "ERROR: PHASE-INDEX.md contains phase not in canonical router: $index_phase"
    echo "  File: docs/PHASE-INDEX.md"
    echo "  Contract: phase map alignment (SKILL.md <-> PHASE-INDEX.md)"
    exit 1
  fi
done < <(sed -n 's/.*\*\*\(Phase [0-9][0-9.]*: [^*]*\)\*\*.*/\1/p' "$PHASE_INDEX_FILE")

echo "Validating PHASE-INDEX.md phase format consistency..."
PHASE_MAP_SECTION=$(awk '/^## Phase Map/{found=1; next} found && /^## /{exit} found' "$PHASE_INDEX_FILE")
unformatted=$(echo "$PHASE_MAP_SECTION" | grep -E 'Phase [0-9]+(\.[0-9]+)?:' | grep -Fv '**Phase' || true)
if [[ -n "$unformatted" ]]; then
  echo "ERROR: PHASE-INDEX.md contains unformatted phase references in Phase Map section:"
  echo "$unformatted"
  echo "  File: docs/PHASE-INDEX.md"
  echo "  Contract: phase entries must use **bold** formatting for reliable extraction"
  exit 1
fi

# --- Contract-level: Completion Status Protocol section ---
echo "Validating completion statuses in protocol section..."
PROTOCOL_SECTION=$(awk '/^## Completion Status Protocol/{found=1; next} found && /^## /{exit} found' "$SKILL_FILE")
if [[ -z "$PROTOCOL_SECTION" ]]; then
  echo "ERROR: '## Completion Status Protocol' section in SKILL.md is missing or empty"
  echo "  File: SKILL.md"
  echo "  Contract: completion protocol section must exist as a dedicated heading with content"
  exit 1
fi

required_status_markers=(
  "- **DONE**"
  "- **DONE_WITH_CONCERNS**"
  "- **BLOCKED**"
  "- **NEEDS_CONTEXT**"
)
for marker in "${required_status_markers[@]}"; do
  if ! echo "$PROTOCOL_SECTION" | grep -Fq -- "$marker"; then
    echo "ERROR: Completion status marker missing from protocol section: $marker"
    echo "  File: SKILL.md, section: '## Completion Status Protocol'"
    echo "  Contract: all four status markers must appear in the protocol section, not elsewhere"
    exit 1
  fi
done

# --- Contract-level: Cross-Phase Contracts ---
echo "Validating cross-phase contracts in SKILL.md..."
CROSS_PHASE_SECTION=$(awk '/^### Cross-Phase Contracts/{found=1; next} found && /^##[# ]/{exit} found' "$SKILL_FILE")
if [[ -z "$CROSS_PHASE_SECTION" ]]; then
  echo "ERROR: '### Cross-Phase Contracts' section in SKILL.md is missing or empty"
  echo "  File: SKILL.md"
  echo "  Contract: cross-phase contract section must exist with content"
  exit 1
fi

required_cross_phase_contracts=(
  "DesignFarmerConfig"
  "Completion statuses are mandatory"
  "one-at-a-time"
  "explicit verification evidence"
)
for contract in "${required_cross_phase_contracts[@]}"; do
  if ! echo "$CROSS_PHASE_SECTION" | grep -Fq "$contract"; then
    echo "ERROR: Required cross-phase contract missing from SKILL.md: '$contract'"
    echo "  File: SKILL.md, section: '### Cross-Phase Contracts'"
    echo "  Contract: cross-phase contracts must include all required behavioral guarantees"
    exit 1
  fi
done

echo "Validating cross-phase contracts in PHASE-INDEX.md..."
INDEX_CROSS_SECTION=$(awk '/^## Cross-Phase Contracts/{found=1; next} found && /^## /{exit} found' "$PHASE_INDEX_FILE")
if [[ -z "$INDEX_CROSS_SECTION" ]]; then
  echo "ERROR: '## Cross-Phase Contracts' section in PHASE-INDEX.md is missing or empty"
  echo "  File: docs/PHASE-INDEX.md"
  echo "  Contract: PHASE-INDEX.md must mirror cross-phase contract declarations with content"
  exit 1
fi

index_required_contracts=(
  "Completion statuses are mandatory"
  "one-at-a-time"
  "explicit verification evidence"
)
for contract in "${index_required_contracts[@]}"; do
  if ! echo "$INDEX_CROSS_SECTION" | grep -Fq "$contract"; then
    echo "ERROR: Cross-phase contract missing from PHASE-INDEX.md: '$contract'"
    echo "  File: docs/PHASE-INDEX.md, section: '## Cross-Phase Contracts'"
    echo "  Contract: phase index must stay aligned with SKILL.md cross-phase contracts"
    exit 1
  fi
done

# --- Contract-level: Discovery gating semantics ---
echo "Validating discovery interview gating semantics..."
DISCOVERY_FILE="$SKILL_DIR/phases/phase-1-discovery.md"

discovery_control_points=(
  "ONE AT A TIME"
  "AskUserQuestion"
  "STOP"
)
for marker in "${discovery_control_points[@]}"; do
  if ! grep -Fq "$marker" "$DISCOVERY_FILE"; then
    echo "ERROR: Discovery gating control-point missing: '$marker'"
    echo "  File: phases/phase-1-discovery.md"
    echo "  Contract: discovery interview must enforce one-question-at-a-time semantics"
    exit 1
  fi
done

stop_count=$(grep -cF "STOP" "$DISCOVERY_FILE" || true)
ask_count=$(grep -cF "AskUserQuestion" "$DISCOVERY_FILE" || true)
if [[ "$stop_count" -lt 2 ]]; then
  echo "ERROR: Discovery file has fewer than 2 STOP markers (found $stop_count)"
  echo "  File: phases/phase-1-discovery.md"
  echo "  Contract: each question block must end with a STOP control point"
  exit 1
fi
if [[ "$ask_count" -lt 2 ]]; then
  echo "ERROR: Discovery file has fewer than 2 AskUserQuestion references (found $ask_count)"
  echo "  File: phases/phase-1-discovery.md"
  echo "  Contract: each question must be gated via AskUserQuestion"
  exit 1
fi

# --- Contract-level: Phase file required sections ---
echo "Validating required sections in verification phases..."

if ! grep -Fq "## 9.2 Final Verification" "$SKILL_DIR/phases/phase-9-documentation.md"; then
  echo "ERROR: Missing required section '## 9.2 Final Verification' in phase-9-documentation.md"
  echo "  File: phases/phase-9-documentation.md"
  echo "  Contract: Phase 9 must contain an explicit final verification section"
  exit 1
fi

if ! grep -Fq "## 11.1 Final Verification" "$SKILL_DIR/phases/phase-11-readiness-handoff.md"; then
  echo "ERROR: Missing required section '## 11.1 Final Verification' in phase-11-readiness-handoff.md"
  echo "  File: phases/phase-11-readiness-handoff.md"
  echo "  Contract: Phase 11 must contain an explicit final verification section"
  exit 1
fi

if ! grep -Fq "## 11.2 Readiness Checklist" "$SKILL_DIR/phases/phase-11-readiness-handoff.md"; then
  echo "ERROR: Missing required section '## 11.2 Readiness Checklist' in phase-11-readiness-handoff.md"
  echo "  File: phases/phase-11-readiness-handoff.md"
  echo "  Contract: Phase 11 must contain a readiness checklist section"
  exit 1
fi

echo "Validating tool-contract keywords..."
if ! grep -Fq "AskUserQuestion" "$SKILL_FILE"; then
  echo "ERROR: AskUserQuestion reference not found"
  exit 1
fi

if ! grep -Fq -- "- Agent" "$SKILL_FILE"; then
  echo "ERROR: Agent tool is not declared in SKILL.md allowed-tools"
  exit 1
fi

if ! grep -Fq 'Agent(prompt="' "$SKILL_FILE"; then
  echo "ERROR: Explicit Agent(prompt=...) compatibility reference not found"
  exit 1
fi

echo "Validating stale references..."
if grep -R -nE 'best-practices\.md|research/best-practices\.md' "$SKILL_DIR" >/dev/null 2>&1; then
  echo "ERROR: Stale best-practices reference found in split bundle"
  exit 1
fi

echo "All skill structure and contract checks passed."
