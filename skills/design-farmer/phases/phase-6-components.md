# Phase 6: Component Implementation

Implement components ONE AT A TIME, in dependency order.

The implementation path depends on **Design Maturity** (from Phase 2) and **Headless Library**
choice (from Question 3-1):

## 6.0 Path Selection

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
import * as React from 'react'
// import { Slot } from '@radix-ui/react-slot'  // for asChild pattern

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger' | 'outline'
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl'
  loading?: boolean
  asChild?: boolean  // Radix slot pattern: render as child element
}

// Component consumes ONLY semantic tokens via CSS custom properties.
// Sizing values from the approved design reference (DESIGN.md):
//   sm: h-32px px-12px text-14px
//   md: h-36px px-16px text-14px
//   lg: h-40px px-20px text-16px
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
     size: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
     disabled?: boolean;
     loading?: boolean;
     asChild?: boolean;  // slot pattern (if headless library supports it)
     children: React.ReactNode;
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

6. **Verify and proceed** — Run tests, check for zero errors, then move to next component.

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
