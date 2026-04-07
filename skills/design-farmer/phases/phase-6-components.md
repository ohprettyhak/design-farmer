# Phase 6: Component Implementation

Implement components ONE AT A TIME, in dependency order.

## 6.0 Framework Guardrail

Read `framework`, `designMaturity`, and `componentScope` from `{systemPath}/.design-farmer/config.json`.

- React (full support): `next-app-router`, `next-pages-router`, `vite-react`, `remix`
- Non-React (token output only): `astro`, `sveltekit`, `nuxt` — component patterns in this phase (forwardRef, JSX, headless libraries) are React-specific.

```
If framework is in [next-app-router, next-pages-router, vite-react, remix]:
  → Proceed to 6.0.1 (full component implementation)

If framework is in [astro, sveltekit, nuxt] AND componentScope = 'foundation':
  → SKIP component implementation (tokens only — already done in Phase 5)
  → Emit DONE: "Token-only implementation complete for {framework}. Phase 6 skipped: component
    patterns require React. Use the generated CSS tokens directly in your {framework} components."
  → Jump to Phase 8 (skip Phase 7 — Storybook is React-oriented and has no components to document)

If framework is in [astro, sveltekit, nuxt] AND componentScope ≠ 'foundation':
  → NEEDS_CONTEXT: ask via AskUserQuestion:
    "Your project uses {framework}, which doesn't use React component patterns (forwardRef, JSX,
    headless React libraries). Phase 6 generates React components — these won't compile for {framework}.
    
    How should I proceed?
    - A) Generate React components anyway — I'm using React inside {framework} (e.g. React islands in Astro)
    - B) Downgrade to foundation-only — skip components, use tokens only
    - C) Stop here — I'll write {framework}-native components manually using the DESIGN.md as reference"
  
  → Wait for user response. If A: validate headless library compatibility (see below), then proceed to 6.0.1. If B: emit DONE_WITH_CONCERNS and jump to Phase 8 (no components to document in Storybook). If C: emit DONE_WITH_CONCERNS and jump to Phase 8.

  **If user chose A (generate React components for a non-React framework):**
  The headless library selected in Phase 1 Q3-1 may be framework-specific (e.g., Melt UI for Svelte,
  Radix Vue for Vue). These libraries are NOT compatible with React component generation.
  
  Check `headlessLibrary` from config.json. If it maps to a non-React package:
  - `melt` → @melt-ui/svelte (Svelte-only)
  - `bits` → bits-ui (Svelte-only)
  - `headless-ui` with Vue framework → @headlessui/vue (Vue-only)
  
  Ask via AskUserQuestion:
  > Your headless library (`{headlessLibrary}`) is {framework}-specific and won't work with React components.
  > Choose a React-compatible replacement:
  > - A) Radix UI — Rich primitives, widely adopted
  > - B) Base UI — Maximum flexibility, by MUI
  > - C) Ark UI — Framework-agnostic
  > - D) No library — Build from scratch
  
  Update `headlessLibrary` in config.json with the user's choice before proceeding to 6.0.1.
```

The implementation path depends on **Design Maturity** (from Phase 2) and **Headless Library**
choice (from Question 3-1):

## 6.0.1 Path Selection

```
If Design Maturity = GREENFIELD (score 0-2):
  -> Use the approved preview and DESIGN.md as the sizing/styling reference
  -> If headless library chosen: wrap headless primitives with styled layer
  -> If no library: build custom primitives from scratch
  -> Every sizing decision (height, padding, font-size, radius) comes from the approved design reference in DESIGN.md

If Design Maturity = EMERGING (score 3-5):
  -> Analyze existing component patterns first
  -> Identify inconsistencies vs. the approved design reference in DESIGN.md
  -> Standardize existing patterns, fill gaps with DESIGN.md defaults
  -> Migrate to headless library gradually if chosen

If Design Maturity = MATURE (score 6+):
  -> Deep analysis of existing component API patterns
  -> Preserve existing props interface where possible
  -> Add missing accessibility, token integration, and theme support
  -> Do NOT break existing consumer code without explicit user approval
```

## 6.0.2 Dependency Pre-install

Before implementing any component, install required dependencies and verify versions:

```bash
# Headless library → npm package mapping:
#
#   Base UI:     @base-ui-components/react          (single package)
#   Ark UI:      @ark-ui/react                      (single package)
#   Headless UI: @headlessui/react                  (single package)
#   Melt UI:     @melt-ui/svelte                    (single package)
#   Bits UI:     bits-ui                            (single package)
#
#   Radix UI: INDIVIDUAL packages per component — install only what is needed:
#     @radix-ui/react-slot        (required for asChild pattern — install always)
#     @radix-ui/react-dialog      (Dialog, Modal)
#     @radix-ui/react-checkbox    (Checkbox)
#     @radix-ui/react-radio-group (Radio)
#     @radix-ui/react-select      (Select)
#     @radix-ui/react-popover     (Popover)
#     @radix-ui/react-tooltip     (Tooltip)
#     @radix-ui/react-tabs        (Tabs)
#     @radix-ui/react-dropdown-menu (Menu)
#     @radix-ui/react-toast       (Toast)
#
#   For componentScope=foundation: install only @radix-ui/react-slot
#   For componentScope=core: install slot + dialog + checkbox + radio-group + select
#   For componentScope=full: install all of the above

if [ "{headlessLibrary}" != "none" ] && [ "{headlessLibrary}" != "" ]; then
  # For single-package libraries: check version and install
  # For Radix UI: install per-component packages matching componentScope (see mapping above)
  # Example (core scope, Radix):
  #   {packageManager} add @radix-ui/react-slot @radix-ui/react-dialog \
  #     @radix-ui/react-checkbox @radix-ui/react-radio-group @radix-ui/react-select
  #
  # Resolve package name from headlessLibrary choice:
  # base-ui    → @base-ui-components/react
  # ark        → @ark-ui/react
  # headless-ui → @headlessui/react
  # melt       → @melt-ui/svelte
  # bits       → bits-ui
  # radix      → per-component packages (see mapping above)
  #
  # For single-package libraries:
  HEADLESS_PKG=$(node -e "const m={'base-ui':'@base-ui-components/react','ark':'@ark-ui/react','headless-ui':'@headlessui/react','bits':'bits-ui'};console.log(m['{headlessLibrary}']||'')" 2>/dev/null)
  [ -n "$HEADLESS_PKG" ] && npm view "$HEADLESS_PKG" version 2>/dev/null && {packageManager} add "$HEADLESS_PKG"
  # For Radix UI: install per-component packages matching componentScope (already handled above)
  # Verify: list installed packages
  {packageManager} list | grep radix 2>/dev/null || {packageManager} list | grep {headlessLibrary}
fi
```

Do NOT hardcode a specific version number — always install the latest from npm.

---

## 6.0.3 React Import Rules

**CRITICAL:** Always use named imports from React. Never use the React namespace.

```typescript
// ✅ CORRECT — named imports
import { forwardRef, useId, useState, type ComponentProps, type ReactNode, type CSSProperties } from "react";

// ❌ WRONG — namespace import (banned)
import * as React from "react";
import React from "react";

// ❌ WRONG — React namespace types (banned)
type Props = { children: React.ReactNode };      // use: type ReactNode
type Ref = React.Ref<HTMLButtonElement>;          // use: type Ref<HTMLButtonElement>
const El = React.ElementRef<typeof Button>;       // use: ComponentRef<typeof Button>

// ❌ WRONG — React.FC (banned)
const Button: React.FC<ButtonProps> = () => {};  // use: function Button(props: ButtonProps) {}
```

**Component typing patterns:**

```typescript
// ✅ Extending native HTML props — use ComponentProps
import { forwardRef, type ComponentProps } from "react";

// For extending a component's own props:
type ButtonWithIconProps = ComponentProps<typeof Button> & { icon?: ReactNode };

// For forwardRef with generic HTML elements:
export const Input = forwardRef<HTMLInputElement, InputProps>(
  function Input({ size = "medium", ...props }, ref) { ... }
);

// ✅ For compound components (namespace export):
export const Dialog = {
  Root: DialogRoot,
  Trigger: DialogTrigger,
  Portal: DialogPortal,
  Popup: DialogPopup,
  Title: DialogTitle,
  Description: DialogDescription,
  Close: DialogClose,
};

// ❌ WRONG — defaultProps (deprecated in React 19)
Button.defaultProps = { variant: "primary" };  // use default parameters instead
```

---

## 6.0.4 Border vs Box-Shadow Approach

For interactive elements (Input, Select trigger, Textarea, etc.), use **box-shadow** for borders instead of CSS `border`:

```css
/* ✅ CORRECT — box-shadow approach */
.input {
  box-shadow: 0 0 0 1px var(--border-default), var(--shadow-sm);
}
.input:focus {
  box-shadow: 0 0 0 1px var(--border-focus), var(--shadow-sm);
}
.input[data-error] {
  box-shadow: 0 0 0 1px var(--state-error);
}

/* ❌ WRONG — CSS border (causes layout shift) */
.input {
  border: 1px solid var(--border-default);
}
.input:focus {
  border-color: var(--border-focus);
  /* width stays 1px but box model recalculates → layout shift */
}
```

**Why box-shadow:** No layout shift (zero width impact), composable with drop shadows in one property, and `transition: box-shadow` is cleaner than `transition: border-color`.

**Define these tokens in `src/styles/tokens.css`:**

```css
:root {
  --input-shadow:       0 0 0 1px var(--border-default), var(--shadow-sm);
  --input-shadow-focus: 0 0 0 1px var(--border-focus), var(--shadow-sm);
  --input-shadow-error: 0 0 0 1px var(--state-error), var(--shadow-sm);
}
```

**When to use CSS `border` (normal, structural dividers):**
- Card borders: `border: 1px solid var(--border-default)` (non-interactive, no state changes)
- Table row dividers: `border-bottom: 1px solid var(--border-subtle)`
- Section separators: `border-top: 1px solid var(--border-subtle)`

**Rule:** If the element has interactive states (focus, error, disabled) → use box-shadow. If purely structural → use CSS border.

---

## 6.1 Headless Component Wrapping Pattern

When the user chose a headless library (Radix, Base UI, Ark UI, etc.), each component
follows a three-layer architecture:

```
Layer 1: Headless Primitive (from library)
  └── Provides: behavior, ARIA, keyboard nav, focus management, state machine
  └── No styling, no opinions on visuals

Layer 2: Styled Wrapper (your design system)
  └── Applies: design tokens via CSS custom properties
  └── Adds: size variants, visual variants, component tokens
  └── Composes: headless primitive + your token-based styles

Layer 3: Composed Components (optional higher-level)
  └── Combines: multiple styled wrappers into application-level patterns
  └── Example: FormField = Label + Input + HelperText + ErrorMessage
```

**Example: Button with Radix UI Primitive**

```typescript
// primitives/button/button.tsx
import { forwardRef, type ButtonHTMLAttributes } from 'react'
import { cn } from '../../utils/cn'
// import { Slot } from '@radix-ui/react-slot'  // for asChild pattern

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger' | 'outline'
  size?: 'x-small' | 'small' | 'medium' | 'large'
  loading?: boolean
  asChild?: boolean  // Radix slot pattern: render as child element
}

// Component consumes ONLY semantic tokens via CSS custom properties.
// Sizing values from the approved design reference (DESIGN.md):
//   sm: h-32px px-12px text-14px
//   md: h-36px px-16px text-14px
//   lg: h-40px px-20px text-16px

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', size = 'medium', loading, className, ...props }, ref) => (
    <button
      ref={ref}
      className={cn(
        'btn',                              // base token class
        `btn-${variant}`,                   // variant token class
        `btn-${size}`,                      // size token class
        loading && 'btn-loading',
        className                           // consumer override — always last
      )}
      disabled={loading || props.disabled}
      {...props}
    />
  )
)
Button.displayName = 'Button'
```

**Example: Dialog with Base UI**

```typescript
// primitives/dialog/dialog.tsx
// import * as Dialog from '@base-ui-components/react/dialog'
//
// Compose headless parts into a styled dialog:
// <Dialog.Root>
//   <Dialog.Trigger>     → your styled trigger button
//   <Dialog.Portal>      → renders outside DOM tree
//     <Dialog.Backdrop>  → styled overlay (oklch(0 0 0 / 0.5))
//     <Dialog.Popup>     → styled container (surface.primary, shadow.xl, radius.lg)
//       <Dialog.Title>   → styled heading
//       <Dialog.Description> → styled body
//       <Dialog.Close>   → styled close button
//     </Dialog.Popup>
//   </Dialog.Portal>
// </Dialog.Root>
//
// Base UI handles: focus trap, Escape to close, scroll lock, portal
// You handle: token-based styling, size variants, animations
```

**Compound Component Pattern** (for complex components):

```typescript
// Export as a namespace for clean consumer API:
// import { Select } from 'design-system'
//
// <Select.Root>
//   <Select.Trigger />
//   <Select.Content>
//     <Select.Group>
//       <Select.Label>Fruits</Select.Label>
//       <Select.Item value="apple">Apple</Select.Item>
//       <Select.Item value="banana">Banana</Select.Item>
//     </Select.Group>
//   </Select.Content>
// </Select.Root>
//
// Each sub-component is independently styled with tokens.
// The root manages shared state via React context.
```

## 6.2 Component Implementation Cycle

For each component:

1. **Contract definition** — Define the component API before writing code:
   ```typescript
   interface ButtonProps {
     variant: 'primary' | 'secondary' | 'ghost' | 'danger' | 'outline';
     size: 'x-small' | 'small' | 'medium' | 'large';
     disabled?: boolean;
     loading?: boolean;
     asChild?: boolean;  // slot pattern (if headless library supports it)
     children: ReactNode;
   }
   ```
   Reference `DESIGN.md` for sizing values when building greenfield.

2. **Implementation** — Build the component:
   ```
   Implement {ComponentName} at {systemPath}/src/primitives/{component}/

   Design maturity: {GREENFIELD|EMERGING|MATURE}
   Headless library: {radix|base-ui|ark|none}
   Styling approach: {tailwind|css-modules|css-custom-properties}

   Contract: {props interface}
   Sizing reference: {values from DESIGN.md for this component}
   Token dependencies: {semantic tokens this component uses}

   Requirements:
   - If headless library: wrap the library's primitive with styled layer
   - If no library: implement ARIA attributes, keyboard nav, focus management from scratch
   - Consume ONLY semantic tokens (never primitive tokens directly)
   - All sizes from the approved DESIGN.md reference (height, padding, font-size, radius)
   - States: hover, focus-visible, active, disabled, loading
   - Support compound component pattern for complex components (Select, Dialog, etc.)
   ```

3. **Test creation** — Write tests alongside the component:
   ```
   Write tests for {ComponentName} at {systemPath}/src/primitives/{component}/
   Cover:
   - Rendering all variants and sizes
   - Keyboard navigation (Tab, Enter, Space, Escape as applicable)
   - ARIA attributes present and correct
   - Disabled state prevents interaction
   - Loading state shows indicator and prevents interaction
   - Theme switching applies correct token values
   - Snapshot test for each variant/size combination
   - Visual regression baseline capture (screenshot per variant/state)
   - If compound component: test sub-component composition
   Use: vitest + @testing-library/react + axe-core for a11y
   ```

4. **Visual regression testing** — Capture visual baselines:
   ```
   Strategy (choose based on project setup):
   - Storybook + Chromatic: automated visual diff on every PR (recommended if Storybook installed)
   - Playwright screenshot comparison: headless browser captures per variant/state
   - Snapshot-based: CSS snapshot tests as lightweight proxy

   Coverage for each component:
   - All variants x all sizes (e.g., Button: 5 variants x 5 sizes = 25 combinations)
   - All interactive states (default, hover, focus, disabled, loading)
   - Both themes (light and dark)
   ```

5. **Accessibility validation** — Run axe-core:
   ```bash
   # In the test file:
   # import { axe } from 'jest-axe' or vitest equivalent
   # const results = await axe(container)
   # expect(results).toHaveNoViolations()
   ```

6. **Fix Loop Checkpoint** — Run the **Fix Loop Protocol** (see `operational-notes.md`) after each component:

   ```
   Checks: typecheck, lint, test
   Max attempts: 5
   ```

   Do NOT move to the next component until the loop passes. After ALL components in scope are implemented, run one final full-suite Fix Loop before proceeding to Phase 7.

## 6.3 Component Priority Order

```
Foundation (no dependencies):
  1. Token system + Theme provider
  2. Typography components (Heading, Text, Label)
  3. Layout primitives (Box, Stack, Grid, Container)

Core Interactive (depends on foundation):
  4. Button + IconButton
  5. Input / TextField
  6. TextArea
  7. Checkbox
  8. Radio / RadioGroup
  9. Select (compound component)
  10. Switch / Toggle

Overlay (depends on core — headless library most valuable here):
  11. Dialog / Modal (compound: Root, Trigger, Content, Title, Description, Close)
  12. Popover (compound: Root, Trigger, Content, Arrow)
  13. Tooltip
  14. Toast / Notification

Composed (depends on all above):
  15. Card
  16. Tabs (compound: Root, List, Trigger, Content)
  17. Menu / Dropdown (compound: Root, Trigger, Content, Item, Separator)
  18. Breadcrumbs
  19. Pagination
  20. Form / FormField (compound: Root, Label, Control, Description, ErrorMessage)
```

Only implement components within the user's chosen scope from Phase 1 Question 3.

**Status: DONE** — All components in scope implemented, tested, and accessible. Proceed to Phase 7: Storybook Integration.
