# Phase 3.5: Visual Preview

**Purpose:** Generate a visual preview of the proposed design system before writing implementation code. This lets the user validate color palette, typography, spacing, and overall visual direction before hundreds of files are generated.

## 3.5.0 Preview Opt-In Gate

Read `designMaturity` from `{systemPath}/.design-farmer/config.json`.

| Maturity | Behavior | Recommendation |
|----------|----------|----------------|
| GREENFIELD (0–2) | Mandatory — proceed to 3.5.1 | Always generate |
| EMERGING (3–5) | Ask user | Recommend A (generate) |
| MATURE (6+) | Ask user | Recommend B (skip) |

For EMERGING/MATURE, ask via AskUserQuestion:

> {If EMERGING: "Your codebase has existing patterns."}
> {If MATURE: "Your design system is mature."}
>
> **Generate a visual HTML preview?**
> - A) Yes — generate HTML preview
> - B) No — text summary instead

**→ STOP — wait for response (skip for GREENFIELD).**

Set `generatePreview` in config.json (`true` if GREENFIELD or chose A; `false` if chose B).
If `false`: skip 3.5.1. Instead, present a **text summary** of the extracted design direction
(color palette OKLCH values, typography choices, spacing scale) and ask the user to approve
the direction via AskUserQuestion before proceeding to Phase 4. This is an intentional skip,
not a failure — do NOT use the error-state Fallback Path (3.5.3).

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

**Skip this section if `generatePreview = false` — the opt-in gate (3.5.0) already handled text-only approval.**

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
>
> Options:
> - A) Looks great — proceed to architecture and implementation
> - B) Colors need adjustment — I'll tell you what to change
> - C) Typography needs adjustment — I'll tell you what to change
> - D) Spacing needs adjustment — I'll tell you what to change
> - E) Start over with different direction

**STOP. Do NOT proceed until user responds.**

If user chose B, C, or D:
- Ask follow-up questions ONE AT A TIME to understand desired changes
- Regenerate the preview with adjustments
- Loop back to the review gate

If user chose E:
- Return to Phase 1 Question 0 (Brand & Color Direction)
- Restart the extraction process with new direction

**Before returning to Phase 1, reset pipeline state:**
1. Delete `{systemPath}/DESIGN.md` if it exists (partial draft from Phase 3)
2. Read `{systemPath}/.design-farmer/config.json` if it exists
3. Reset completedPhases to `["0"]` (Phase 0 pre-flight is still valid)
4. Clear design-specific fields: `brandColor`, `colorDirection`, `customComponents`, `designMaturity`, `maturityScore`, `generatePreview`
5. Preserve project-specific fields: `packageManager`, `framework`, `isMonorepo`, `systemPath`, `designSystemPackage`, `componentScope`, `headlessLibrary`, `themeStrategy`, `themeLibrary`, `accessibilityLevel`, `targetPlatforms`, `vision`, `painPoint`, `productName`, `designSystemDir`
6. Persist the reset config back to `{systemPath}/.design-farmer/config.json` (and config.backup.json)
7. Log: "Phase 3.5: User chose to start over. Resetting design extraction state. Project structure settings preserved."

Note: Phase 1 will re-run from Q0. Preserved Q3–Q7 values serve as defaults — the agent should present them as pre-filled answers, allowing the user to accept or change each one.

## 3.5.3 Fallback Path

If preview generation fails (e.g., no color palette extracted, tooling error):
1. Log: "Preview generation failed: {reason}"
2. Present the raw extracted data as a text summary instead
3. Ask user to confirm the text-based direction before proceeding
4. Continue to Phase 4 with user's textual approval

**Status: DONE** — Visual preview reviewed and approved. Proceed to Phase 4: Architecture Design.
