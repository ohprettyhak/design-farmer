# Phase 3.5: Visual Preview

**Purpose:** Generate a visual preview of the proposed design system before writing implementation code. This lets the user validate color palette, typography, spacing, and overall visual direction before hundreds of files are generated.

## Phase Start: Config Validation

Before reading config, verify that `{systemPath}/.design-farmer/config.json` exists and is valid JSON with the required fields (`designMaturity`, `componentScope`, `themeStrategy`). If missing, unparseable, or missing required fields, emit:

**Status: BLOCKED** — Config validation failed: {reason}. Recovery: re-run Phase 1 Discovery Interview to regenerate config, or restore from `{systemPath}/.design-farmer/config.backup.json` if available.

Do NOT proceed to 3.5.0 until config is valid.

---

## 3.5.0 Preview Opt-In Gate

Read `designMaturity` from `{systemPath}/.design-farmer/config.json`.

| Maturity | Behavior | Recommendation |
|----------|----------|----------------|
| GREENFIELD | Mandatory — proceed to 3.5.1 | Always generate |
| EMERGING | Ask user | Recommend A (generate) |
| MATURE | Ask user | Recommend B (skip) |

For EMERGING/MATURE, ask via AskUserQuestion:

> {If EMERGING: "Your codebase has existing patterns."}
> {If MATURE: "Your design system is mature."}
>
> **Generate a visual HTML preview?**
> - A) Yes — generate HTML preview
> - B) No — text summary instead

**→ STOP — wait for response.**

For GREENFIELD: skip this AskUserQuestion gate, set `generatePreview: true` and `previewOutcome: 'generated'` in config.json, and proceed directly to section 3.5.1.

Set `generatePreview` in config.json (`true` if GREENFIELD or chose A; `false` if chose B).
Set `previewOutcome` in config.json (`'generated'` if GREENFIELD or chose A; `'skipped'` if chose B).
If `false`: skip 3.5.1. Instead, present a **text summary** of the extracted design direction
(color palette OKLCH values, typography choices, spacing scale) via AskUserQuestion:

> Based on your codebase analysis, here's the design direction I extracted:
>
> **Color Palette:** {list primary hue OKLCH values and generated 11-step palette}
> **Semantic Roles:** {surface, text, border token values for light/dark}
> **Typography:** {font families, size scale, weight usage}
> **Spacing:** {base unit, scale values}
>
> **Does this direction match your design intent?**
>
> Options:
> - A) Yes, proceed to architecture
> - B) Adjust — I'll tell you what to change
> - C) Start over with different direction

**→ STOP — wait for user response.**

If user approved the text summary (chose A above): `previewOutcome` is already set to `'skipped'` (line 39 above). Ensure `completedPhases` exists in config.json (initialize as `[]` if undefined), then append `'phase-3.5'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Also update `config.backup.json`. Then proceed to Phase 4 (Architecture Design). No further approval gate is needed.
If user chose B: ask follow-up questions, adjust values, re-present summary.
If user chose C: follow Option E reset logic below (return to Phase 1).
This is an intentional skip, not a failure — do NOT use the error-state Fallback Path (3.5.3).

## 3.5.1 Preview Generation

Generate a self-contained HTML file at `{systemPath}/.design-farmer/design-preview.html`:

```
Generate a self-contained HTML file at {systemPath}/.design-farmer/design-preview.html that visualizes the proposed design system. This file must:

1. **Color Palette Display** — Show all generated OKLCH palettes as color swatches with:
   - 11-step swatches (50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950) for each hue
   - Hex/OKLCH values displayed under each swatch
   - Light and dark theme variants side by side

2. **Typography Specimen** — Render text samples:
   - Each font family at all defined sizes
   - Heading hierarchy (h1-h6) with actual rendered text
   - Body text paragraph showing line-height and letter-spacing
   - Weight variations (regular, medium, semibold, bold)

3. **Spacing Scale** — Visual spacing ruler:
   - Show each spacing token as a colored bar proportional to its value
   - Label with token name and pixel value

4. **Sample Components** — Render mockup components using the proposed tokens:
   - Button with all variants (primary, secondary, ghost, danger, outline)
   - Input field with label and helper text
   - Card with header, body, and footer
   - Badge with status colors

5. **Theme Toggle** — A JavaScript toggle at the top:
   - Switches between light and dark themes
   - Applies [data-theme='light'] / [data-theme='dark'] to body
   - All CSS custom properties switch accordingly

6. **Self-contained** — No external dependencies:
   - All CSS inline in a style tag
   - All JS inline in a script tag
   - OKLCH values must work in modern browsers (96%+ support)

Read the extracted patterns from Phase 3 output and DesignFarmerConfig from {systemPath}/.design-farmer/config.json:
- Color palettes (OKLCH values from Phase 3 extraction or greenfield generation)
- Typography (font families, sizes, weights, line heights)
- Spacing (scale values)
- Component scope (from config.json)

**Greenfield framing (if designMaturity = GREENFIELD):** All values shown are generated defaults,
not extracted from existing code. Label the preview header clearly:
`"Proposed Design Direction — Greenfield Defaults (nothing was extracted from your codebase)"`.
Reference `examples/DESIGN.md` for the full Nova UI example to calibrate
whether your generated defaults are complete and reasonable before rendering the preview.

The preview file lives inside .design-farmer/ to avoid polluting the project root.
```

## 3.5.2 Preview Review Gate

**This gate (3.5.2) only applies when `generatePreview = true`.** When `generatePreview = false`, text-only approval already occurred at gate 3.5.0 — do NOT re-prompt.

**CRITICAL: This is a hard gate. Do NOT proceed to Phase 4 until the user approves.**

Via AskUserQuestion, ask:

> I've generated a visual preview of your proposed design system.
>
> **Preview location:** `{systemPath}/.design-farmer/design-preview.html`
> Open it in your browser to review the visual direction.
>
> **What do you think of the visual direction?**
>
> {If designMaturity = GREENFIELD: prepend with —
> "These are **proposed defaults** generated from your brand color — nothing was extracted from your
> codebase. This is a clean starting point you can adjust freely before any code is written."}
> {If designMaturity = EMERGING: prepend with —
> "These values are **partially extracted from your codebase**, with generated defaults filling gaps. Adjust any values that don't match your intended direction."}
>
> Options:
> - A) Looks great — proceed to architecture and implementation
> - B) Colors need adjustment — I'll tell you what to change
> - C) Typography needs adjustment — I'll tell you what to change
> - D) Spacing needs adjustment — I'll tell you what to change
> - E) Start over with different direction

**STOP. Do NOT proceed until user responds.**

If user chose A: Ensure `completedPhases` exists in config.json (initialize as `[]` if undefined), then append `'phase-3.5'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Also update `config.backup.json`. Proceed to Phase 4 (Architecture Design).

If user chose B, C, or D:
- Ask follow-up questions ONE AT A TIME to understand desired changes
- After applying changes, update the Phase 3 draft DESIGN.md at `{systemPath}/DESIGN.md` with the adjusted values. Replace the corresponding sections (Color Palette, Typography, etc.) with the user-approved values. This ensures Phase 4.5 receives an up-to-date draft.
- Regenerate the preview with adjustments
- Loop back to the review gate

If user chose E:
- Return to Phase 1 Question 0 (Brand & Color Direction)
- Restart the extraction process with new direction

**Before returning to Phase 1, reset pipeline state:**
1. Delete `{systemPath}/DESIGN.md` if it exists (partial draft from Phase 3)
2. Read `{systemPath}/.design-farmer/config.json` if it exists
3. Set `resetFromPhase: "3.5"` in config (signals Phase 1 re-entry detection)
4. Reset completedPhases to `["phase-0"]` (Phase 0 pre-flight is still valid)
5. Clear design-specific fields: `brandColor`, `colorDirection`, `customComponents`, `designMaturity`, `maturityScore`, `generatePreview`, `previewOutcome`, `skippedPhases`
6. Preserve project-specific fields: `packageManager`, `framework`, `isMonorepo`, `systemPath`, `designSystemPackage`, `componentScope`, `headlessLibrary`, `themeStrategy`, `themeLibrary`, `accessibilityLevel`, `targetPlatforms`, `vision`, `painPoint`, `productName`, `designSystemDir`
7. Persist the reset config back to `{systemPath}/.design-farmer/config.json` (and config.backup.json)
8. Log: "Phase 3.5: User chose to start over. Resetting design extraction state. Project structure settings preserved."

Note: Phase 1 will re-run from Q0. Preserved values serve as defaults — the agent should present them as pre-filled answers.

**Control flow after 3.5.1:**
- If preview generation succeeded → proceed to 3.5.2 (Preview Review Gate)
- If preview generation failed → proceed to 3.5.3 (Fallback Path)
- If user chose to skip preview at gate 3.5.0 → the approval flow in 3.5.0 handles continuation directly; do NOT enter 3.5.3

## 3.5.3 Fallback Path (generation failure only — do NOT enter from user-initiated skips)

**This fallback is ONLY for generation failures.** If `previewOutcome = 'skipped'` (user chose B at gate 3.5.0), do NOT enter this section — the user already approved via text summary.

If preview generation fails (e.g., no color palette extracted, tooling error):
1. Set `previewOutcome: 'failed'` in config.json
2. Log: "Preview generation failed: {reason}"
3. Present the raw extracted data as a text summary instead
4. Ask user to confirm the text-based direction before proceeding
5. Continue to Phase 4 with user's textual approval

Before emitting status, ensure `completedPhases` exists in config.json (initialize as `[]` if undefined), then append `'phase-3.5'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Also update `config.backup.json`.

**Status: DONE** — Visual preview reviewed and approved. Proceed to Phase 4: Architecture Design.
