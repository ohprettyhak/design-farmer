# Phase 3.5: Visual Preview

**Purpose:** Generate a visual preview of the proposed design system before writing implementation code. This lets the user validate color palette, typography, spacing, and overall visual direction before hundreds of files are generated.

## 3.5.1 Preview Generation

Generate a self-contained HTML file at `{systemPath}/design-preview.html`:

```
Generate a self-contained HTML file at {systemPath}/design-preview.html that visualizes the proposed design system. This file must:

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
```

## 3.5.2 Preview Review Gate

**CRITICAL: This is a hard gate. Do NOT proceed to Phase 4 until the user approves.**

Via AskUserQuestion, ask:

> I've generated a visual preview of your proposed design system.
>
> **Preview location:** `{systemPath}/design-preview.html`
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
- Return to Phase 1 Question 2 (Brand & Color Direction)
- Restart the extraction process with new direction

## 3.5.3 Fallback Path

If preview generation fails (e.g., no color palette extracted, tooling error):
1. Log: "Preview generation failed: {reason}"
2. Present the raw extracted data as a text summary instead
3. Ask user to confirm the text-based direction before proceeding
4. Continue to Phase 4 with user's textual approval

**Status: DONE** — Visual preview reviewed and approved. Proceed to Phase 4: Architecture Design.
