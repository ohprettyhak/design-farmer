# Phase 3: Design Pattern Extraction & OKLCH Conversion

## 3.0 Path Selection

Read `designMaturity` from `DesignFarmerConfig` (set by Phase 2). If unavailable, read from `{systemPath}/.design-farmer/config.json`.

```
GREENFIELD (designMaturity = 'greenfield'): No significant patterns to extract. Skip sections 3.1–3.7 extraction loops.
  → Generate defaults from the brand color (DesignFarmerConfig.brandColor).
  → Apply typography and spacing defaults defined below.
  → Output uses the same structure as extracted values — downstream phases treat them identically.
  → After generating the early DESIGN.md draft, you MUST still append `'phase-3'` to `completedPhases` (see the append instruction at the end of this file).

EMERGING (designMaturity = 'emerging'): Partial extraction. Run sections 3.1–3.7 but fill gaps with generated defaults.
  → Mark extracted values as `[EXTRACTED]` and generated defaults as `[GENERATED]` in the output.
  → Marker format: append the tag as an inline suffix to each value, e.g., `oklch(0.55 0.20 250) [EXTRACTED]` or `Inter [GENERATED]`.
  → These markers appear in the Phase 3 output draft and are consumed by Phase 4 to decide which patterns to preserve vs. replace.
  → For each token category (color, typography, spacing, border-radius, shadow), explicitly label each value as `[EXTRACTED]` or `[GENERATED]` in the DESIGN.md draft. If no values in a category are extracted, all values must be `[GENERATED]`.

Gap-filling rules per category:
- Colors: If any brand colors extracted, complete to 11-step palette with [GENERATED] steps for missing shades. If zero extracted, generate full palette [GENERATED].
- Typography: If font families extracted, keep them [EXTRACTED] and generate missing sizes/weights [GENERATED]. If none extracted, generate full typography scale [GENERATED].
- Spacing, border-radius, shadows: If any values extracted, keep them [EXTRACTED] and generate missing scale values [GENERATED]. If none extracted, generate full defaults [GENERATED].

MATURE (designMaturity = 'mature'): Full extraction. Run sections 3.1–3.7 as written.
  → Extraction is authoritative; do not substitute defaults.
```

### Greenfield Defaults (apply when designMaturity = 'greenfield')

**Color**: Generate 11-step OKLCH palette from `DesignFarmerConfig.brandColor`.

If the user explicitly chose neutral-first in Q2 (colorDirection='neutral'):
- Use the neutral-first default immediately: `oklch(0.55 0.22 264)` (indigo)
- No extraction is needed in this case

If the user chose 'keep' (colorDirection='keep'):
- Attempt brand color extraction from the codebase first
- If zero colors are found after scanning (no matches), then fall back to the neutral-first default: `oklch(0.55 0.22 264)` (indigo)
- Note in the DESIGN.md draft that no brand colors were extracted when falling back

See `examples/DESIGN.md` for a fully filled-in example of all token values
and component design decisions. Use it as the concrete reference when building greenfield output.

**Typography defaults:**
- Primary font: `Inter`, fallback: `system-ui, -apple-system, sans-serif`
- Monospace: `JetBrains Mono`, fallback: `ui-monospace, SFMono-Regular, monospace`
- Scale ratio: 1.25 (Major Third)
- Base sizes: 12px (small), 14px (body), 16px (body-large), 18–36px (headings)
- Weights: 300 (display), 400 (body), 500 (label), 600 (heading), 700 (emphasis/bold)

**Spacing defaults**: Base-4 scale: `2, 4, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96` px

**Border radius defaults:**
- Tight: `4px` (badges, tags)
- Default: `6px` (buttons, inputs)
- Loose: `8px` (cards, dialogs, popovers)

**Shadow defaults** using `oklch(0 0 0 / alpha)`:
- SM: `0 1px 3px oklch(0 0 0 / 0.06)`
- MD: `0 4px 12px oklch(0 0 0 / 0.08)`
- LG: `0 8px 24px oklch(0 0 0 / 0.12)`

---

## 3.1 Color Extraction & Conversion

Extract all color values and convert to OKLCH:

```
For each extracted color:
1. Parse the original format (hex, rgb, hsl)
2. Convert to OKLCH: oklch(L C H)
   - L (Lightness): 0 to 1
   - C (Chroma): 0 to ~0.4
   - H (Hue): 0 to 360 degrees
   - If conversion fails due to unrecognized format, log the failure and skip that color. Do not block the entire phase for a single conversion failure.
   - Out-of-gamut colors are handled by the clamping algorithm in section 3.2.
3. Group by hue similarity (within 15 degrees)
4. Identify the most-used color per hue group as the "base" color
```

## 3.2 OKLCH Palette Generation

For each identified base color, generate an 11-step palette:

```
Steps: 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950

Algorithm:
1. Establish lightness bounds:
   - Delta = 0.4 (standard range)
   - L_min = max(0.05, base_L - delta/2)
   - L_max = min(0.95, base_L + delta/2)

2. Distribute lightness evenly across 11 steps:
   - Step 50:  L_max (lightest)
   - Step 950: L_min (darkest)
   - Step 500: base_L (midpoint)

3. Clamp chroma per step to sRGB gamut:
   - Reduce C while preserving L and H until the color is within sRGB gamut
   - culori:  clampChroma(color, 'oklch', 'srgb')
   - Color.js: color.toGamut({ space: 'srgb' })

4. Maintain constant hue across all steps:
   - H never changes within a palette
   - If source had hue drift (HSL artifact), normalize to constant H

5. Optionally enhance for Display P3:
   - sRGB gamut safety was already ensured in step 3; do not re-clamp here.
   - For Display P3 targets, provide enhanced-chroma variants:
     @media (color-gamut: p3) {
       --color-primary-500: oklch(0.623 0.214 250);
     }
   - P3 gains by hue: greens/cyans +35% chroma, blues/purples +10-13%
```

## 3.3 Contrast Validation (APCA)

```
For every foreground/background pair in the palette:
- Light backgrounds (L > 0.85): foreground L must be <= 0.45
- Dark backgrounds (L < 0.25): foreground L must be >= 0.75
- NEVER adjust chroma for contrast — only modify the L channel

APCA threshold table → see operational-notes.md "APCA thresholds vary by font size and weight"

At palette generation time (before component usage is known), use Lc 60 as the
working threshold for step-500 as body-text candidate. Final validation per
component occurs in Phase 8 (Review), where actual font sizes are known.

⚠️  APCA is part of the WCAG 3.0 Working Draft. For legal compliance (ADA, EN 301 549),
also verify WCAG 2.x 4.5:1 alongside APCA checks.

After contrast adjustments, re-verify sRGB gamut for every modified color.
If adjusting L pushed any color out of gamut, reduce C while preserving the
new L and H (same algorithm as 3.2 step 3). This ensures the light-mode
palette remains in-gamut before entering dark mode derivation.
```

## 3.4 Dark Mode Derivation

```
Dark mode palette = reverse the lightness mapping:
- Light step 50  (L=0.95) -> Dark step 50  (L=0.15)
- Light step 950 (L=0.15) -> Dark step 950 (L=0.95)
- H is preserved unchanged; C is carried over from the final light-mode palette
  (after any contrast-driven L adjustments in 3.3 and their resulting gamut
  corrections). C is not scaled or intentionally modified.
- After inversion, clamp C to sRGB gamut only when the new L pushes the color
  out of bounds (high-chroma hues at extreme L values). Use the same sRGB gamut
  clamping as 3.2 step 3 (e.g., culori: clampChroma or Color.js: toGamut).
  This is a gamut-safety pass, not an intentional chroma adjustment.
- Note: dark step 50 is the near-black variant (L=0.15), not near-white.
  Consumers should use semantic tokens (e.g., --surface-default) rather than
  bare palette steps so the inversion is transparent to components.
- Re-validate APCA contrast for all dark-mode pairs using the same thresholds
  and rules as 3.3 (working threshold Lc 60; full table in operational-notes.md)
```

<!-- Section 3.5 (Gamut Safety) was merged into 3.2 step 5. Numbering preserved for cross-reference stability. -->

## 3.6 Typography Extraction

```
Extract and normalize:
- Font families -> map to font-family tokens
- Font sizes -> normalize to a modular scale (1.125, 1.2, or 1.25 ratio)
- Line heights -> map to unitless ratios (1.2, 1.4, 1.5, 1.6)
- Font weights -> map to standard weight tokens (300 display, 400 body, 500 label, 600 heading, 700 emphasis)
- Letter spacing -> map to tracking tokens
```

## 3.7 Spacing Extraction

```
Extract and normalize:
- All margin/padding/gap values
- Normalize to a base-4 or base-8 scale
- Generate spacing tokens: 0, 0.5(2px), 1(4px), 1.5(6px), 2(8px), 2.5(10px),
  3(12px), 4(16px), 5(20px), 6(24px), 8(32px), 10(40px), 12(48px),
  16(64px), 20(80px), 24(96px)
```

### Early DESIGN.md Draft

If `DESIGN.md` does not already exist, generate a minimal draft at `{systemPath}/DESIGN.md` with:
- Header: `> **DRAFT** — Auto-generated after Phase 3. Will be completed in Phase 4.5.`
- `## Config` YAML block (same format as Phase 4.5 — required for Phase 0 re-entry)
- `## 2. Color Palette & Roles` with extracted/generated OKLCH values
- `## 3. Typography Rules` with extracted/default values
- `## 5. Layout Principles` with extracted/default spacing scale

Do NOT overwrite an existing DESIGN.md. Phase 4.5 merges this draft into the final version.

Before emitting status, append `'phase-3'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Ensure `completedPhases` exists in config.json (initialize as `[]` if undefined), then append `'phase-3'`. If `'phase-3'` is already present, skip the append (idempotent). Also update `config.backup.json`.

**Status: DONE** — Pattern extraction complete. Proceed to Phase 3.5: Visual Preview.
