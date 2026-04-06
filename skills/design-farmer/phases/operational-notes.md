# Operational Notes

## Agent Delegation Strategy

Use the closest available specialist in your environment. Do not assume these labels map
to literal built-in agents; tooling names and delegation APIs vary by runtime.

| Task | Preferred capability | Effort |
|------|----------------------|--------|
| Codebase scanning | Repository exploration specialist | Low |
| Pattern analysis | Design-system analysis specialist | Medium |
| Token implementation | Implementation specialist | Medium |
| Component implementation | Implementation specialist | Medium |
| Test writing | Test-focused specialist | Medium |
| Storybook setup | Documentation/setup specialist | Medium |
| Architecture review | Architecture reviewer | High |
| Critical review | Skeptical reviewer | High |
| Code review | Code reviewer | Medium |
| Design review | Visual/design reviewer | Medium |
| Documentation | Documentation specialist | Low |

## Escalation Rules

- Stop after 3 failed attempts at the same task and report to user.
- If a component requires a pattern not covered by the token system, add the token first.
- If OKLCH conversion produces an out-of-gamut color, fall back to maximum in-gamut chroma.
- If the user's existing codebase uses a fundamentally incompatible pattern, ask before overriding.

## OKLCH Quick Reference

```
Format: oklch(L C H / alpha)
L (Lightness): 0 (black) to 1 (white)
C (Chroma):    0 (gray) to ~0.4 (most vivid)
H (Hue):       0-360 degrees

Key hue ranges:
  0-30:    Red
  30-90:   Orange to Yellow
  90-150:  Yellow-Green to Green
  150-210: Green to Cyan
  210-270: Cyan to Blue
  270-330: Blue to Purple
  330-360: Purple to Red

Contrast rules (APCA):
  Light bg (L > 0.85): fg L <= 0.45
  Dark bg  (L < 0.25): fg L >= 0.75

  APCA thresholds vary by font size and weight — Lc 60/75 are NOT universal:

  | Text category         | Size       | Weight | Min Lc (pass) | Preferred Lc |
  |-----------------------|------------|--------|---------------|--------------|
  | Large display / hero  | ≥ 36px     | any    | Lc 45         | Lc 60        |
  | UI labels / headings  | 24–35px    | any    | Lc 55         | Lc 68        |
  | Body text (default)   | 16–23px    | 400+   | Lc 60         | Lc 75        |
  | Small / caption       | 14–15px    | 400    | Lc 75         | Lc 90        |
  | Small / caption       | 14–15px    | 700    | Lc 60         | Lc 75        |
  | Minimum readable      | ≤ 13px     | any    | Lc 90         | avoid        |

  Rule: NEVER adjust chroma for contrast — only modify the L channel.
  Rule: Re-validate APCA after every theme inversion (dark mode).
  Reference: https://www.myndex.com/APCA/ (APCA Readability Criterion)

  ⚠️  Legal note: APCA is a WCAG 3.0 Working Draft algorithm, not yet a W3C standard.
  For legally required accessibility (ADA, EN 301 549), also verify WCAG 2.x 4.5:1 (body)
  and 3:1 (large text ≥ 18pt or 14pt bold). APCA Lc 60 ≠ WCAG 2.x 4.5:1.

Gamut safety:
  sRGB:      reduce C while keeping L and H
  Display P3: ~35% more chroma for greens/cyans, ~10% for blues
  Fallback:  @media (color-gamut: p3) { ... }

Browser support: Baseline 2023, 96%+ global coverage
```

## Token Naming Convention

```
Primitive:  {category}.{hue}.{step}         -> color.blue.500
Semantic:   {role}.{variant}                -> text.primary, surface.inverse
Component:  {component}.{part}.{state}      -> button.background.hover
```

## Fix Loop Protocol

Implementation and verification phases (5, 6, 7, 9, 10, 11) generate or validate code that must compile, lint, and pass tests.
Errors are expected — especially during integration. This protocol defines a built-in retry
loop that keeps fixing until all checks pass, without requiring external plugins or tools.

### Loop Structure

```
MAX_ATTEMPTS = 5

for attempt in 1..MAX_ATTEMPTS:
  1. RUN all applicable checks:
     - typecheck:  {packageManager} run typecheck  (or tsc --noEmit)
     - lint:       {packageManager} run lint        (if configured)
     - build:      {packageManager} run build       (if applicable)
     - test:       {packageManager} run test        (if tests exist for changed files)

  2. READ the full error output. Do not skip or summarize.

  3. If ALL checks pass (exit code 0):
     → BREAK — emit "Fix Loop: PASSED on attempt {attempt}/{MAX_ATTEMPTS}"
     → Continue to next phase step

  4. If ANY check fails:
     a. CATEGORIZE each error:
        - TYPE_ERROR:  TypeScript type mismatch, missing export, wrong import path
        - LINT_ERROR:  ESLint/Biome rule violation, unused variable, formatting
        - BUILD_ERROR: Module resolution, missing dependency, config issue
        - TEST_ERROR:  Assertion failure, snapshot mismatch, missing mock

     b. FIX errors in priority order:
        BUILD_ERROR > TYPE_ERROR > LINT_ERROR > TEST_ERROR
        (Build errors often cascade into type errors; fix root cause first)

     c. APPLY fixes directly — do not ask the user for permission on
        mechanical fixes (import paths, missing exports, type annotations).
        DO ask before changing component APIs, test assertions, or config files.

     d. Log: "Fix Loop: attempt {attempt}/{MAX_ATTEMPTS} — fixed {count} errors ({categories})"

  5. If attempt == MAX_ATTEMPTS and checks still fail:
     → STOP — emit BLOCKED status:
       "Fix Loop: FAILED after {MAX_ATTEMPTS} attempts.
        Remaining errors: {count} ({category breakdown})
        Last error output: {paste truncated output}
        AskUserQuestion: These errors could not be auto-resolved. Options:
        - A) Show me the full error log — I'll fix it manually
        - B) Skip this check and continue (I'll fix later)
        - C) Increase attempts and keep trying"
     → Wait for user response before continuing.
```

### When to Activate

The fix loop activates automatically at these checkpoints:

| Phase | Checkpoint | Checks to Run |
|-------|-----------|---------------|
| Phase 5 (Tokens) | After token files + tests written | typecheck, test |
| Phase 6 (Components) | After EACH component implemented | typecheck, lint, test |
| Phase 6 (Components) | After ALL components done | typecheck, lint, test (full suite) |
| Phase 7 (Storybook) | After storybook config + stories | build (storybook build), typecheck |
| Phase 9 (Docs) | Final verification | typecheck, lint, build, test |
| Phase 10 (Integration) | After app integration changes | typecheck, lint, build |
| Phase 11 (Readiness) | Release gate | typecheck, lint, build, test |

### Rules

- **Never delete a failing test to make the loop pass.** Fix the implementation or the test, not the existence of the test.
- **Never disable a lint rule to bypass an error.** Fix the code to comply with the rule.
- **Build errors take priority.** A missing dependency or broken import cascades into dozens of type errors. Fix the root cause.
- **Snapshot mismatches are expected** after implementation changes. Update snapshots (`{packageManager} run test -- -u`) only when the new output is correct.
- **Log every attempt.** When the loop completes, include the attempt count in the phase status: `"Status: DONE (Fix Loop: passed on attempt 2/5)"`

### Example Fix Loop Session

```
Fix Loop: attempt 1/5
  typecheck: FAIL (3 errors)
    - TS2307: Cannot find module './tokens/semantic/colors'
    - TS2345: Argument of type 'string' is not assignable to 'ButtonVariant'
    - TS7006: Parameter 'props' implicitly has an 'any' type
  lint: SKIP (typecheck must pass first)
  build: SKIP
  test: SKIP

  → Fix: add missing barrel export in tokens/semantic/index.ts
  → Fix: narrow type from string to ButtonVariant union
  → Fix: add explicit type annotation to props parameter

Fix Loop: attempt 2/5
  typecheck: PASS
  lint: FAIL (1 error)
    - no-unused-vars: 'oldTheme' is defined but never used
  build: PASS
  test: PASS

  → Fix: remove unused 'oldTheme' variable

Fix Loop: attempt 3/5
  typecheck: PASS
  lint: PASS
  build: PASS
  test: PASS

Fix Loop: PASSED on attempt 3/5
```

## Forbidden Patterns

- Hardcoded color values in component files (use semantic tokens).
- Direct primitive token usage in components (use semantic layer).
- HSL or hex as primary color format (convert to OKLCH).
- Adjusting chroma for contrast fixes (adjust lightness only).
- Unnamed or abbreviated token names (be explicit and descriptive).
- Inconsistent prop naming across similar components.
