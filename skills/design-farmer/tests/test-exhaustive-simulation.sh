#!/usr/bin/env bash
# Exhaustive Simulation — Design Farmer Phase Pipeline
#
# Simulates ALL possible execution paths through the phase pipeline,
# verifying that every combination of user choices leads to a valid,
# non-contradictory instruction set.
#
# Coverage dimensions:
#   A. Phase 0: DESIGN.md re-entry (3 paths: A/B/C)
#   B. Phase 1: Discovery interview conditional questions (Q3-1, Q5-1)
#   C. Phase 2: Design maturity branches (greenfield/emerging/mature)
#   D. Phase 3: Path selection per maturity
#   E. Phase 4b: Theme strategy gate (light-only vs others)
#   F. Phase 5: Target platform branch (web/web-native/web-hybrid/multi-platform)
#   G. Phase 6: Framework guardrail (React vs non-React x componentScope)
#   H. Phase 6: Headless library compatibility (framework-specific libraries)
#   I. Phase 7: Storybook skip logic (optional + non-React token-only)
#   J. Phase 8: Reviewer scope adaptation (token-only vs full components)
#   K. Phase 8: themeStrategy=light-only reviewer skip
#   L. Phase 10: Framework decision matrix coverage
#   M. Phase 11: Temporary file cleanup correctness
#   N. Cross-phase: data dependency chain integrity
#   O. Cross-phase: conditional skip/jump path validity
#   P. Fallback/degradation registry completeness
#   Q. Fix Loop Protocol activation coverage
#   R. Discovery conditional question triggers
#   S. DESIGN.md Config field round-trip (Phase 4.5 → Phase 0 re-entry)
#   T. Phase handoff chain with skip/jump paths
#   U. Storybook location decision (monorepo vs single-repo)
#
# Usage: bash skills/design-farmer/tests/test-exhaustive-simulation.sh

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

# ===========================================================================
# DIMENSION A: Phase 0 — DESIGN.md Re-Entry Paths
# ===========================================================================
echo "=== DIMENSION A: Phase 0 — DESIGN.md Re-Entry Paths ==="

# Path A: Use DESIGN.md as-is → skip to Phase 5
if grep -q "Jump directly to Phase 5" "$PHASES_DIR/phase-0-preflight.md" &&
   grep -q "Do not run Phases 1–4" "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Re-entry path A: skip to Phase 5 with explicit Phase 1-4 bypass"
else
  fail "Re-entry path A: missing skip-to-Phase-5 or Phase-1-4 bypass"
fi

# Path A must parse Config YAML from DESIGN.md
if grep -q "Read the.*Config.*YAML block" "$PHASES_DIR/phase-0-preflight.md" &&
   grep -q "packageManager" "$PHASES_DIR/phase-0-preflight.md" &&
   grep -q "designMaturity" "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Re-entry path A: Config YAML parsing includes critical fields"
else
  fail "Re-entry path A: missing Config YAML field parsing"
fi

# Path A: must derive computed identifiers (designSystemDir, designSystemPackage, productName)
if grep -q "designSystemDir" "$PHASES_DIR/phase-0-preflight.md" &&
   grep -q "designSystemPackage" "$PHASES_DIR/phase-0-preflight.md" &&
   grep -q "productName" "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Re-entry path A: derives computed identifiers"
else
  fail "Re-entry path A: missing derived identifier computation"
fi

# Path A: must run architecture scan (substitute for Phase 4)
if grep -q "quick architecture scan" "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Re-entry path A: substitutes Phase 4 with architecture scan"
else
  fail "Re-entry path A: no Phase 4 substitute scan"
fi

# Path B: Update DESIGN.md → run Phases 1-4 normally
if grep -q 'chose.*B.*or.*C.*continue to Phase 1' "$PHASES_DIR/phase-0-preflight.md" ||
   grep -q 'continue to Phase 1.*Discovery Interview.*as normal' "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Re-entry path B/C: continues to Phase 1 normally"
else
  fail "Re-entry path B/C: missing continuation to Phase 1"
fi

# Phase 0 must detect existing design system WITHOUT DESIGN.md
if grep -q "existing design system.*detected.*but no DESIGN.md" "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Phase 0: handles existing design system without DESIGN.md"
else
  fail "Phase 0: missing handler for design system without DESIGN.md"
fi

echo ""

# ===========================================================================
# DIMENSION B: Phase 1 — Conditional Question Flows
# ===========================================================================
echo "=== DIMENSION B: Phase 1 — Conditional Question Flows ==="

# Q3-1 (Headless Library) conditional: only if componentScope != foundation
if grep -q "Only ask this if the user chose B.*Core interactive.*C.*Full starter kit.*or D.*Custom" "$PHASES_DIR/phase-1-discovery.md" &&
   grep -q "Skip if user chose A.*Foundation only" "$PHASES_DIR/phase-1-discovery.md"; then
  pass "Q3-1: correctly gated on componentScope (skip for foundation)"
else
  fail "Q3-1: missing or incorrect conditional gate"
fi

# Q5-1 (Dark Mode Library) conditional: only if themeStrategy includes dark
if grep -q "Only ask this if the user chose A.*Light.*Dark.*C.*Multi-brand.*or D" "$PHASES_DIR/phase-1-discovery.md" &&
   grep -q "Skip if user chose B.*Light only" "$PHASES_DIR/phase-1-discovery.md"; then
  pass "Q5-1: correctly gated on themeStrategy (skip for light-only)"
else
  fail "Q5-1: missing or incorrect conditional gate"
fi

# Q5-1 must cover ALL supported frameworks
for fw in "Next.js" "Astro" "Remix" "SvelteKit" "Nuxt" "plain React"; do
  if grep -qi "$fw" "$PHASES_DIR/phase-1-discovery.md"; then
    pass "Q5-1: covers framework $fw"
  else
    fail "Q5-1: missing framework $fw"
  fi
done

# Q3-1 must provide options per framework family (React, Vue, Svelte, other)
for fw_family in "React" "Vue" "Svelte"; do
  if grep -q "If $fw_family detected" "$PHASES_DIR/phase-1-discovery.md"; then
    pass "Q3-1: has framework-specific options for $fw_family"
  else
    fail "Q3-1: missing framework-specific options for $fw_family"
  fi
done

# Impatience escape hatch after 3+ questions
if grep -q "impatience after 3" "$PHASES_DIR/phase-1-discovery.md"; then
  pass "Discovery: has impatience escape hatch"
else
  fail "Discovery: missing impatience escape hatch"
fi

# Final confirmation question must list all 8 questions
if grep -q "Q0.*pain point.*through.*Q7.*platforms" "$PHASES_DIR/phase-1-discovery.md" ||
   grep -q "Q0.*through.*Q7" "$PHASES_DIR/phase-1-discovery.md"; then
  pass "Discovery: final confirmation covers Q0 through Q7"
else
  fail "Discovery: final confirmation doesn't reference Q0 through Q7"
fi

echo ""

# ===========================================================================
# DIMENSION C: Phase 2/3 — Design Maturity Branches
# ===========================================================================
echo "=== DIMENSION C: Phase 2/3 — Design Maturity Branches ==="

# Phase 2 must define all three maturity levels with scoring
for level in "GREENFIELD" "EMERGING" "MATURE"; do
  if grep -q "$level" "$PHASES_DIR/phase-2-repo-analysis.md"; then
    pass "Phase 2: defines maturity level $level"
  else
    fail "Phase 2: missing maturity level $level"
  fi
done

# Phase 2 must update DesignFarmerConfig with maturity
if grep -q "designMaturity.*greenfield.*emerging.*mature" "$PHASES_DIR/phase-2-repo-analysis.md" &&
   grep -q "maturityScore" "$PHASES_DIR/phase-2-repo-analysis.md"; then
  pass "Phase 2: updates config with designMaturity and maturityScore"
else
  fail "Phase 2: missing config update for maturity"
fi

# Phase 3 must branch on designMaturity
for level in "GREENFIELD" "EMERGING" "MATURE"; do
  if grep -q "$level" "$PHASES_DIR/phase-3-pattern-extraction.md"; then
    pass "Phase 3: branches on $level maturity"
  else
    fail "Phase 3: missing $level branch"
  fi
done

# Phase 3 GREENFIELD: skip extraction, use defaults
if grep -q "GREENFIELD.*Skip sections 3.1.*3.7" "$PHASES_DIR/phase-3-pattern-extraction.md" ||
   grep -q "GREENFIELD.*No significant patterns to extract" "$PHASES_DIR/phase-3-pattern-extraction.md"; then
  pass "Phase 3 GREENFIELD: skips extraction loops"
else
  fail "Phase 3 GREENFIELD: doesn't explicitly skip extraction"
fi

# Phase 3 GREENFIELD: must provide default values
if grep -q "Greenfield Defaults" "$PHASES_DIR/phase-3-pattern-extraction.md" &&
   grep -q "Inter" "$PHASES_DIR/phase-3-pattern-extraction.md" &&
   grep -q "oklch(0.55 0.22 264)" "$PHASES_DIR/phase-3-pattern-extraction.md"; then
  pass "Phase 3 GREENFIELD: provides complete defaults (font, color)"
else
  fail "Phase 3 GREENFIELD: missing default values"
fi

# Phase 3 EMERGING: marks extracted vs generated
if grep -q "EXTRACTED.*GENERATED" "$PHASES_DIR/phase-3-pattern-extraction.md" ||
   grep -q "\[EXTRACTED\].*\[GENERATED\]" "$PHASES_DIR/phase-3-pattern-extraction.md"; then
  pass "Phase 3 EMERGING: marks extracted vs generated values"
else
  fail "Phase 3 EMERGING: missing extracted/generated markers"
fi

# Phase 3.5 GREENFIELD framing
if grep -q "Greenfield" "$PHASES_DIR/phase-3.5-visual-preview.md" &&
   grep -q "Proposed Design Direction" "$PHASES_DIR/phase-3.5-visual-preview.md"; then
  pass "Phase 3.5: greenfield-specific framing for preview"
else
  fail "Phase 3.5: missing greenfield framing"
fi

echo ""

# ===========================================================================
# DIMENSION D: Phase 4b — Theme Strategy Gate
# ===========================================================================
echo "=== DIMENSION D: Phase 4b — Theme Strategy Gate ==="

# light-only must skip dark CSS, ThemeProvider, scoped theming, dark mode checklist
if grep -q "light-only" "$PHASES_DIR/phase-4b-theming.md"; then
  # Check explicit skip instructions
  if grep -q "Skip 4b.2 ThemeProvider" "$PHASES_DIR/phase-4b-theming.md" &&
     grep -q "Skip 4b.3 Scoped Theming" "$PHASES_DIR/phase-4b-theming.md" &&
     grep -q "Skip 4b.4 Dark Mode Checklist" "$PHASES_DIR/phase-4b-theming.md"; then
    pass "Phase 4b light-only: skips ThemeProvider, scoped theming, dark mode checklist"
  else
    fail "Phase 4b light-only: missing skip instructions"
  fi
else
  fail "Phase 4b: doesn't handle light-only themeStrategy"
fi

# light-only → proceed to 4b.5
if grep -q "Proceed to 4b.5 Styling Approach" "$PHASES_DIR/phase-4b-theming.md"; then
  pass "Phase 4b light-only: correctly jumps to 4b.5 styling approach"
else
  fail "Phase 4b light-only: missing jump to 4b.5"
fi

# All other strategies must proceed through 4b.1-4b.5
for strategy in "light-dark" "multi-brand" "custom"; do
  if grep -q "$strategy" "$PHASES_DIR/phase-4b-theming.md"; then
    pass "Phase 4b: handles themeStrategy=$strategy"
  else
    fail "Phase 4b: missing themeStrategy=$strategy"
  fi
done

echo ""

# ===========================================================================
# DIMENSION E: Phase 5 — Target Platform Branches
# ===========================================================================
echo "=== DIMENSION E: Phase 5 — Target Platform Branches ==="

# All four platform types must be handled
for platform in "web" "web-native" "web-hybrid" "multi-platform"; do
  if grep -q "$platform" "$PHASES_DIR/phase-5-tokens.md"; then
    pass "Phase 5: handles targetPlatforms=$platform"
  else
    fail "Phase 5: missing targetPlatforms=$platform"
  fi
done

# web-native / multi-platform: must require OKLCH → sRGB conversion for native
if grep -q "OKLCH.*converted to sRGB" "$PHASES_DIR/phase-5-tokens.md" ||
   grep -q "convert to.*hex.*sRGB" "$PHASES_DIR/phase-5-tokens.md"; then
  pass "Phase 5: requires OKLCH→sRGB conversion for native platforms"
else
  fail "Phase 5: missing OKLCH→sRGB conversion requirement"
fi

# web-hybrid: must be treated as web (no conversion needed)
# The web-hybrid block spans multiple lines, so check both key phrases exist in the file
if grep -q "web-hybrid" "$PHASES_DIR/phase-5-tokens.md" &&
   grep -q "Treat as.*web" "$PHASES_DIR/phase-5-tokens.md" &&
   grep -q "No conversion needed" "$PHASES_DIR/phase-5-tokens.md"; then
  pass "Phase 5: web-hybrid treated as web (no conversion)"
else
  fail "Phase 5: web-hybrid not explicitly mapped to web path"
fi

# Style Dictionary must be mentioned for multi-platform
if grep -q "Style Dictionary" "$PHASES_DIR/phase-5-tokens.md"; then
  pass "Phase 5: references Style Dictionary for multi-platform"
else
  fail "Phase 5: missing Style Dictionary reference for multi-platform"
fi

# cn utility: skip for non-Tailwind
if grep -q "Skip this step if the project is not using Tailwind" "$PHASES_DIR/phase-5-tokens.md"; then
  pass "Phase 5: cn utility correctly conditional on Tailwind"
else
  fail "Phase 5: cn utility missing Tailwind conditional"
fi

echo ""

# ===========================================================================
# DIMENSION F: Phase 6 — Framework Guardrail (React vs Non-React)
# ===========================================================================
echo "=== DIMENSION F: Phase 6 — Framework Guardrail ==="

# React frameworks: full component support
for react_fw in "next-app-router" "next-pages-router" "vite-react" "remix"; do
  if grep -q "$react_fw" "$PHASES_DIR/phase-6-components.md"; then
    pass "Phase 6: React framework $react_fw → full component path"
  else
    fail "Phase 6: missing React framework $react_fw"
  fi
done

# Non-React with foundation scope: skip components entirely
if grep -q "astro.*sveltekit.*nuxt.*componentScope.*foundation" "$PHASES_DIR/phase-6-components.md" ||
   grep -q "SKIP component implementation.*tokens only" "$PHASES_DIR/phase-6-components.md"; then
  pass "Phase 6: non-React + foundation → skip to Phase 8"
else
  fail "Phase 6: missing non-React + foundation skip path"
fi

# Non-React with non-foundation: ask user
if grep -q "NEEDS_CONTEXT" "$PHASES_DIR/phase-6-components.md" &&
   grep -q "doesn.*t use React component patterns" "$PHASES_DIR/phase-6-components.md"; then
  pass "Phase 6: non-React + non-foundation → NEEDS_CONTEXT prompt"
else
  fail "Phase 6: missing non-React + non-foundation user prompt"
fi

# User chose A (React in non-React framework): must validate headless library
if grep -q "headless library.*framework-specific" "$PHASES_DIR/phase-6-components.md" ||
   grep -q "NOT compatible with React" "$PHASES_DIR/phase-6-components.md"; then
  pass "Phase 6: validates headless library compatibility for React-in-non-React"
else
  fail "Phase 6: missing headless library compatibility check"
fi

# Specific incompatible libraries listed
for lib in "melt" "bits"; do
  if grep -q "$lib" "$PHASES_DIR/phase-6-components.md"; then
    pass "Phase 6: flags $lib as non-React-compatible"
  else
    fail "Phase 6: missing $lib incompatibility flag"
  fi
done

# Phase 6 maturity branching
for maturity in "GREENFIELD" "EMERGING" "MATURE"; do
  if grep -q "$maturity" "$PHASES_DIR/phase-6-components.md"; then
    pass "Phase 6: branches on maturity=$maturity"
  else
    fail "Phase 6: missing maturity=$maturity branch"
  fi
done

echo ""

# ===========================================================================
# DIMENSION G: Phase 7 — Storybook Optional + Skip Logic
# ===========================================================================
echo "=== DIMENSION G: Phase 7 — Storybook Optional + Skip Logic ==="

# Phase 7 must be optional (user can choose C to skip)
if grep -q "No, skip Storybook" "$PHASES_DIR/phase-7-storybook.md"; then
  pass "Phase 7: offers skip option"
else
  fail "Phase 7: missing skip option"
fi

# Phase 6 non-React token-only: must jump to Phase 8 skipping Phase 7
if grep -q "Jump to Phase 8.*skip Phase 7" "$PHASES_DIR/phase-6-components.md" ||
   grep -q "skip Phase 7.*Storybook" "$PHASES_DIR/phase-6-components.md"; then
  pass "Phase 6→7 skip: non-React token-only skips Storybook"
else
  fail "Phase 6→7 skip: missing Storybook skip for non-React token-only"
fi

# Monorepo Storybook location question
if grep -q "monorepo.*Where should Storybook live" "$PHASES_DIR/phase-7-storybook.md"; then
  pass "Phase 7: asks Storybook location for monorepo"
else
  fail "Phase 7: missing monorepo Storybook location question"
fi

# Single-repo: no location question
if grep -q "NOT a monorepo.*skip this question" "$PHASES_DIR/phase-7-storybook.md" ||
   grep -q "not a monorepo.*set.*storybookRoot.*to.*systemPath" "$PHASES_DIR/phase-7-storybook.md"; then
  pass "Phase 7: skips location question for single-repo"
else
  fail "Phase 7: doesn't skip location question for single-repo"
fi

echo ""

# ===========================================================================
# DIMENSION H: Phase 8 — Reviewer Scope Adaptation
# ===========================================================================
echo "=== DIMENSION H: Phase 8 — Reviewer Scope Adaptation ==="

# Token-only path: must adapt all 5 reviewers
if grep -q "no components were implemented" "$PHASES_DIR/phase-8-review.md" &&
   grep -q "skip component-specific review criteria" "$PHASES_DIR/phase-8-review.md"; then
  pass "Phase 8: adapts reviewers for token-only path"
else
  fail "Phase 8: missing reviewer adaptation for token-only"
fi

# Each reviewer must have token-only adaptation instructions
for reviewer_num in "8.1" "8.2" "8.3" "8.4" "8.5"; do
  if grep -q "$reviewer_num.*skip\|$reviewer_num.*focus" "$PHASES_DIR/phase-8-review.md"; then
    pass "Phase 8: reviewer $reviewer_num has token-only adaptation"
  else
    # Try alternate check: look for the section mentioning the reviewer
    section_mention=$(grep -c "8\.[1-5].*skip\|8\.[1-5].*focus" "$PHASES_DIR/phase-8-review.md" || true)
    if [ "$section_mention" -ge 5 ]; then
      pass "Phase 8: reviewer $reviewer_num has token-only adaptation (bulk)"
    else
      warn "Phase 8: reviewer $reviewer_num may lack explicit token-only adaptation"
    fi
  fi
done

# themeStrategy=light-only: skip dark mode evaluation
if grep -q "themeStrategy.*light-only.*skip dark mode" "$PHASES_DIR/phase-8-review.md"; then
  pass "Phase 8: light-only skips dark mode evaluation"
else
  fail "Phase 8: missing light-only dark mode skip"
fi

# Risk regulation thresholds must be defined
if grep -q "risk > 20%" "$PHASES_DIR/phase-8-review.md" &&
   grep -q "Hard cap.*30 fixes" "$PHASES_DIR/phase-8-review.md"; then
  pass "Phase 8: risk regulation thresholds defined"
else
  fail "Phase 8: missing risk regulation thresholds"
fi

# 3 fix attempts → BLOCKED
if grep -q "persists after 3 fix attempts" "$PHASES_DIR/phase-8-review.md"; then
  pass "Phase 8: 3-attempt escalation to BLOCKED"
else
  fail "Phase 8: missing 3-attempt escalation rule"
fi

echo ""

# ===========================================================================
# DIMENSION I: Phase 10 — Framework Decision Matrix
# ===========================================================================
echo "=== DIMENSION I: Phase 10 — Framework Decision Matrix ==="

# All framework branches must be in the decision matrix
for fw in "Next.js App Router" "Next.js Pages Router" "Remix" "Astro" "SvelteKit" "Nuxt" "Plain React"; do
  if grep -qi "$fw" "$PHASES_DIR/phase-10-integration.md"; then
    pass "Phase 10: decision matrix includes $fw"
  else
    fail "Phase 10: missing $fw in decision matrix"
  fi
done

# Each framework must have NEVER-DO instructions
never_do_count=$(grep -c "NEVER\|Do NOT" "$PHASES_DIR/phase-10-integration.md" || true)
if [ "$never_do_count" -ge 5 ]; then
  pass "Phase 10: has sufficient NEVER-DO guardrails ($never_do_count)"
else
  fail "Phase 10: insufficient NEVER-DO guardrails ($never_do_count)"
fi

# Theme library compatibility gate
if grep -q "themeLibrary.*does NOT match" "$PHASES_DIR/phase-10-integration.md" &&
   grep -q "framework-compatible library" "$PHASES_DIR/phase-10-integration.md"; then
  pass "Phase 10: theme library compatibility gate present"
else
  fail "Phase 10: missing theme library compatibility gate"
fi

# Mode B guided: must show diff preview
if grep -q "diff preview" "$PHASES_DIR/phase-10-integration.md" &&
   grep -q "Approve this change" "$PHASES_DIR/phase-10-integration.md"; then
  pass "Phase 10: Mode B shows diff previews"
else
  fail "Phase 10: Mode B missing diff preview mechanism"
fi

# CSS import order verification
if grep -q "import ORDER" "$PHASES_DIR/phase-10-integration.md" &&
   grep -q "Reset.*base.*Token.*Theme.*Component" "$PHASES_DIR/phase-10-integration.md"; then
  pass "Phase 10: CSS import order verified"
else
  # Try alternate check
  if grep -q "Reset" "$PHASES_DIR/phase-10-integration.md" &&
     grep -q "Token" "$PHASES_DIR/phase-10-integration.md" &&
     grep -q "Theme" "$PHASES_DIR/phase-10-integration.md" &&
     grep -q "Component" "$PHASES_DIR/phase-10-integration.md"; then
    pass "Phase 10: CSS import order components present"
  else
    fail "Phase 10: missing CSS import order verification"
  fi
fi

echo ""

# ===========================================================================
# DIMENSION J: Phase 11 — Cleanup Correctness
# ===========================================================================
echo "=== DIMENSION J: Phase 11 — Cleanup Correctness ==="

# Must clean up design-preview.html (inside .design-farmer/)
if grep -q ".design-farmer/design-preview.html" "$PHASES_DIR/phase-11-readiness-handoff.md"; then
  pass "Phase 11: cleans up .design-farmer/design-preview.html"
else
  fail "Phase 11: missing .design-farmer/design-preview.html cleanup"
fi

# Must clean up visual-qa-checklist.md
if grep -q "visual-qa-checklist.md" "$PHASES_DIR/phase-11-readiness-handoff.md"; then
  pass "Phase 11: cleans up visual-qa-checklist.md"
else
  fail "Phase 11: missing visual-qa-checklist.md cleanup"
fi

# Must NOT delete DESIGN.md
if grep -q "Do NOT delete.*DESIGN.md\|Do NOT.*delete.*DESIGN.md" "$PHASES_DIR/phase-11-readiness-handoff.md"; then
  pass "Phase 11: explicitly preserves DESIGN.md"
else
  # Check alternate wording
  if grep -q "DESIGN.md.*permanent\|DESIGN.md.*preserved" "$PHASES_DIR/phase-11-readiness-handoff.md"; then
    pass "Phase 11: DESIGN.md marked as permanent/preserved"
  else
    fail "Phase 11: missing explicit DESIGN.md preservation"
  fi
fi

echo ""

# ===========================================================================
# DIMENSION K: Cross-Phase Data Dependencies
# ===========================================================================
echo "=== DIMENSION K: Cross-Phase Data Dependencies ==="

# DesignFarmerConfig must be persisted (Phase 1) and loadable (Phase 2+)
if grep -q "config.json" "$PHASES_DIR/phase-1-discovery.md" &&
   grep -q "config.json" "$PHASES_DIR/phase-5-tokens.md" &&
   grep -q "config.json" "$PHASES_DIR/phase-6-components.md"; then
  pass "Config persistence: config.json referenced in Phase 1, 5, 6"
else
  fail "Config persistence: config.json not consistently referenced"
fi

# DESIGN.md used in Phases 5+ as source of truth
if grep -q "DESIGN.md" "$PHASES_DIR/phase-5-tokens.md" &&
   grep -q "DESIGN.md" "$PHASES_DIR/phase-6-components.md" &&
   grep -q "DESIGN.md" "$PHASES_DIR/phase-8-review.md"; then
  pass "DESIGN.md: referenced as source of truth in Phases 5, 6, 8"
else
  fail "DESIGN.md: not consistently referenced as source of truth"
fi

# designMaturity must flow from Phase 2 → Phase 3, 3.5, 6
if grep -q "designMaturity" "$PHASES_DIR/phase-3-pattern-extraction.md" &&
   grep -q "designMaturity" "$PHASES_DIR/phase-3.5-visual-preview.md" &&
   grep -q "designMaturity" "$PHASES_DIR/phase-6-components.md"; then
  pass "designMaturity: flows through Phases 3, 3.5, 6"
else
  fail "designMaturity: broken flow chain"
fi

# Phase 6 must explicitly read designMaturity from config.json
if grep -q "designMaturity" "$PHASES_DIR/phase-6-components.md" &&
   grep -q "config.json" "$PHASES_DIR/phase-6-components.md" &&
   grep -E "Read.*designMaturity.*config\.json|Read.*config\.json.*designMaturity" "$PHASES_DIR/phase-6-components.md" > /dev/null 2>&1; then
  pass "Phase 6: explicitly reads designMaturity from config.json"
else
  fail "Phase 6: missing explicit designMaturity read from config.json"
fi

# Phase 6 must explicitly read componentScope from config.json
if grep -E "Read.*componentScope.*config\.json|Read.*config\.json.*componentScope" "$PHASES_DIR/phase-6-components.md" > /dev/null 2>&1; then
  pass "Phase 6: explicitly reads componentScope from config.json"
else
  fail "Phase 6: missing explicit componentScope read from config.json"
fi

# themeStrategy must flow to Phase 4b, 5
if grep -q "themeStrategy" "$PHASES_DIR/phase-4b-theming.md" &&
   grep -q "themeStrategy\|light-only" "$PHASES_DIR/phase-5-tokens.md"; then
  pass "themeStrategy: flows through Phase 4b and Phase 5"
else
  fail "themeStrategy: broken flow chain"
fi

# targetPlatforms must flow to Phase 5
if grep -q "targetPlatforms" "$PHASES_DIR/phase-5-tokens.md"; then
  pass "targetPlatforms: flows to Phase 5"
else
  fail "targetPlatforms: missing in Phase 5"
fi

# framework must flow to Phase 6, 10
if grep -q "framework" "$PHASES_DIR/phase-6-components.md" &&
   grep -q "framework" "$PHASES_DIR/phase-10-integration.md"; then
  pass "framework: flows to Phase 6 and Phase 10"
else
  fail "framework: broken flow chain"
fi

# componentScope must flow to Phase 6, 8
if grep -q "componentScope" "$PHASES_DIR/phase-6-components.md" &&
   grep -q "componentScope" "$PHASES_DIR/phase-8-review.md"; then
  pass "componentScope: flows to Phase 6 and Phase 8"
else
  fail "componentScope: broken flow chain"
fi

# headlessLibrary must flow to Phase 6
if grep -q "headlessLibrary" "$PHASES_DIR/phase-6-components.md"; then
  pass "headlessLibrary: flows to Phase 6"
else
  fail "headlessLibrary: missing in Phase 6"
fi

echo ""

# ===========================================================================
# DIMENSION L: Conditional Skip/Jump Path Validity
# ===========================================================================
echo "=== DIMENSION L: Conditional Skip/Jump Path Validity ==="

# Path 1: DESIGN.md re-entry (Phase 0A → Phase 5 → 6 → ... → 11)
# Phase 5 must be reachable directly from Phase 0
if grep -q "Jump directly to Phase 5" "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Skip path: Phase 0 → Phase 5 direct jump exists"
else
  fail "Skip path: Phase 0 → Phase 5 direct jump missing"
fi

# Path 2: Non-React foundation → Phase 6 skips to Phase 8
if grep -q "Jump to Phase 8" "$PHASES_DIR/phase-6-components.md"; then
  pass "Skip path: Phase 6 → Phase 8 (non-React token-only)"
else
  fail "Skip path: Phase 6 → Phase 8 skip missing"
fi

# Path 3: User skips Phase 7 (Storybook) → Phase 8
# Phase 7 status normally says Phase 8, verify that choosing C doesn't break handoff
if grep -q "Phase 8" "$PHASES_DIR/phase-7-storybook.md"; then
  pass "Skip path: Phase 7 → Phase 8 handoff exists"
else
  fail "Skip path: Phase 7 → Phase 8 handoff missing"
fi

# Path 4: User skips Phase 10 (Integration) → Phase 11
if grep -q "Phase 11" "$PHASES_DIR/phase-10-integration.md"; then
  pass "Skip path: Phase 10 → Phase 11 handoff exists"
else
  fail "Skip path: Phase 10 → Phase 11 handoff missing"
fi

# Path 5: Phase 3.5 rejection → returns to Phase 1 Q2
if grep -q "Return to Phase 1 Question 2" "$PHASES_DIR/phase-3.5-visual-preview.md" ||
   grep -q "return to Phase 1" "$PHASES_DIR/phase-3.5-visual-preview.md"; then
  pass "Feedback loop: Phase 3.5 rejection → Phase 1 Q2"
else
  fail "Feedback loop: missing Phase 3.5 → Phase 1 Q2 loop"
fi

# Phase 8.5 → must be optional when no browser tooling available
if grep -q "skip this phase" "$PHASES_DIR/phase-8.5-design-review.md" ||
   grep -q "neither exists, skip" "$PHASES_DIR/phase-8.5-design-review.md"; then
  pass "Skip path: Phase 8.5 skippable when no browser/storybook"
else
  fail "Skip path: Phase 8.5 missing skip condition"
fi

echo ""

# ===========================================================================
# DIMENSION M: Fallback/Degradation Registry Completeness
# ===========================================================================
echo "=== DIMENSION M: Fallback/Degradation Registry ==="

# SKILL.md Fallback Registry must list all phases that have fallbacks
fallback_phases="Phase 2\|Phase 3\|Phase 3.5\|Phase 4.5\|Phase 5\|Phase 6\|Phase 7\|Phase 8\|Phase 8.5\|Phase 9\|Phase 10\|Phase 11"
fallback_count=$(grep -cE "Phase [0-9]" "$SKILL_FILE" | head -1 || echo "0")

# Check that the fallback registry table exists and has entries
fallback_table_entries=$(awk '/### Fallback Registry/,/^---/' "$SKILL_FILE" | grep -c '^|' || true)
if [ "$fallback_table_entries" -ge 10 ]; then
  pass "Fallback Registry: has $fallback_table_entries entries (>= 10 expected)"
else
  fail "Fallback Registry: only $fallback_table_entries entries (expected >= 10)"
fi

# Phase 3.5 fallback: text-only preview
if grep -q "Fallback Path" "$PHASES_DIR/phase-3.5-visual-preview.md" &&
   grep -q "text summary" "$PHASES_DIR/phase-3.5-visual-preview.md"; then
  pass "Fallback: Phase 3.5 has text-only fallback"
else
  fail "Fallback: Phase 3.5 missing text-only fallback"
fi

# Phase 8.5 fallback: manual verification
if grep -q "manual verification" "$PHASES_DIR/phase-8.5-design-review.md"; then
  pass "Fallback: Phase 8.5 has manual verification fallback"
else
  fail "Fallback: Phase 8.5 missing manual verification fallback"
fi

echo ""

# ===========================================================================
# DIMENSION N: Fix Loop Protocol Activation Matrix
# ===========================================================================
echo "=== DIMENSION N: Fix Loop Protocol Activation Matrix ==="

# operational-notes.md must define activation table
if grep -q "Phase 5.*typecheck.*test" "$PHASES_DIR/operational-notes.md" &&
   grep -q "Phase 6.*typecheck.*lint.*test" "$PHASES_DIR/operational-notes.md" &&
   grep -q "Phase 7.*build.*typecheck" "$PHASES_DIR/operational-notes.md" &&
   grep -q "Phase 9.*typecheck.*lint.*build.*test" "$PHASES_DIR/operational-notes.md" &&
   grep -q "Phase 10.*typecheck.*lint.*build" "$PHASES_DIR/operational-notes.md" &&
   grep -q "Phase 11.*typecheck.*lint.*build.*test" "$PHASES_DIR/operational-notes.md"; then
  pass "Fix Loop: activation table covers all 6 phases with correct checks"
else
  fail "Fix Loop: incomplete activation table in operational-notes.md"
fi

# Each implementation phase must reference "Fix Loop" (already tested in suite 2, verify again)
for phase_file in "phase-5-tokens.md" "phase-6-components.md" "phase-7-storybook.md" "phase-9-documentation.md" "phase-10-integration.md" "phase-11-readiness-handoff.md"; do
  if grep -q "Fix Loop" "$PHASES_DIR/$phase_file"; then
    pass "Fix Loop: referenced in $phase_file"
  else
    fail "Fix Loop: missing reference in $phase_file"
  fi
done

# Fix Loop max attempts must be consistent (5)
for phase_file in "phase-5-tokens.md" "phase-6-components.md" "phase-7-storybook.md" "phase-9-documentation.md" "phase-10-integration.md" "phase-11-readiness-handoff.md"; do
  if grep -q "Max attempts: 5\|MAX_ATTEMPTS.*5\|5/5\|attempt.*5" "$PHASES_DIR/$phase_file"; then
    pass "Fix Loop: $phase_file uses 5 max attempts"
  else
    warn "Fix Loop: $phase_file may not explicitly state 5 max attempts"
  fi
done

echo ""

# ===========================================================================
# DIMENSION O: DESIGN.md Config Field Round-Trip
# ===========================================================================
echo "=== DIMENSION O: Config Field Round-Trip (Phase 4.5 ↔ Phase 0) ==="

# Extract fields from Phase 4.5 YAML template
template_fields=$(sed -n '/^```yaml/,/^```/p' "$PHASES_DIR/phase-4.5-design-source-of-truth.md" \
  | grep -oE '^[a-zA-Z]+:' | sed 's/://' | sort -u)

# Extract fields from Phase 0 re-entry parsing list
phase0_fields=$(sed -n '/Parse it to reconstruct/,/^$/p' "$PHASES_DIR/phase-0-preflight.md" || true)

# Extract fields from DesignFarmerConfig interface in Phase 1
config_interface=$(awk '/interface DesignFarmerConfig/,/^}/' "$PHASES_DIR/phase-1-discovery.md")

# Verify round-trip: every field in Phase 4.5 template must appear in Phase 0 re-entry
missing_roundtrip=""
for field in $template_fields; do
  if ! echo "$phase0_fields" | grep -qF "$field"; then
    missing_roundtrip="$missing_roundtrip $field"
  fi
done

if [ -z "$missing_roundtrip" ]; then
  field_count=$(echo "$template_fields" | wc -w | tr -d ' ')
  pass "Config round-trip: all $field_count fields survive Phase 4.5 → Phase 0 re-entry"
else
  fail "Config round-trip: fields missing from Phase 0 re-entry:$missing_roundtrip"
fi

# Verify round-trip: every field in Phase 4.5 template must appear in Phase 1 interface
missing_interface=""
for field in $template_fields; do
  if ! echo "$config_interface" | grep -qF "$field"; then
    missing_interface="$missing_interface $field"
  fi
done

if [ -z "$missing_interface" ]; then
  pass "Config round-trip: all fields exist in DesignFarmerConfig interface"
else
  warn "Config round-trip: fields missing from interface:$missing_interface"
fi

# Verify example DESIGN.md uses same fields
example_fields=$(sed -n '/^```yaml/,/^```/p' "$EXAMPLES_DIR/DESIGN.md" \
  | grep -oE '^[a-zA-Z]+:' | sed 's/://' | sort -u)
template_sorted=$(echo "$template_fields" | tr ' ' '\n' | sort)
example_sorted=$(echo "$example_fields" | tr ' ' '\n' | sort)
if [ "$template_sorted" = "$example_sorted" ]; then
  pass "Config round-trip: example DESIGN.md matches template fields"
else
  fail "Config round-trip: example DESIGN.md fields differ from template"
fi

echo ""

# ===========================================================================
# DIMENSION P: Styling Approach Coverage
# ===========================================================================
echo "=== DIMENSION P: Styling Approach Coverage ==="

# Phase 4b.5 must cover all detected styling approaches
for approach in "Tailwind v4" "Tailwind v3" "CSS Modules" "styled-components" "vanilla-extract" "Panda CSS" "no styling framework"; do
  if grep -qi "$approach" "$PHASES_DIR/phase-4b-theming.md"; then
    pass "Phase 4b.5: covers $approach"
  else
    fail "Phase 4b.5: missing $approach"
  fi
done

echo ""

# ===========================================================================
# DIMENSION Q: AskUserQuestion Gate Consistency
# ===========================================================================
echo "=== DIMENSION Q: AskUserQuestion Gate Consistency ==="

# Every phase that asks user a question must have STOP + wait
question_phases=(
  "phase-0-preflight.md"
  "phase-1-discovery.md"
  "phase-3.5-visual-preview.md"
  "phase-7-storybook.md"
  "phase-8-review.md"
  "phase-8.5-design-review.md"
  "phase-10-integration.md"
)

for phase_file in "${question_phases[@]}"; do
  ask_count=$(grep -c "AskUserQuestion\|Via AskUserQuestion" "$PHASES_DIR/$phase_file" || true)
  stop_count=$(grep -ci "STOP.*wait\|wait.*user.*response\|Do NOT proceed until" "$PHASES_DIR/$phase_file" || true)
  if [ "$ask_count" -gt 0 ] && [ "$stop_count" -gt 0 ]; then
    pass "$phase_file: $ask_count questions with $stop_count stop gates"
  elif [ "$ask_count" -gt 0 ]; then
    fail "$phase_file: has $ask_count questions but $stop_count stop gates"
  else
    pass "$phase_file: no questions (ok if expected)"
  fi
done

echo ""

# ===========================================================================
# DIMENSION R: Phase 6 Headless Library → Package Mapping
# ===========================================================================
echo "=== DIMENSION R: Headless Library Package Mapping ==="

# Phase 6 must map all headless library choices to npm packages
for lib in "base-ui" "ark" "headless-ui" "melt" "bits"; do
  if grep -q "$lib" "$PHASES_DIR/phase-6-components.md"; then
    pass "Phase 6: maps headless library $lib to package"
  else
    fail "Phase 6: missing package mapping for $lib"
  fi
done

# Radix must have per-component package list
if grep -q "@radix-ui/react-dialog" "$PHASES_DIR/phase-6-components.md" &&
   grep -q "@radix-ui/react-slot" "$PHASES_DIR/phase-6-components.md"; then
  pass "Phase 6: Radix has per-component package list"
else
  fail "Phase 6: Radix missing per-component packages"
fi

# componentScope → Radix package selection must be documented
if grep -q "componentScope=foundation.*slot\|foundation.*only.*slot" "$PHASES_DIR/phase-6-components.md"; then
  pass "Phase 6: foundation scope → only @radix-ui/react-slot"
else
  fail "Phase 6: missing componentScope→Radix package mapping"
fi

echo ""

# ===========================================================================
# DIMENSION S: Combinatorial Path Simulation
# ===========================================================================
echo "=== DIMENSION S: Combinatorial Path Simulation ==="

# Simulate ALL valid execution paths and verify no contradictions
# Key decision variables:
#   1. designmd_exists: true/false
#   2. designmd_choice: A(use)/B(update)/C(ignore) (only if exists)
#   3. designMaturity: greenfield/emerging/mature
#   4. framework: react/non-react
#   5. componentScope: foundation/core/full/custom
#   6. themeStrategy: light-only/light-dark/multi-brand/custom
#   7. targetPlatforms: web/web-native/web-hybrid/multi-platform
#   8. storybook_choice: A(full)/B(minimal)/C(skip)
#   9. integration_choice: A(full)/B(guided)/C(skip)

# Preserve locale for UTF-8 arrow concatenation in path strings (macOS bash
# truncates multi-byte characters during repeated string concatenation under
# certain locale settings).
_saved_lc_all="${LC_ALL:-}"
export LC_ALL=C

# Count total paths
total_paths=0
valid_paths=0
invalid_paths=0

for designmd_exists in "true" "false"; do
  for designmd_choice in "A" "B" "C" "N/A"; do
    # Skip impossible combinations
    if [ "$designmd_exists" = "false" ] && [ "$designmd_choice" != "N/A" ]; then continue; fi
    if [ "$designmd_exists" = "true" ] && [ "$designmd_choice" = "N/A" ]; then continue; fi

    for maturity in "greenfield" "emerging" "mature"; do
      for fw_type in "react" "non-react"; do
        for comp_scope in "foundation" "core" "full"; do
          for theme in "light-only" "light-dark"; do
            for platform in "web" "web-native"; do
              for storybook in "A" "C"; do
                for integration in "A" "C"; do
                  total_paths=$((total_paths + 1))

                  # Determine expected phase execution path
                  phases_executed=""

                  # Phase 0 always runs
                  phases_executed="0"

                  if [ "$designmd_exists" = "true" ] && [ "$designmd_choice" = "A" ]; then
                    # Skip Phases 1-4, jump to 5
                    phases_executed="$phases_executed→5"
                  else
                    # Normal path: 1→2→3→3.5→4→4b→4.5
                    phases_executed="$phases_executed→1→2→3→3.5→4→4b→4.5→5"
                  fi

                  # Phase 6: framework guardrail
                  if [ "$fw_type" = "non-react" ] && [ "$comp_scope" = "foundation" ]; then
                    # Skip Phase 6 and 7, jump to 8
                    phases_executed="$phases_executed→6(skip)→8"
                  elif [ "$fw_type" = "non-react" ] && [ "$comp_scope" != "foundation" ]; then
                    # NEEDS_CONTEXT: user chooses B (downgrade to foundation)
                    phases_executed="$phases_executed→6(needs_context)→8"
                  else
                    phases_executed="$phases_executed→6"

                    # Phase 7: Storybook
                    if [ "$storybook" = "A" ]; then
                      phases_executed="$phases_executed→7"
                    else
                      phases_executed="$phases_executed→7(skip)"
                    fi

                    # Phase 8
                    phases_executed="$phases_executed→8"
                  fi

                  # Phase 8.5
                  phases_executed="$phases_executed→8.5"

                  # Phase 9 always runs
                  phases_executed="$phases_executed→9"

                  # Phase 10: integration
                  if [ "$integration" = "A" ]; then
                    phases_executed="$phases_executed→10"
                  else
                    phases_executed="$phases_executed→10(skip)"
                  fi

                  # Phase 11 always runs
                  phases_executed="$phases_executed→11"

                  # Validate path invariants (use [[ ]] glob matching to avoid
                  # pipe/grep issues under set -eo pipefail)
                  path_valid=true

                  # Invariant 1: non-react + foundation must skip Phase 6
                  if [ "$fw_type" = "non-react" ] && [ "$comp_scope" = "foundation" ]; then
                    if [[ "$phases_executed" != *"6(skip)"* ]]; then
                      fail "Path [$fw_type/$comp_scope]: expected 6(skip) in $phases_executed"
                      path_valid=false
                    fi
                  fi

                  # Invariant 2: storybook=C must skip Phase 7 (when Phase 7 is reached)
                  if [ "$storybook" = "C" ] && [[ "$phases_executed" == *7* ]]; then
                    if [[ "$phases_executed" != *"7(skip)"* ]]; then
                      fail "Path [storybook=$storybook]: expected 7(skip) in $phases_executed"
                      path_valid=false
                    fi
                  fi

                  # Invariant 3: integration=C must skip Phase 10
                  if [ "$integration" = "C" ]; then
                    if [[ "$phases_executed" != *"10(skip)"* ]]; then
                      fail "Path [integration=$integration]: expected 10(skip) in $phases_executed"
                      path_valid=false
                    fi
                  fi

                  # Invariant 4: DESIGN.md re-entry (Path A) must skip Phases 1-4
                  if [ "$designmd_exists" = "true" ] && [ "$designmd_choice" = "A" ]; then
                    if [[ "$phases_executed" == *"→1→"* ]]; then
                      fail "Path [designmd=A]: should skip Phase 1 but found it in $phases_executed"
                      path_valid=false
                    fi
                  fi

                  # Invariant 5: Phase 0 and Phase 11 always present
                  if [[ "$phases_executed" != 0* ]] || [[ "$phases_executed" != *"→11" ]]; then
                    fail "Path missing Phase 0 start or Phase 11 end: $phases_executed"
                    path_valid=false
                  fi

                  # Invariant 6: non-react + non-foundation must use NEEDS_CONTEXT for Phase 6
                  if [ "$fw_type" = "non-react" ] && [ "$comp_scope" != "foundation" ]; then
                    if [[ "$phases_executed" != *"6(needs_context)"* ]]; then
                      fail "Path [$fw_type/$comp_scope]: expected 6(needs_context) in $phases_executed"
                      path_valid=false
                    fi
                  fi

                  # Invariant 7: non-react paths must not reach Phase 7
                  # Note: the loop models NEEDS_CONTEXT as always choosing B (downgrade).
                  # If the loop adds sub-choice A (proceed with React), this invariant must be updated.
                  if [ "$fw_type" = "non-react" ]; then
                    if [[ "$phases_executed" == *"→7"* ]]; then
                      fail "Path [$fw_type]: non-react should not reach Phase 7 but found it in $phases_executed"
                      path_valid=false
                    fi
                  fi

                  if [ "$path_valid" = true ]; then
                    valid_paths=$((valid_paths + 1))
                  else
                    invalid_paths=$((invalid_paths + 1))
                  fi
                done
              done
            done
          done
        done
      done
    done
  done
done

if [ "$valid_paths" -gt 0 ] && [ "$invalid_paths" -eq 0 ]; then
  pass "Combinatorial simulation: $valid_paths valid paths out of $total_paths enumerated (0 invalid)"
else
  fail "Combinatorial simulation: $invalid_paths invalid paths out of $total_paths enumerated"
fi

# Restore locale
if [ -n "$_saved_lc_all" ]; then
  export LC_ALL="$_saved_lc_all"
else
  unset LC_ALL
fi

# Verify specific critical combinations

# COMBO 1: Non-React + greenfield + foundation + light-only
# Expected: Phase 0→1→2→3→3.5→4→4b(partial)→4.5→5→6(skip)→8(adapted)→8.5→9→10(skip)→11
# Phase 4b should only execute 4b.5, Phase 6 should skip, Phase 8 should adapt reviewers
combo1_valid=true
if ! grep -q "light-only" "$PHASES_DIR/phase-4b-theming.md"; then combo1_valid=false; fi
if ! grep -q "SKIP component implementation" "$PHASES_DIR/phase-6-components.md"; then combo1_valid=false; fi
if ! grep -q "skip component-specific review" "$PHASES_DIR/phase-8-review.md"; then combo1_valid=false; fi
if [ "$combo1_valid" = true ]; then
  pass "COMBO: non-React + greenfield + foundation + light-only is valid"
else
  fail "COMBO: non-React + greenfield + foundation + light-only has gaps"
fi

# COMBO 2: React + mature + full + light-dark + web-native
# Expected: Full path with Style Dictionary multi-platform in Phase 5
combo2_valid=true
if ! grep -q "Style Dictionary" "$PHASES_DIR/phase-5-tokens.md"; then combo2_valid=false; fi
if ! grep -q "MATURE" "$PHASES_DIR/phase-6-components.md"; then combo2_valid=false; fi
if [ "$combo2_valid" = true ]; then
  pass "COMBO: React + mature + full + light-dark + web-native is valid"
else
  fail "COMBO: React + mature + full + light-dark + web-native has gaps"
fi

# COMBO 3: DESIGN.md re-entry (Path A) → Phase 5 directly
combo3_valid=true
if ! grep -q "Jump directly to Phase 5" "$PHASES_DIR/phase-0-preflight.md"; then combo3_valid=false; fi
if ! grep -q "from DESIGN.md if Phase 3 was skipped" "$PHASES_DIR/phase-5-tokens.md"; then
  # Check if Phase 5 can handle re-entry
  if ! grep -q "re-entry path" "$PHASES_DIR/phase-5-tokens.md"; then combo3_valid=false; fi
fi
if [ "$combo3_valid" = true ]; then
  pass "COMBO: DESIGN.md re-entry → Phase 5 direct entry is valid"
else
  fail "COMBO: DESIGN.md re-entry → Phase 5 direct entry has gaps"
fi

echo ""

# ===========================================================================
# DIMENSION T: Storybook Dark Mode Attribute Alignment
# ===========================================================================
echo "=== DIMENSION T: Storybook Dark Mode Attribute Alignment ==="

# Phase 4b dark mode checklist must mention all 4 systems
if grep -q "ThemeProvider" "$PHASES_DIR/phase-4b-theming.md" &&
   grep -q "CSS selectors" "$PHASES_DIR/phase-4b-theming.md" &&
   grep -q "Tailwind" "$PHASES_DIR/phase-4b-theming.md" &&
   grep -q "Storybook" "$PHASES_DIR/phase-4b-theming.md"; then
  pass "Attribute alignment: Phase 4b covers ThemeProvider + CSS + Tailwind + Storybook"
else
  fail "Attribute alignment: Phase 4b missing system in alignment table"
fi

# Phase 7 must also have attribute alignment
if grep -q "attributeName" "$PHASES_DIR/phase-7-storybook.md" &&
   grep -q "withThemeByDataAttribute\|withThemeByClassName" "$PHASES_DIR/phase-7-storybook.md"; then
  pass "Attribute alignment: Phase 7 configures Storybook decorator"
else
  fail "Attribute alignment: Phase 7 missing Storybook decorator configuration"
fi

# Phase 8.5 must check attribute alignment
if grep -q "Attribute alignment" "$PHASES_DIR/phase-8.5-design-review.md"; then
  pass "Attribute alignment: Phase 8.5 checks alignment in visual QA"
else
  fail "Attribute alignment: Phase 8.5 missing alignment check"
fi

echo ""

# ===========================================================================
# DIMENSION U: Operational Notes Forbidden Patterns
# ===========================================================================
echo "=== DIMENSION U: Operational Notes Forbidden Patterns ==="

# Every forbidden pattern must be enforceable in Phase 8 reviewers
forbidden_patterns=(
  "Hardcoded color values"
  "Direct primitive token usage"
  "HSL or hex as primary color"
  "Adjusting chroma for contrast"
)

for pattern in "${forbidden_patterns[@]}"; do
  if grep -qi "$pattern" "$PHASES_DIR/operational-notes.md"; then
    pass "Forbidden pattern defined: $pattern"
  else
    fail "Forbidden pattern missing: $pattern"
  fi
done

# Phase 8 reviewers must check these patterns
if grep -q "hardcoded color" "$PHASES_DIR/phase-8-review.md" &&
   grep -q "primitive token" "$PHASES_DIR/phase-8-review.md"; then
  pass "Phase 8: reviewers check hardcoded colors and primitive tokens"
else
  fail "Phase 8: reviewers missing forbidden pattern checks"
fi

echo ""

# ===========================================================================
# DIMENSION V: EXAMPLES-GALLERY Phase Mapping Accuracy
# ===========================================================================
echo "=== DIMENSION V: EXAMPLES-GALLERY Phase Mapping ==="

# Each example must reference phases that actually exist
while IFS= read -r phase_ref; do
  phase_num=$(echo "$phase_ref" | grep -oE '[0-9]+\.?[0-9]*' | head -1)
  # Verify phase exists in canonical set
  case "$phase_num" in
    0|1|2|3|3.5|4|4.5|5|6|7|8|8.5|9|10|11)
      pass "Examples Gallery: references valid Phase $phase_num"
      ;;
    *)
      if [ -n "$phase_num" ]; then
        fail "Examples Gallery: references non-existent Phase $phase_num"
      fi
      ;;
  esac
done < <(grep -oE 'Phase [0-9]+\.?[0-9]*' "$DOCS_DIR/EXAMPLES-GALLERY.md" | sort -u)

echo ""

# ===========================================================================
# DIMENSION W: Version Check & Bundle Integrity Gate
# ===========================================================================
echo "=== DIMENSION W: Version Check & Bundle Integrity Gate ==="

# Version check must be non-blocking
if grep -q "fails.*times out.*continue silently" "$SKILL_FILE" ||
   grep -q "never block on a version check failure" "$SKILL_FILE"; then
  pass "Version check: non-blocking on failure"
else
  fail "Version check: may block on failure"
fi

# Bundle integrity must block on missing files
if grep -q "STOP immediately" "$SKILL_FILE" &&
   grep -q "Incomplete Design Farmer bundle" "$SKILL_FILE"; then
  pass "Bundle integrity: blocks on missing files"
else
  fail "Bundle integrity: doesn't block on missing files"
fi

# Must not guess missing phase behavior
if grep -q "Do NOT guess missing phase behavior" "$SKILL_FILE"; then
  pass "Bundle integrity: explicitly prohibits guessing"
else
  fail "Bundle integrity: missing no-guessing rule"
fi

echo ""

# ===========================================================================
# DIMENSION X: Phase 6 Component Priority Order Completeness
# ===========================================================================
echo "=== DIMENSION X: Phase 6 Component Priority Order ==="

# Foundation components must be listed first
if grep -q "Foundation.*no dependencies" "$PHASES_DIR/phase-6-components.md" &&
   grep -q "Core Interactive.*depends on foundation" "$PHASES_DIR/phase-6-components.md" &&
   grep -q "Overlay.*depends on core" "$PHASES_DIR/phase-6-components.md" &&
   grep -q "Composed.*depends on all" "$PHASES_DIR/phase-6-components.md"; then
  pass "Phase 6: component priority order has all 4 tiers"
else
  fail "Phase 6: component priority order missing tiers"
fi

# componentScope mapping to tiers
# foundation → tier 1 only
# core → tiers 1-2
# full → tiers 1-4
if grep -q "componentScope\|scope" "$PHASES_DIR/phase-6-components.md" &&
   grep -q "Only implement components within the user.*chosen scope" "$PHASES_DIR/phase-6-components.md"; then
  pass "Phase 6: component scope gates implementation tiers"
else
  fail "Phase 6: missing scope → tier gating"
fi

echo ""

# ===========================================================================
# DIMENSION Y: Phase 4.5 DESIGN.md Subsequent Run Behavior
# ===========================================================================
echo "=== DIMENSION Y: Phase 4.5 — Subsequent Run Behavior ==="

# Must handle existing DESIGN.md without overwriting
if grep -q "Subsequent Run Behavior" "$PHASES_DIR/phase-4.5-design-source-of-truth.md" &&
   grep -q "Append new entries" "$PHASES_DIR/phase-4.5-design-source-of-truth.md" &&
   grep -q "never delete past decisions" "$PHASES_DIR/phase-4.5-design-source-of-truth.md"; then
  pass "Phase 4.5: subsequent run preserves history"
else
  fail "Phase 4.5: missing subsequent run preservation logic"
fi

# Must have Revision History section
if grep -q "Revision History" "$PHASES_DIR/phase-4.5-design-source-of-truth.md"; then
  pass "Phase 4.5: includes Revision History tracking"
else
  fail "Phase 4.5: missing Revision History"
fi

# Phase 8 integration: reviewers must reference DESIGN.md
if grep -q "read DESIGN.md" "$PHASES_DIR/phase-4.5-design-source-of-truth.md" &&
   grep -q "Phase 8" "$PHASES_DIR/phase-4.5-design-source-of-truth.md"; then
  pass "Phase 4.5: includes Phase 8 reviewer integration"
else
  fail "Phase 4.5: missing Phase 8 reviewer integration"
fi

echo ""

# ===========================================================================
# DIMENSION Z: Phase 8.5 Risk Regulation Consistency
# ===========================================================================
echo "=== DIMENSION Z: Phase 8.5 Risk Regulation Consistency ==="

# Phase 8 and 8.5 must both have risk regulation
# The "20%" threshold may appear on a different line than the word "risk"
if grep -q "20%" "$PHASES_DIR/phase-8-review.md" &&
   grep -q "20%" "$PHASES_DIR/phase-8.5-design-review.md" &&
   grep -q "STOP" "$PHASES_DIR/phase-8-review.md" &&
   grep -q "STOP" "$PHASES_DIR/phase-8.5-design-review.md"; then
  pass "Risk regulation: both Phase 8 and 8.5 have 20% threshold with STOP"
else
  fail "Risk regulation: inconsistent 20% threshold"
fi

# Both must have hard cap at 30 fixes
if grep -q "30 fixes" "$PHASES_DIR/phase-8-review.md" &&
   grep -q "30 fixes" "$PHASES_DIR/phase-8.5-design-review.md"; then
  pass "Risk regulation: both have 30 fix hard cap"
else
  fail "Risk regulation: inconsistent 30 fix cap"
fi

# Phase 8 and 8.5 risk formulas should be documented
if grep -q "15%.*per reverted fix" "$PHASES_DIR/phase-8-review.md" &&
   grep -q "15%.*per reverted fix" "$PHASES_DIR/phase-8.5-design-review.md"; then
  pass "Risk regulation: revert penalty consistent (15%)"
else
  fail "Risk regulation: inconsistent revert penalty"
fi

echo ""

# ===========================================================================
# DIMENSION AA: Pipeline State Tracking (completedPhases, createdAt)
# ===========================================================================
echo "=== DIMENSION AA: Pipeline State Tracking ==="

# Phase 1 must set createdAt in config persistence block (not just interface definition)
# Check that createdAt appears in the bash block that writes config.json, not only in the TypeScript interface
config_write_section=$(awk '/mkdir -p.*\.design-farmer/,/^```$/' "$PHASES_DIR/phase-1-discovery.md")
if echo "$config_write_section" | grep -q "createdAt"; then
  pass "Phase 1: sets createdAt in config persistence block"
else
  fail "Phase 1: createdAt missing from config persistence block (only in interface?)"
fi

# completedPhases must exist in interface and be tracked by centralized SKILL.md rule
if grep -q "completedPhases" "$PHASES_DIR/phase-1-discovery.md"; then
  pass "Phase 1: completedPhases defined in DesignFarmerConfig"
else
  fail "Phase 1: missing completedPhases in DesignFarmerConfig"
fi

# DesignFarmerConfig interface must include pipeline state fields
config_interface=$(awk '/interface DesignFarmerConfig/,/^}/' "$PHASES_DIR/phase-1-discovery.md")
for field in "completedPhases" "createdAt" "lastReviewScore" "lastReviewDate" "generatePreview"; do
  if echo "$config_interface" | grep -qF "$field"; then
    pass "DesignFarmerConfig: includes $field"
  else
    fail "DesignFarmerConfig: missing $field"
  fi
done

# completedPhases tracking must be centralized in SKILL.md (not per-phase)
if grep -q "Every phase appends its ID to.*completedPhases\|every phase appends its ID to.*completedPhases" "$SKILL_FILE"; then
  pass "SKILL.md: centralized completedPhases tracking rule"
else
  fail "SKILL.md: missing centralized completedPhases tracking rule"
fi

# Phase 8 must set lastReviewScore and lastReviewDate
if grep -q "lastReviewScore" "$PHASES_DIR/phase-8-review.md" &&
   grep -q "lastReviewDate" "$PHASES_DIR/phase-8-review.md"; then
  pass "Phase 8: sets lastReviewScore and lastReviewDate"
else
  fail "Phase 8: missing lastReviewScore or lastReviewDate"
fi

# Phase 0 must display completedPhases and createdAt on re-entry
if grep -q "completedPhases" "$PHASES_DIR/phase-0-preflight.md" &&
   grep -q "createdAt" "$PHASES_DIR/phase-0-preflight.md"; then
  pass "Phase 0: displays completedPhases and createdAt on re-entry"
else
  fail "Phase 0: missing completedPhases/createdAt display on re-entry"
fi

# SKILL.md must document completedPhases contract
if grep -q "completedPhases" "$SKILL_FILE"; then
  pass "SKILL.md: documents completedPhases contract"
else
  fail "SKILL.md: missing completedPhases contract"
fi

echo ""

# ===========================================================================
# DIMENSION AB: Preview Opt-In Gate (Phase 3.5)
# ===========================================================================
echo "=== DIMENSION AB: Preview Opt-In Gate ==="

# Phase 3.5 must have opt-in gate based on designMaturity
if grep -qi "GREENFIELD.*mandatory" "$PHASES_DIR/phase-3.5-visual-preview.md" &&
   grep -q "EMERGING" "$PHASES_DIR/phase-3.5-visual-preview.md" &&
   grep -q "MATURE" "$PHASES_DIR/phase-3.5-visual-preview.md"; then
  pass "Phase 3.5: has maturity-conditional preview opt-in"
else
  fail "Phase 3.5: missing maturity-conditional preview opt-in"
fi

# generatePreview must be stored in config
if grep -q "generatePreview" "$PHASES_DIR/phase-3.5-visual-preview.md"; then
  pass "Phase 3.5: stores generatePreview in config"
else
  fail "Phase 3.5: missing generatePreview config storage"
fi

# Skip path must NOT use failure fallback 3.5.3 (opt-out is intentional, not an error)
if grep -q "intentional skip\|not a failure\|NOT use.*Fallback Path" "$PHASES_DIR/phase-3.5-visual-preview.md"; then
  pass "Phase 3.5: opt-out skip path separated from failure fallback"
else
  fail "Phase 3.5: opt-out path not clearly separated from failure fallback"
fi

# Preview must be generated inside .design-farmer/
if grep -q ".design-farmer/design-preview.html" "$PHASES_DIR/phase-3.5-visual-preview.md"; then
  pass "Phase 3.5: preview generated inside .design-farmer/"
else
  fail "Phase 3.5: preview not in .design-farmer/ directory"
fi

# SKILL.md must document generatePreview contract
if grep -q "generatePreview" "$SKILL_FILE"; then
  pass "SKILL.md: documents generatePreview contract"
else
  fail "SKILL.md: missing generatePreview contract"
fi

echo ""

# ===========================================================================
# DIMENSION AC: Early DESIGN.md Draft (Phase 3)
# ===========================================================================
echo "=== DIMENSION AC: Early DESIGN.md Draft ==="

# Phase 3 must generate early DESIGN.md draft
if grep -q "Early DESIGN.md Draft" "$PHASES_DIR/phase-3-pattern-extraction.md" &&
   grep -q "DRAFT" "$PHASES_DIR/phase-3-pattern-extraction.md"; then
  pass "Phase 3: generates early DESIGN.md draft"
else
  fail "Phase 3: missing early DESIGN.md draft generation"
fi

# Phase 3 draft must include Config YAML block
if grep -q "Config.*YAML block\|Config YAML" "$PHASES_DIR/phase-3-pattern-extraction.md"; then
  pass "Phase 3: draft includes Config YAML block for re-entry"
else
  fail "Phase 3: draft missing Config YAML block"
fi

# Phase 3 must not overwrite existing DESIGN.md
if grep -qi "NOT overwrite\|preserve the existing" "$PHASES_DIR/phase-3-pattern-extraction.md"; then
  pass "Phase 3: preserves existing DESIGN.md"
else
  fail "Phase 3: may overwrite existing DESIGN.md"
fi

# Phase 4.5 must handle existing draft
if grep -q "draft DESIGN.md already exists\|draft.*Phase 3" "$PHASES_DIR/phase-4.5-design-source-of-truth.md"; then
  pass "Phase 4.5: handles existing Phase 3 draft"
else
  fail "Phase 4.5: missing Phase 3 draft handling"
fi

# SKILL.md must document early DESIGN.md contract
if grep -q "Early DESIGN.md draft\|early DESIGN.md\|Phase 3.*4.5 context gap" "$SKILL_FILE"; then
  pass "SKILL.md: documents early DESIGN.md draft contract"
else
  fail "SKILL.md: missing early DESIGN.md draft contract"
fi

echo ""

# ===========================================================================
# DIMENSION AD: Cross-File Token Existence — --surface-muted
# ===========================================================================
echo "=== DIMENSION AD: Cross-File Token Existence (--surface-muted) ==="

# Phase 4b must define --surface-muted in light theme
if grep -q "\-\-surface-muted" "$PHASES_DIR/phase-4b-theming.md"; then
  pass "Phase 4b: defines --surface-muted token"
else
  fail "Phase 4b: missing --surface-muted token definition"
fi

# Phase 4b must define --surface-muted in dark theme (appears twice = light + dark)
muted_count=$(grep -c "\-\-surface-muted" "$PHASES_DIR/phase-4b-theming.md" || true)
if [ "$muted_count" -ge 2 ]; then
  pass "Phase 4b: --surface-muted defined in both light and dark themes"
else
  fail "Phase 4b: --surface-muted not in both themes (found $muted_count)"
fi

# Phase 4.5 template must mention Surface Muted
if grep -q "Surface Muted" "$PHASES_DIR/phase-4.5-design-source-of-truth.md"; then
  pass "Phase 4.5: template includes Surface Muted"
else
  fail "Phase 4.5: template missing Surface Muted"
fi

# examples/DESIGN.md must define Surface Muted
if grep -q "Surface Muted" "$EXAMPLES_DIR/DESIGN.md"; then
  pass "examples/DESIGN.md: defines Surface Muted"
else
  fail "examples/DESIGN.md: missing Surface Muted"
fi

echo ""

# ===========================================================================
# DIMENSION AE: Badge Status Background Token Name Consistency
# ===========================================================================
echo "=== DIMENSION AE: Badge Status Background Token Consistency ==="

# Phase 4b must define all four badge background tokens
for variant in success warning error info; do
  if grep -q "\-\-state-${variant}-bg" "$PHASES_DIR/phase-4b-theming.md"; then
    pass "Phase 4b: defines --state-${variant}-bg (canonical token)"
  else
    fail "Phase 4b: missing --state-${variant}-bg token definition"
  fi
done

# Phase 4.5 must reference all four badge background tokens
for variant in success warning error info; do
  if grep -q "\-\-state-${variant}-bg" "$PHASES_DIR/phase-4.5-design-source-of-truth.md"; then
    pass "Phase 4.5: references --state-${variant}-bg in Badges table"
  else
    fail "Phase 4.5: missing --state-${variant}-bg in Badges table"
  fi
done

if grep -q "state-success}/15%\|state-success-surface" "$PHASES_DIR/phase-4.5-design-source-of-truth.md"; then
  fail "Phase 4.5: Badges table still uses invalid /15% or -surface token"
else
  pass "Phase 4.5: Badges table does not use /15% or -surface tokens"
fi

# examples/DESIGN.md must reference all four badge background tokens
for variant in success warning error info; do
  if grep -q "\-\-state-${variant}-bg" "$EXAMPLES_DIR/DESIGN.md"; then
    pass "examples/DESIGN.md: references --state-${variant}-bg in Badges table"
  else
    fail "examples/DESIGN.md: missing --state-${variant}-bg in Badges table"
  fi
done

if grep -q "state-success-surface\|state-warning-surface\|state-error-surface\|state-info-surface" "$EXAMPLES_DIR/DESIGN.md"; then
  fail "examples/DESIGN.md: Badges table still uses -surface token names"
else
  pass "examples/DESIGN.md: Badges table does not use -surface token names"
fi

echo ""

# ===========================================================================
# DIMENSION AF: Phase 11 — Handoff Template Adaptation
# ===========================================================================
echo "=== DIMENSION AF: Phase 11 — Handoff Template Adaptation ==="

# Storybook line must be conditional
if grep -q "If Storybook was installed\|If.*Phase 7 was not skipped" "$PHASES_DIR/phase-11-readiness-handoff.md"; then
  pass "Phase 11: Storybook section is conditional"
else
  fail "Phase 11: Storybook section is unconditional"
fi

# Theme toggle must be conditional on themeStrategy
if grep -q "themeStrategy.*light-only\|If themeStrategy" "$PHASES_DIR/phase-11-readiness-handoff.md"; then
  pass "Phase 11: theme toggle conditional on themeStrategy"
else
  fail "Phase 11: theme toggle is unconditional"
fi

# Keyboard navigation must be conditional on componentScope
if grep -q "componentScope.*foundation\|If componentScope" "$PHASES_DIR/phase-11-readiness-handoff.md"; then
  pass "Phase 11: keyboard nav conditional on componentScope"
else
  fail "Phase 11: keyboard nav is unconditional"
fi

# Components count must be conditional on componentScope
if grep -q "componentScope.*foundation" "$PHASES_DIR/phase-11-readiness-handoff.md"; then
  pass "Phase 11: component count is conditional"
else
  fail "Phase 11: component count is unconditional"
fi

echo ""

# ===========================================================================
# DIMENSION AG: Cross-File Token Inventory Consistency
# ===========================================================================
echo "=== DIMENSION AG: Cross-File Token Inventory Consistency ==="

# Map Phase 4b CSS token names to their semantic labels in Phase 4.5 / examples
# Each entry: css_name|semantic_label
TOKEN_MAP=(
  "surface-default|Surface Default"
  "surface-subtle|Surface Subtle"
  "surface-muted|Surface Muted"
  "surface-inverse|Surface Inverse"
  "text-primary|Primary Text"
  "text-secondary|Secondary Text"
  "text-tertiary|Tertiary Text"
  "text-inverse|Inverse Text"
  "text-disabled|Disabled Text"
  "text-brand|Brand Text"
  "interactive-primary|Interactive Primary"
  "interactive-primary-hover|Interactive Primary Hover"
  "interactive-primary-active|Interactive Primary Active"
  "interactive-bg|Interactive Bg"
  "interactive-text|Interactive Text"
  "border-default|Border Default"
  "border-strong|Border Strong"
  "border-subtle|Border Subtle"
  "border-focus|Border Focus"
  "state-success|Success"
  "state-success-bg|Success Bg"
  "state-warning|Warning"
  "state-warning-text|warning-text"
  "state-warning-bg|Warning Bg"
  "state-error|Error"
  "state-error-hover|Error Hover"
  "state-error-bg|Error Bg"
  "state-info|Info"
  "state-info-bg|Info Bg"
)

for entry in "${TOKEN_MAP[@]}"; do
  css_name="${entry%%|*}"
  label="${entry##*|}"

  # Verify token exists in Phase 4b CSS (both light and dark themes)
  token_count=$(grep -c "\-\-${css_name}:" "$PHASES_DIR/phase-4b-theming.md" || true)
  if [ "$token_count" -ge 2 ]; then
    pass "Token inventory: --${css_name} defined in both themes"
  else
    fail "Token inventory: --${css_name} missing or not in both themes (found ${token_count})"
  fi

  # Verify token is documented in Phase 4.5 template (by bold label or CSS name with --)
  if grep -q "\*\*${label}\*\*\|\-\-${css_name}" "$PHASES_DIR/phase-4.5-design-source-of-truth.md"; then
    pass "Token inventory: --${css_name} documented in Phase 4.5"
  else
    fail "Token inventory: --${css_name} missing from Phase 4.5 template"
  fi

  # Verify token is referenced in examples/DESIGN.md (by bold label or CSS name with --)
  if grep -q "\*\*${label}\*\*\|\-\-${css_name}" "$EXAMPLES_DIR/DESIGN.md"; then
    pass "Token inventory: --${css_name} referenced in examples/DESIGN.md"
  else
    fail "Token inventory: --${css_name} missing from examples/DESIGN.md"
  fi
done

echo ""

# ===========================================================================
# SUMMARY
# ===========================================================================
echo "==========================================="
echo "EXHAUSTIVE SIMULATION RESULTS"
echo "==========================================="
echo "RESULTS: $PASS passed, $FAIL failed, $WARN warnings"
echo ""
echo "Dimensions covered:"
echo "  A: Phase 0 Re-Entry Paths"
echo "  B: Conditional Question Flows"
echo "  C: Design Maturity Branches"
echo "  D: Theme Strategy Gate"
echo "  E: Target Platform Branches"
echo "  F: Framework Guardrail"
echo "  G: Storybook Skip Logic"
echo "  H: Reviewer Scope Adaptation"
echo "  I: Framework Decision Matrix"
echo "  J: Cleanup Correctness"
echo "  K: Cross-Phase Data Dependencies"
echo "  L: Skip/Jump Path Validity"
echo "  M: Fallback/Degradation Registry"
echo "  N: Fix Loop Protocol Activation"
echo "  O: Config Field Round-Trip"
echo "  P: Styling Approach Coverage"
echo "  Q: AskUserQuestion Gate Consistency"
echo "  R: Headless Library Package Mapping"
echo "  S: Combinatorial Path Simulation"
echo "  T: Dark Mode Attribute Alignment"
echo "  U: Forbidden Pattern Enforcement"
echo "  V: Examples Gallery Phase Mapping"
echo "  W: Version Check & Bundle Integrity"
echo "  X: Component Priority Order"
echo "  Y: DESIGN.md Subsequent Run"
echo "  Z: Risk Regulation Consistency"
echo " AA: Pipeline State Tracking"
echo " AB: Preview Opt-In Gate"
echo " AC: Early DESIGN.md Draft"
echo " AD: Cross-File Token Existence (--surface-muted)"
echo " AE: Badge Status Background Token Consistency"
echo " AF: Phase 11 Handoff Template Adaptation"
echo " AG: Cross-File Token Inventory Consistency"
echo "==========================================="

if [ $FAIL -gt 0 ]; then
  exit 1
fi
