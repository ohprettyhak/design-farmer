# Design System: Nova UI
**Product Type:** B2B SaaS Analytics Dashboard

> **This is an example DESIGN.md** — use it as a concrete reference for greenfield design system construction.
> When Design Farmer generates your DESIGN.md in Phase 4.5, it will be customized to your brand and codebase.
> Replace "Nova UI" and its values with your own product decisions.
>
> All color values use OKLCH. All sizes are in pixels unless noted.

## Config
<!-- Required for Design Farmer re-entry (Phase 0 → Phase 5 shortcut). Update before use. -->
```yaml
packageManager: pnpm
framework: next-app-router
isMonorepo: true
systemPath: packages/design-system
designSystemPackage: "@acme/design-system"
componentScope: core
headlessLibrary: radix
themeStrategy: light-dark
themeLibrary: next-themes
accessibilityLevel: apca
targetPlatforms: web
designMaturity: greenfield
maturityScore: 0
```

---

## 1. Visual Theme & Atmosphere

Nova UI is designed for a modern B2B analytics product — technical, precise, and quietly confident. The overall
aesthetic is clean and information-dense without feeling clinical. Deep indigo anchors the brand identity; cool
neutral slate surfaces keep the focus on data. Generous whitespace prevents cognitive overload on complex dashboard
views, and subtle elevation signals hierarchy without visual clutter.

The design language draws from the best of enterprise software: familiar enough for non-technical users to navigate
immediately, sophisticated enough to signal to buyers that this product means business. Weight 300 headlines create
an airy, editorial quality that distinguishes Nova from generic dashboard tooling.

**Key Characteristics:**
- Background base: `oklch(0.98 0.003 240)` (light) / `oklch(0.12 0.015 250)` (dark)
- Primary font: Inter, weights 300–600; display headings at 300 for confident, airy quality
- Brand accent: `oklch(0.55 0.22 264)` — deep indigo that passes APCA Lc 60 on white
- Border style: nearly-invisible `oklch(0.84 0.010 240)` lines as structural guides, never decoration

---

## 2. Color Palette & Roles

### Background Surfaces
- **Surface Default** (`oklch(0.98 0.003 240)`): Main page background, card backgrounds — barely-off-white with a cool cast
- **Surface Subtle** (`oklch(0.95 0.005 240)`): Secondary backgrounds, sidebar, table row alternation, inputs at rest
- **Surface Muted** (`oklch(0.91 0.008 240)`): Hover states on non-interactive containers, skeleton loaders
- **Surface Inverse** (`oklch(0.13 0.015 250)`): Dark surfaces for reversed-out elements; tooltips in light mode

### Text & Content
- **Primary Text** (`oklch(0.15 0.008 250)`): Main body copy, headings, labels — near-black with a cool tint
- **Secondary Text** (`oklch(0.42 0.012 250)`): Captions, metadata, helper text, table cell secondary info
- **Tertiary Text** (`oklch(0.62 0.010 250)`): Placeholders, disabled labels, de-emphasized metadata
- **Inverse Text** (`oklch(0.97 0.003 240)`): Text on dark or colored backgrounds — near-white

### Brand & Interactive
- **Interactive Primary** (`oklch(0.55 0.22 264)`): CTAs, links, selected states, focus indicators — deep indigo
- **Interactive Primary Hover** (`oklch(0.48 0.20 264)`): Hover state — 12% darker lightness
- **Interactive Primary Active** (`oklch(0.42 0.18 264)`): Pressed state — 20% darker lightness
- **Interactive Text** (`oklch(0.50 0.22 264)`): Brand-colored inline text, active nav items
- **Interactive Bg** (`oklch(0.96 0.02 264)`): Subtle tinted container background for interactive regions

### Status Colors
- **Success** (`oklch(0.58 0.17 145)`): Positive feedback, confirmed states, upward trend indicators — medium green
- **Success Surface** (`oklch(0.96 0.04 145)`): Success message backgrounds
- **Warning** (`oklch(0.68 0.18 55)`): Caution states, pending actions, approaching limits — amber
- **Warning Surface** (`oklch(0.97 0.04 70)`): Warning message backgrounds
- **Error** (`oklch(0.58 0.22 25)`): Destructive actions, validation errors, downward trend — medium red
- **Error Surface** (`oklch(0.97 0.04 25)`): Error message backgrounds
- **Info** (`oklch(0.55 0.18 230)`): Informational feedback, neutral notifications — steel blue
- **Info Surface** (`oklch(0.96 0.03 230)`): Info message backgrounds

### Borders & Dividers
- **Border Subtle** (`oklch(0.92 0.006 240)`): Low-emphasis dividers, table row separators
- **Border Default** (`oklch(0.84 0.010 240)`): Standard borders, input outlines
- **Border Strong** (`oklch(0.70 0.015 250)`): High-emphasis borders, active selections
- **Border Focus** (`oklch(0.55 0.22 264)`): Keyboard focus indicator — matches brand primary

### Shadows
- **Shadow SM** (`0 1px 3px oklch(0 0 0 / 0.06), 0 1px 2px oklch(0 0 0 / 0.04)`): Subtle depth for cards, inputs
- **Shadow MD** (`0 4px 12px oklch(0 0 0 / 0.08), 0 2px 6px oklch(0 0 0 / 0.06)`): Dropdowns, popovers
- **Shadow LG** (`0 8px 24px oklch(0 0 0 / 0.12), 0 4px 12px oklch(0 0 0 / 0.08)`): Modals, dialogs
- **Shadow XL** (`0 16px 40px oklch(0 0 0 / 0.16), 0 8px 20px oklch(0 0 0 / 0.10)`): Spotlight dialogs, drawer overlays

---

## 3. Typography Rules

### Font Family
- **Primary**: `Inter`, fallback: `system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`
- **Monospace**: `JetBrains Mono`, fallback: `ui-monospace, SFMono-Regular, 'Cascadia Code', monospace`

> **Why Inter?** Purpose-designed for screens at small sizes; variable font allows precise weight tuning.
> At 300 it reads editorial; at 500 it reads confident UI.

### Hierarchy

| Role | Size | Weight | Line Height | Letter Spacing |
|------|------|--------|-------------|----------------|
| Display | 36px | 300 | 1.10 | -0.03em |
| Heading 1 | 30px | 600 | 1.20 | -0.02em |
| Heading 2 | 24px | 600 | 1.25 | -0.01em |
| Heading 3 | 20px | 500 | 1.30 | normal |
| Heading 4 | 18px | 500 | 1.35 | normal |
| Body Large | 16px | 400 | 1.60 | normal |
| Body | 14px | 400 | 1.50 | normal |
| Small | 12px | 400 | 1.40 | 0.01em |
| Code | 13px | 400 | 1.60 | normal |

### Typography Principles
Display and H1 use weight 300 to create confident, editorial presence at large sizes — this distinguishes Nova
from generic enterprise software. UI labels and body copy use 400–500 for functional clarity. Negative
letter-spacing on large headings corrects the optical looseness of Inter at display sizes; small/caption text
gets +0.01em to improve legibility at 12px.

---

## 4. Component Stylings

### Buttons

**Primary Button** — `variant="primary"`
- Background: `var(--interactive-primary)` → `oklch(0.55 0.22 264)`
- Text: `var(--text-inverse)` → `oklch(0.97 0.003 240)`
- Border-radius: `6px` (`--button-radius`)
- Hover: `var(--interactive-primary-hover)` → `oklch(0.48 0.20 264)`
- Active: `var(--interactive-primary-active)` → `oklch(0.42 0.18 264)`
- Disabled: `opacity: 40%`

**Secondary Button** — `variant="secondary"`
- Background: `var(--interactive-bg)` → `oklch(0.96 0.02 264)`
- Text: `var(--interactive-text)` → `oklch(0.50 0.22 264)`
- Border: `box-shadow: 0 0 0 1px var(--border-default)`

**Ghost Button** — `variant="ghost"`
- Background: transparent
- Text: `var(--interactive-text)`
- Hover background: `var(--surface-muted)`

**Outline Button** — `variant="outline"`
- Background: transparent
- Border: `box-shadow: 0 0 0 1px var(--border-default)`
- Text: `var(--text-primary)`

**Destructive Button** — `variant="error"`
- Background: `var(--state-error)` → `oklch(0.58 0.22 25)`
- Text: white
- Hover: 8% darker lightness

**Size Scale:**
| Size | Height | Padding X | Font Size |
|------|--------|-----------|-----------|
| x-small | 24px | 8px | 12px |
| small | 28px | 10px | 12px |
| medium | 32px | 12px | 14px |
| large | 36px | 16px | 14px |

### Inputs & Forms

**Text Input** (normal state)
- Background: `var(--surface-default)`
- Border: `box-shadow: 0 0 0 1px var(--border-default), var(--shadow-sm)` — box-shadow prevents layout shift
- Height: `32px` (medium), `28px` (small)
- Padding: `8px 12px` (medium), `6px 10px` (small)
- Border-radius: `6px`
- Focus: `box-shadow: 0 0 0 1px var(--border-focus), var(--shadow-sm)`
- Error: `box-shadow: 0 0 0 1px var(--state-error)`
- Disabled: `opacity: 40%, cursor: not-allowed, background: var(--surface-subtle)`
- Placeholder: `var(--text-tertiary)` → `oklch(0.62 0.010 250)`

**CSS tokens defined in tokens.css:**
```css
--input-shadow:       0 0 0 1px var(--border-default), var(--shadow-sm);
--input-shadow-focus: 0 0 0 1px var(--border-focus), var(--shadow-sm);
--input-shadow-error: 0 0 0 1px var(--state-error), var(--shadow-sm);
```

### Cards & Containers

**Elevated Card**
- Background: `var(--surface-default)`
- Shadow: `var(--shadow-sm)`
- Border-radius: `8px` (`--card-radius`)

**Outlined Card**
- Background: `var(--surface-default)`
- Border: `1px solid var(--border-default)`
- Border-radius: `8px`

**Filled Card**
- Background: `var(--surface-subtle)`
- Border-radius: `8px`

Card sub-components: CardHeader (`border-bottom: 1px solid var(--border-subtle)`, `var(--surface-subtle)` bg),
CardTitle (18px/500, `var(--text-primary)`), CardDescription (14px/400, `var(--text-secondary)`),
CardContent (16px padding), CardFooter (`border-top: 1px solid var(--border-subtle)`, flex end)

### Badges

| Variant | Background | Text |
|---------|-----------|------|
| default | `var(--surface-muted)` | `var(--text-secondary)` |
| success | `var(--state-success-surface)` | `var(--state-success)` |
| warning | `var(--state-warning-surface)` | `var(--state-warning)` |
| error | `var(--state-error-surface)` | `var(--state-error)` |
| info | `var(--state-info-surface)` | `var(--state-info)` |

Shape: `border-radius: 9999px` (pill), height `20px`, padding `0 8px`, font-size `12px`

### Dialog / Modal

- Backdrop: `oklch(0 0 0 / 0.4)`
- Popup: `var(--surface-default)`, `var(--shadow-lg)`, `border-radius: 12px` (`--dialog-radius`)
- Max widths: small `380px`, medium `520px`, large `680px`
- Width: `w-full max-w-[Xpx]` (responsive)
- Animation: scale + rotateX 3D entrance: `perspective(1200px) rotateX(-2deg) scale(0.995)` → `rotateX(0) scale(1)`, 200ms ease-out

### Overlay (Popover / Tooltip / Dropdown)

- Background: `var(--surface-default)`
- Border: `1px solid var(--border-subtle)`
- Shadow: `var(--shadow-md)`
- Border-radius: `8px` (`--popover-radius`)
- Animation: fade + translateY(`-4px`) entrance, 150ms ease-out

### Toast / Notification

- Library: Sonner (`sonner`) — not a custom implementation
- Mount once at root: `<Toaster position="bottom-right" richColors closeButton />`
- Style: `borderRadius: var(--toast-radius)`, `fontFamily: var(--font-family-sans)`
- Surface: `--normal-bg: var(--surface-default)`, `--normal-border: var(--border-default)`

### Tabs

- Tab list: horizontal scrollable, `border-bottom: 1px solid var(--border-subtle)`
- Active tab: `color: var(--text-primary)`, sliding underline `var(--interactive-primary)` — 2px thick
- Inactive: `var(--text-tertiary)`, hover `var(--text-secondary)`
- Transition: 150ms ease for underline position and color

---

## 5. Layout Principles

### Spacing System
- Base unit: `4px`
- Scale: `2, 4, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96` px

### Container & Grid
- Page max-width: `1280px` (dashboard), `768px` (content pages)
- Column gap: `16px` (compact), `24px` (standard), `32px` (loose)
- Section vertical rhythm: `32px` between sections, `64px` between major sections

### Whitespace Philosophy
Generous internal padding makes the UI feel spacious and reduces eye fatigue during long sessions. The `24px`
standard gap creates clear visual breathing room between cards. Never use spacing less than `8px` between
interactive elements (touch target safety). The `4px` base unit ensures all spacing values align on a crisp
pixel grid across all viewports.

---

## 6. Depth & Elevation

| Level | Treatment | Use Case |
|-------|-----------|----------|
| Flat | No shadow | Page background, table rows |
| SM | `0 1px 3px oklch(0 0 0 / 0.06)` | Cards, inputs |
| MD | `0 4px 12px oklch(0 0 0 / 0.08)` | Dropdowns, popovers |
| LG | `0 8px 24px oklch(0 0 0 / 0.12)` | Modals, drawers |
| XL | `0 16px 40px oklch(0 0 0 / 0.16)` | Spotlight dialogs |
| Focus | `0 0 0 3px oklch(0.55 0.22 264 / 0.30)` | Keyboard focus ring |

---

## 7. Do's and Don'ts

### Do
- Use `box-shadow: 0 0 0 1px` for interactive element borders (no layout shift on state change)
- Use semantic tokens (`--text-primary`, not `--color-neutral-900`) in all components
- Use CSS `:hover` and `:active` for interactive states — not JS event handlers
- Use named React imports: `import { forwardRef, useId } from "react"` — not `import React from "react"`
- Use `ComponentProps<typeof X>` for extending component props
- Use `oklch()` for all color values — never hex or hsl in token definitions
- Verify APCA contrast Lc ≥ 60 for all text/surface pairs

### Don't
- Don't use `React.FC`, `React.ReactNode`, `React.ElementRef` (use imported named types instead)
- Don't use `import * as React from "react"` (use named imports)
- Don't hardcode color values in components (always use semantic tokens)
- Don't use CSS `border` on inputs/selects (use box-shadow to avoid layout shift)
- Don't use inline `style={{}}` for component styling (use Tailwind classes or CSS Modules)
- Don't use JS state (onMouseEnter/onMouseLeave) for hover/active — use CSS `:hover/:active`
- Don't use primitive tokens in components (`--color-indigo-500`, only `--interactive-primary`)

---

## 8. Responsive Behavior

### Breakpoints
| Name | Width | Key Changes |
|------|-------|-------------|
| Mobile | < 640px | Single column, stacked layouts, nav to hamburger |
| Tablet | 640–1024px | Two-column, condensed sidebar |
| Desktop | > 1024px | Full layout, expanded sidebar, multi-column grids |

### Touch Targets
- Minimum tap target: `44×44px`
- Buttons always meet minimum height at all sizes
- Table row height: `48px` minimum on mobile

### Collapsing Strategy
- Navigation: horizontal → hamburger at mobile breakpoint
- Card grids: 3-column → 2-column → 1-column
- Dialog: `w-full max-w-[520px]` with `16px` horizontal margin on mobile

---

## 9. Agent Prompt Guide

### Quick Token Reference
- Primary action background: `var(--interactive-primary)` → `oklch(0.55 0.22 264)`
- Page background: `var(--surface-default)` → `oklch(0.98 0.003 240)`
- Card background: `var(--surface-default)` or `var(--surface-subtle)`
- Primary text: `var(--text-primary)` → `oklch(0.15 0.008 250)`
- Secondary text: `var(--text-secondary)` → `oklch(0.42 0.012 250)`
- Border default: `var(--border-default)` → `oklch(0.84 0.010 240)`
- Error state: `var(--state-error)` → `oklch(0.58 0.22 25)`
- Focus ring: `var(--border-focus)` → `oklch(0.55 0.22 264)`

### Example Component Prompts
- "Create a card: `--surface-default` bg, `--border-default` outline, `8px` radius, CardHeader with `--surface-subtle` + `--border-subtle` bottom, CardContent with `16px` padding"
- "Create a primary button: `--interactive-primary` bg, `--text-inverse` text, `6px` radius, hover `--interactive-primary-hover`, active `--interactive-primary-active`, `32px` height, `12px` padding-x"
- "Create an input: `32px` height, `6px` radius, `box-shadow: --input-shadow`, focus `--input-shadow-focus`, error `--input-shadow-error`, placeholder `--text-tertiary`"

### Iteration Guide
1. Always reference semantic tokens, never raw color values
2. When adding a new component, follow size variant naming: `x-small | small | medium | large`
3. Match border approach: box-shadow for interactive outlines, CSS border for structural dividers
4. Test hover/focus/active/disabled states in both light and dark themes
5. Verify APCA Lc ≥ 60 for any new text/background pair

---

## Revision History
| Date | Action | Sections Changed |
|------|--------|-----------------|
| 2026-04-06 | Example file created | All |

---

> **Using this example in a greenfield project:**
> 1. Copy this file to `{systemPath}/DESIGN.md`
> 2. Replace "Nova UI" with your product name
> 3. Update Section 1 (Visual Theme) to reflect your brand personality
> 4. Replace the indigo brand color (`oklch(0.55 0.22 264)`) with your brand primary
> 5. Adjust typography, spacing, and component values to match your aesthetic
> 6. Run Design Farmer — it will detect this DESIGN.md in Phase 0 and offer to use it directly
