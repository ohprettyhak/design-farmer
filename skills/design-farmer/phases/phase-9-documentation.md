# Phase 9: Documentation & Completion

Check if `DESIGN.md` exists at `{systemPath}/DESIGN.md` before reading. If missing, emit **Status: BLOCKED** — DESIGN.md not found at `{systemPath}/DESIGN.md`. Recovery: re-run Phase 4.5 to generate the design source of truth, or restore from a backup if available.

Read `DESIGN.md` from Phase 4.5 to calibrate documentation content against the approved design decisions. All token names, component APIs, and theme values in the generated documentation must match the DESIGN.md source of truth.

## 9.1 Generate Documentation

Create documentation at `{systemPath}/docs/` or inline in source:

```
- README.md: Getting started, installation, usage
- TOKENS.md: Token naming conventions, usage rules, adding new tokens
- COMPONENTS.md: Component API reference, variant guide, accessibility notes
- THEMING.md: Theme creation, customization, dark mode setup
- CONTRIBUTING.md: How to add components, testing requirements, review process
```

## 9.2 Final Verification

```bash
# Run all tests
{packageManager} test

# Type check
{packageManager} run typecheck  # or npx tsc --noEmit

# Lint
{packageManager} run lint

# Build (if applicable)
{packageManager} run build

# Storybook build (if installed)
{packageManager} run build-storybook
```

Run the **Fix Loop Protocol** (see `operational-notes.md`) with the full check suite:

```
Checks: typecheck, lint, build, test
Max attempts: 5
```

All must pass with zero errors before declaring completion.

## 9.3 Completion Report

```
## Design Farmer — Completion Report

### System Overview
- Location: {systemPath}
- Components: {count} implemented
- Tokens: {count} primitive, {count} semantic, {count} component
- Themes: {light/dark/multi-brand}
- Tests: {count} total ({count} unit, {count} a11y, {count} snapshot)
- Storybook: {yes/no}

### Color System
- Color space: OKLCH
- Palettes: {count} hue palettes, 11 steps each (50–950)
- Contrast: APCA validated, all pairs meet Lc 60+ threshold
- Gamut: sRGB safe with P3 enhancement where supported

### Reviewer Verdicts
- Critic: {PASS/FAIL} ({score}/10 average)
- Code Reviewer: {findings summary}
- Scientist: {data validation summary}
- Designer: {grade}
- Design Engineer: {APPROVED/APPROVED_WITH_CHANGES}

### Pipeline Degradations
- List one bullet per degradation in the format: `{Phase}: {primary_path} failed ({reason}) → {fallback_path}`
- If no degradations occurred, write: `- None`

### Visual QA Status
Read `visualQAMode` from `{systemPath}/.design-farmer/config.json` to determine visual QA status:
- If `visualQAMode = 'manual'`: include "Visual QA: completed via manual verification (degraded mode)"
- If `visualQAMode = 'skipped'` or `visualQASkipped = true`: include "Visual QA: skipped (no dev server or Storybook available)"
- If `visualQAMode = 'auto'` or undefined: include "Visual QA: automated verification passed"

### Next Steps
See Phase 10 (App Integration) to wire the design system into your application.
```

Before emitting status, ensure `completedPhases` exists in config.json (initialize as `[]` if undefined). If `'phase-9'` is already present in the array, skip the append (idempotent). Otherwise, append `'phase-9'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Also update `config.backup.json`.

**Status: DONE** — Documentation generated and final verification passed. Design system is production-ready. Proceed to Phase 10: App Integration (optional).
