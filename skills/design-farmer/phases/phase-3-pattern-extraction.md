# Phase 3: Design Pattern Extraction & OKLCH Conversion

## 3.0 Path Selection

Read `designMaturity` from `DesignFarmerConfig` (set by Phase 2). If unavailable, read from `{systemPath}/.design-farmer/config.json`.

```
GREENFIELD (score 0–2): No significant patterns to extract. Skip sections 3.1–3.7 extraction loops.
  → Generate defaults from the brand color (DesignFarmerConfig.brandColor).
  → Apply typography and spacing defaults defined below.
  → Output uses the same structure as extracted values — downstream phases treat them identically.

EMERGING (score 3–5): Partial extraction. Run sections 3.1–3.7 but fill gaps with generated defaults.
  → Mark extracted values as [EXTRACTED] and generated defaults as [GENERATED] in the output.

MATURE (score 6+): Full extraction. Run sections 3.1–3.7 as written.
  → Extraction is authoritative; do not substitute defaults.
```

### Greenfield Defaults (apply when designMaturity = GREENFIELD)

**Color**: Generate 11-step OKLCH palette from `DesignFarmerConfig.brandColor`.
If no brand color was provided (user chose neutral-first in Q2), start from `oklch(0.55 0.22 264)` (indigo).

See `examples/DESIGN.md` for a fully filled-in example of all token values
and component design decisions. Use it as the concrete reference when building greenfield output.

**Typography defaults:**
- Primary font: `Inter`, fallback: `system-ui, -apple-system, sans-serif`
- Monospace: `JetBrains Mono`, fallback: `ui-monospace, SFMono-Regular, monospace`
- Scale ratio: 1.25 (Major Third)
- Base sizes: 12px (small), 14px (body), 16px (body-large), 18–36px (headings)
- Weights: 300 (display), 400 (body), 500 (label), 600 (heading)

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
```

## 3.4 Dark Mode Derivation

```
Dark mode palette = reverse the lightness mapping:
- Light step 50  (L=0.95) -> Dark step 50  (L=0.15)
- Light step 950 (L=0.15) -> Dark step 950 (L=0.95)
- H is preserved unchanged; C values are preserved unchanged (not scaled)
- Note: dark step 50 is the near-black variant (L=0.15), not near-white.
  Consumers should use semantic tokens (e.g., --surface-default) rather than
  bare palette steps so the inversion is transparent to components.
- Re-validate APCA contrast for all pairs in dark mode
```

## 3.5 Gamut Safety

```
For every generated color:
1. Check sRGB gamut boundary
2. If out-of-gamut: reduce C while preserving L and H
3. Optionally provide Display P3 enhanced version:
   @media (color-gamut: p3) {
     --color-primary-500: oklch(0.623 0.214 250);
   }
4. P3 gains by hue: greens/cyans +35% chroma, blues/purples +10-13%
```

## 3.6 Typography Extraction

```
Extract and normalize:
- Font families -> map to font-family tokens
- Font sizes -> normalize to a modular scale (1.125, 1.2, or 1.25 ratio)
- Line heights -> map to unitless ratios (1.2, 1.4, 1.5, 1.6)
- Font weights -> map to standard weight tokens (400, 500, 600, 700)
- Letter spacing -> map to tracking tokens
```

## 3.7 Spacing Extraction

```
Extract and normalize:
- All margin/padding/gap values
- Normalize to a base-4 or base-8 scale
- Generate spacing tokens: 0, 1(4px), 2(8px), 3(12px), 4(16px), 5(20px),
  6(24px), 8(32px), 10(40px), 12(48px), 16(64px), 20(80px), 24(96px)
```

**Status: DONE** — Pattern extraction complete. Proceed to Phase 3.5: Visual Preview.
