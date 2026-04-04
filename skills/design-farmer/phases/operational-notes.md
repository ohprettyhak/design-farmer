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

## Forbidden Patterns

- Hardcoded color values in component files (use semantic tokens).
- Direct primitive token usage in components (use semantic layer).
- HSL or hex as primary color format (convert to OKLCH).
- Adjusting chroma for contrast fixes (adjust lightness only).
- Unnamed or abbreviated token names (be explicit and descriptive).
- Inconsistent prop naming across similar components.
