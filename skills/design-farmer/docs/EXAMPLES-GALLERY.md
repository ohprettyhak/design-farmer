# Design Farmer Examples Gallery

This gallery shows concrete, end-to-end outcomes from common repository states.
Each example includes before/after snapshots, execution context, and where it maps to the canonical phase flow in `../SKILL.md`.

## How to read these examples

- **Context**: Initial project condition.
- **Steps**: What Design Farmer does (phase-oriented).
- **Before** / **After**: Observable transformation.
- **Phase Mapping**: Most relevant phase anchors.

---

## 1) No design system → baseline token foundation

### Context

Small product repo with scattered hex values (`#3b82f6`, `#ef4444`) and ad-hoc spacing values across components.

### Steps

1. Run discovery + repository analysis to inventory color and spacing usage.
2. Convert detected colors to OKLCH primitives.
3. Introduce semantic tokens for text, surface, border, and action roles.

### Before

- Color usage duplicated in component-level CSS.
- No semantic naming (`primary-500` exists in one file, `brandBlue` in another).
- Accessibility contrast checks are inconsistent.

### After

- Primitive + semantic token hierarchy established.
- Color system normalized in OKLCH with consistent scales.
- Contrast validation integrated as part of quality gates.

### Phase Mapping

- Phase 2: Repository Analysis
- Phase 3: Design Pattern Extraction & OKLCH Conversion
- Phase 5: Token Implementation

---

## 2) Partial system → semantic gap closure

### Context

Existing token file defines spacing and brand colors, but interactive states (`hover`, `focus`, `disabled`) and status roles are missing.

### Steps

1. Audit current token inventory and identify missing semantic roles.
2. Add state-aware semantic tokens without breaking existing references.
3. Verify downstream component usage and contrast stability.

### Before

- Components implement local fallback colors for states.
- Disabled and error states differ by feature team conventions.

### After

- Shared semantic states are available across components.
- Component styles consume design-system tokens only.
- Cross-screen behavior is predictable under theme changes.

### Phase Mapping

- Phase 2: Repository Analysis
- Phase 4: Architecture Design
- Phase 5: Token Implementation

---

## 3) Core UI primitives only → accessible interactive set

### Context

Project has visual primitives but lacks accessible interactive building blocks for forms and dialogs.

### Steps

1. Select component scope (`core` or `full`) and headless strategy.
2. Implement Button, Input, Select, Dialog with keyboard/focus behavior.
3. Add interaction tests and visual docs.

### Before

- Form controls behave inconsistently across screens.
- Keyboard navigation and focus ring behavior are not standardized.

### After

- Interactive components ship with consistent a11y behavior.
- Focus handling, ARIA state, and interaction contracts are repeatable.
- Consumer teams compose screens with shared primitives.

### Phase Mapping

- Phase 1: Discovery Interview
- Phase 6: Component Implementation
- Phase 7: Storybook Integration

---

## 4) Light-only UI → dual-theme system

### Context

Product ships only a light theme, and dark mode requests are blocked by hardcoded palette assumptions.

### Steps

1. Define theme strategy (light + dark).
2. Generate dark theme via OKLCH-aware lightness/chroma adjustments.
3. Wire `data-theme` switching and validate contrast in both modes.

### Before

- Dark mode causes low-contrast text/background combinations.
- Theme switching requires per-component overrides.

### After

- Theme tokens support light and dark from the same semantic contract.
- Components read role-based tokens instead of fixed color values.
- Contrast regressions are caught earlier by phase quality checks.

### Phase Mapping

- Phase 3: Design Pattern Extraction & OKLCH Conversion
- Phase 4: Architecture Design
- Phase 4b: Theme & Styling
- Phase 5: Token Implementation

---

## 5) Production-ready claim → verification hardening

### Context

Team believes design system is complete, but visual drift and token misuse appear during new feature delivery.

### Steps

1. Run full verification flow with quality gates and multi-reviewer pass.
2. Identify drift risks (naming violations, local hardcoded values, a11y gaps).
3. Produce remediation notes and completion status (`DONE` / `DONE_WITH_CONCERNS`).

### Before

- "Looks good" approvals without explicit evidence.
- Hidden inconsistencies discovered late in QA.

### After

- Completion includes reproducible evidence and risk callouts.
- Release decisions are tied to explicit pass/fail criteria.
- Ongoing maintenance has a clear anti-drift reference point.

### Phase Mapping

- Phase 8: Multi-Reviewer Verification
- Phase 8.5: Design Review (Live Visual QA)
- Phase 9: Documentation & Completion

---

## Quick phase-to-example index

| Example | Primary Need | Key Phases |
|---|---|---|
| 1 | Start from scratch | 2, 3, 5 |
| 2 | Fill semantic gaps | 2, 4, 5 |
| 3 | Build accessible interactions | 1, 6, 7 |
| 4 | Add dark mode safely | 3, 4, 5 |
| 5 | Harden production quality | 8, 8.5, 9 |
