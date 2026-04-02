#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_FILE="$ROOT_DIR/skills/design-farmer/SKILL.md"
PHASE_INDEX_FILE="$ROOT_DIR/skills/design-farmer/docs/PHASE-INDEX.md"

if [[ ! -f "$SKILL_FILE" ]]; then
  echo "ERROR: Missing skill file: $SKILL_FILE"
  exit 1
fi

if [[ ! -f "$PHASE_INDEX_FILE" ]]; then
  echo "ERROR: Missing phase index file: $PHASE_INDEX_FILE"
  exit 1
fi

required_phases=(
  "Phase 0: Pre-flight"
  "Phase 1: Discovery Interview"
  "Phase 2: Repository Analysis"
  "Phase 3: Design Pattern Extraction & OKLCH Conversion"
  "Phase 4: Architecture Design"
  "Phase 5: Token Implementation"
  "Phase 6: Component Implementation"
  "Phase 7: Storybook Integration"
  "Phase 8: Multi-Reviewer Verification"
  "Phase 8.5: Design Review (Live Visual QA)"
  "Phase 9: Documentation & Completion"
)

required_status_markers=(
  "- **DONE**"
  "- **DONE_WITH_CONCERNS**"
  "- **BLOCKED**"
  "- **NEEDS_CONTEXT**"
)

echo "Validating required phases in SKILL.md..."
for phase in "${required_phases[@]}"; do
  if ! grep -Fq "## $phase" "$SKILL_FILE"; then
    echo "ERROR: Missing phase header in SKILL.md: $phase"
    exit 1
  fi
done

echo "Validating companion phase index alignment..."
for phase in "${required_phases[@]}"; do
  if ! grep -Fq "$phase" "$PHASE_INDEX_FILE"; then
    echo "ERROR: Missing phase label in PHASE-INDEX.md: $phase"
    exit 1
  fi
done

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

if ! grep -Fq "Agent(" "$SKILL_FILE"; then
  echo "ERROR: Agent delegation reference not found"
  exit 1
fi

echo "All skill structure checks passed."
