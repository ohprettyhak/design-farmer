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

required_status_markers=(
  "- **DONE**"
  "- **DONE_WITH_CONCERNS**"
  "- **BLOCKED**"
  "- **NEEDS_CONTEXT**"
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

echo "Validating completion statuses..."
for marker in "${required_status_markers[@]}"; do
  if ! grep -Fq -- "$marker" "$SKILL_FILE"; then
    echo "ERROR: Missing completion status marker: $marker"
    exit 1
  fi
done

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

echo "All skill structure checks passed."
