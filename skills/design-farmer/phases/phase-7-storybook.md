# Phase 7: Storybook Integration

**Theme strategy check:** Read `themeStrategy` from `{systemPath}/.design-farmer/config.json`. If `themeStrategy = 'light-only'`, skip dark mode decorator setup (Step 4 below), skip theme toggle addon, and skip Dimension 4 (Theme Axis) story generation — dark mode stories and controls are unnecessary for light-only projects.

Via AskUserQuestion, ask:

> Your components are implemented and tested. Storybook provides interactive documentation,
> visual testing, and a component playground.
>
> **Would you like to add Storybook?** (Recommended)
>
> RECOMMENDATION: Choose A — Storybook serves as living documentation and catches visual
> regressions that unit tests miss.
>
> Options:
> - A) Yes, full setup — Install Storybook (latest) with stories for all components, accessibility addon, dark mode support, and auto-generated docs
> - B) Yes, minimal — Install Storybook with basic stories only
> - C) No, skip Storybook — Rely on tests and code documentation only

**→ STOP — wait for user response before continuing.**

If user chose C (skip Storybook):
1. Set `storybookSkipped: true` in `{systemPath}/.design-farmer/config.json` (signals downstream phases that Storybook was skipped by user choice). Also update `config.backup.json`.
2. Do NOT append `'phase-7'` to `completedPhases` — the phase did not run.
3. Emit:

**Status: DONE** — User chose to skip Storybook. Proceeding to Phase 8: Multi-Reviewer Verification with code-based tests only.

Then stop — do NOT execute steps 0–4.

---

If user chose A or B:

**Step 0 — (Monorepo only) Determine Storybook location:**

If a monorepo was detected in Phase 0 (pnpm-workspace.yaml / turbo.json / nx.json / lerna.json present),
ask the user via AskUserQuestion:

> Your project is a monorepo. Where should Storybook live?
>
> RECOMMENDATION: Choose A — co-locating Storybook with the design system keeps stories next to source,
> simplifies imports, and avoids cross-package path configuration.
>
> Options:
> - A) Inside the design system package — `{systemPath}/.storybook/` (co-located, recommended)
> - B) Dedicated storybook app — `apps/storybook/` or `packages/storybook/` (isolated, good for multi-package docs)
> - C) Custom path — specify where you want it
>
> **→ STOP — wait for user response before continuing.**

Store the resolved path as `{storybookRoot}` for all subsequent steps.
If the project is NOT a monorepo, set `{storybookRoot}` to `{systemPath}` and skip this question.

---

**Step 1 — Look up the latest stable Storybook version before installing:**

```bash
# Check the latest stable version from npm
npm view storybook version
# Also check addon compatibility
npm view @storybook/addon-a11y version
npm view @storybook/addon-themes version
npm view @storybook/addon-docs version
```

Use the actual latest version from npm — do NOT hardcode any specific major version.
Storybook releases frequently (7.x -> 8.x -> 9.x -> ...) and addons must match the
installed Storybook major version. Always verify compatibility before installing.

**Step 2 — Delegate installation:**

```
Install and configure Storybook at {storybookRoot}:

IMPORTANT: First run `npm view storybook version` to determine the latest stable version.
Use that version throughout — do NOT assume any specific major version number.

1. Install: run `storybook@latest init` from {storybookRoot} using the detected package manager
   - npm: `cd {storybookRoot} && npx storybook@latest init`
   - yarn: `cd {storybookRoot} && yarn dlx storybook@latest init`
   - pnpm: `cd {storybookRoot} && pnpm dlx storybook@latest init`
   - bun: `cd {storybookRoot} && bunx storybook@latest init`
   - For monorepo Option B (dedicated app at e.g. `apps/storybook`):
     a. Create `apps/storybook/package.json` with the design system as a workspace dependency
        (`{scope}` is the npm scope from `designSystemPackage`, e.g. `@acme` from `@acme/design-system`):
        `{ "name": "@{scope}/storybook", "version": "0.0.1", "private": true,
           "dependencies": { "{designSystemPackage}": "workspace:*" } }`
     b. Register the package in `pnpm-workspace.yaml` (if not already covered by glob, add `- 'apps/*'`)
     c. If turbo.json exists, add `storybook` and `build-storybook` tasks to the pipeline
     d. Run init from inside the new package: `cd apps/storybook && {packageManager} dlx storybook@latest init`
     e. In `apps/storybook/.storybook/main.ts`, set the `stories` glob to reach the design system:
        `stories: ['../../packages/{designSystemDir}/src/**/*.stories.@(ts|tsx)']`
     f. Import the design system's tokens/CSS from the workspace package in `preview.tsx`:
        `import '{designSystemPackage}/src/tokens/index.css'`
   - IMPORTANT: After init, add `@storybook/react` to the design system package's devDependencies:
     `{packageManager} --filter {designSystemPackage} add -D @storybook/react@latest`
     This installs the @storybook/react type definitions inside the design system package so
     the IDE recognizes `Meta`, `StoryObj`, etc. in `.stories.tsx` files without the TypeScript
     TS17004/TS6142 errors that appear when stories are excluded from the main tsconfig.
   - After init, verify the installed version: `npx storybook --version` (or the equivalent for your package manager)
   - Confirm the installed major version matches the addon versions fetched in Step 1
   - If `storybook init` fails (timeout, version conflict, missing dependency):
     1. Log: "[DEGRADATION] Phase 7: storybook init failed ({reason}). Using manual config."
     2. Create `.storybook/main.ts` manually with framework-appropriate config (see Step 2.5 templates)
     3. Create `.storybook/preview.ts` with design system token imports
     4. In degraded mode, generate stories only for dimensions 1–3 (Variant, Size, State) instead of all 11 dimensions. This ensures basic coverage without requiring full Storybook configuration.
     5. Continue with DONE_WITH_CONCERNS
2. Configure addons (ensure versions match the installed Storybook major version):
   - @storybook/addon-a11y (accessibility checking)
   - @storybook/addon-themes (dark mode toggle)
   - @storybook/addon-docs (auto documentation)
3. Configure {storybookRoot}/.storybook/preview.tsx:
   - Import the design system's global CSS (tokens, reset, theme files)
   - Set up theme decorator for dark mode toggle (see 'Storybook Dark Mode Decorator' below)
   - Configure viewport presets (mobile: 375px, tablet: 768px, desktop: 1280px)
   - Enable autodocs for automatic API documentation generation
4. Create stories for every implemented component following the Polymorphic Coverage
   Matrix defined in Step 3 below.
```

**Step 2.5 — Concrete configuration file templates:**

After `storybook@latest init` generates the base config, update the configuration files to match these templates:

**`apps/storybook/.storybook/main.ts`:**
```typescript
import type { StorybookConfig } from "@storybook/react-vite";

const config: StorybookConfig = {
  stories: ["../../packages/{designSystemDir}/src/**/*.stories.@(ts|tsx)"],
  addons: [
    "@storybook/addon-docs",
    "@storybook/addon-a11y",
    "@storybook/addon-themes",
  ],
  framework: {
    name: "@storybook/react-vite",
    options: {},
  },
};

export default config;
```

Note: Use `@storybook/react-vite` framework for Vite-based projects (most monorepos). Use `@storybook/react-webpack5` only if the project uses webpack.

**`apps/storybook/.storybook/preview.tsx`:**
```typescript
import type { Preview } from "@storybook/react";
import "../../packages/{designSystemDir}/src/styles/index.css";

const preview: Preview = {
  parameters: {
    layout: "centered",
    docs: {
      toc: true,
    },
  },
  tags: ["autodocs"],
};

export default preview;
```

**`apps/storybook/package.json`:**
```json
{
  "name": "@{scope}/storybook",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "storybook": "storybook dev --port 6006",
    "build-storybook": "storybook build"
  },
  "dependencies": {
    "{designSystemPackage}": "workspace:*"
  },
  "devDependencies": {
    "@storybook/addon-a11y": "latest",
    "@storybook/addon-docs": "latest",
    "@storybook/addon-themes": "latest",
    "@storybook/react-vite": "latest",
    "storybook": "latest"
  }
}
```

**Critical rules for story files:**
1. Always use the EXACT prop values defined in the component's TypeScript interface
   - ✅ `size="small"` if the component defines `"small" | "medium" | "large"`
   - ❌ `size="sm"` — this will fail TypeScript and show errors in the IDE
2. Import types from the design system package: `import type { Meta, StoryObj } from "@storybook/react"`
3. Always define `meta.component` so autodocs generates the props table
4. Use `render: () => (...)` for complex multi-instance stories
5. Use `args` for single-instance stories where possible

**Step 3 — Polymorphic Coverage Story Generation:**

Every component MUST have stories covering the following 11 dimensions. This ensures
that all visual variants, interactive states, and edge cases are documented and testable.

Use CSF3 format (Component Story Format 3) with `Meta` + `StoryObj` typing for all stories.

**Story file naming convention:** `{ComponentName}.stories.tsx`

**Dimension 1 — Variant Axis (CRITICAL):**
Every visual variant of a component gets its own named story export, PLUS an AllVariants
grid story showing all variants side-by-side for comparison.

```tsx
// Example: Button.stories.tsx
export const Primary: Story = { args: { variant: 'primary', children: 'Primary' } }
export const Secondary: Story = { args: { variant: 'secondary', children: 'Secondary' } }
export const Ghost: Story = { args: { variant: 'ghost', children: 'Ghost' } }
export const Danger: Story = { args: { variant: 'danger', children: 'Danger' } }

// Grid story: all variants in one view
export const AllVariants: Story = {
  render: () => (
    <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
      {['primary', 'secondary', 'ghost', 'danger'].map(v => (
        <Button key={v} variant={v}>{v}</Button>
      ))}
    </div>
  ),
}
```

**Dimension 2 — Size Axis (CRITICAL):**
Every size option gets a dedicated story, PLUS an AllSizes comparison story.

```tsx
export const Small: Story = { args: { size: 'small', children: 'Small' } }
export const Medium: Story = { args: { size: 'medium', children: 'Medium' } }
export const Large: Story = { args: { size: 'large', children: 'Large' } }

export const AllSizes: Story = {
  render: () => (
    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
      {['small', 'medium', 'large'].map(s => (
        <Button key={s} size={s}>{s}</Button>
      ))}
    </div>
  ),
}
```

**Dimension 3 — State Axis (CRITICAL):**
Interactive states: disabled, loading, error. Use `play` functions for hover/focus/active.

```tsx
export const Disabled: Story = { args: { disabled: true, children: 'Disabled' } }
export const Loading: Story = { args: { loading: true, children: 'Loading...' } }

// Play function for interaction testing
export const FocusState: Story = {
  play: async ({ canvasElement }) => {
    const button = canvasElement.querySelector('button')
    button?.focus()
  },
}
```

**Dimension 4 — Theme Axis:**

**If `themeStrategy = 'light-only'`: skip this entire dimension — no theme switching exists for light-only projects.** Do not generate ThemeComparison stories.

Theme decorator is configured globally in the preview setup described below. Add a dedicated side-by-side
comparison story per component:

```tsx
export const ThemeComparison: Story = {
  render: () => (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
      <div data-theme="light" style={{ padding: '1rem', background: 'var(--surface-default)' }}>
        <Button variant="primary">Light Mode</Button>
      </div>
      <div data-theme="dark" style={{ padding: '1rem', background: 'var(--surface-default)' }}>
        <Button variant="primary">Dark Mode</Button>
      </div>
    </div>
  ),
}
```

**Dimension 5 — Color Axis:**
For components with a `color` prop, create a color palette grid:

```tsx
export const AllColors: Story = {
  render: () => (
    <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
      {['primary', 'success', 'warning', 'danger', 'info'].map(c => (
        <Badge key={c} color={c}>{c}</Badge>
      ))}
    </div>
  ),
}
```

**Dimension 6 — Composition Axis (CRITICAL):**
Compound components (Select, Dialog, Tabs, Menu, Form) need stories showing the
full part assembly:

```tsx
// Example: Dialog composition story
export const FullComposition: Story = {
  render: () => (
    <Dialog>
      <DialogTrigger asChild><Button>Open Dialog</Button></DialogTrigger>
      <DialogContent>
        <DialogTitle>Title</DialogTitle>
        <DialogDescription>Description text.</DialogDescription>
        <DialogClose asChild><Button variant="ghost">Close</Button></DialogClose>
      </DialogContent>
    </Dialog>
  ),
}

// Minimal composition
export const BasicComposition: Story = {
  render: () => (
    <Dialog>
      <DialogTrigger>Open</DialogTrigger>
      <DialogContent><DialogTitle>Title</DialogTitle></DialogContent>
    </Dialog>
  ),
}

// Real-world usage pattern
export const ConfirmationDialog: Story = {
  render: () => (
    <Dialog>
      <DialogTrigger asChild><Button variant="danger">Delete</Button></DialogTrigger>
      <DialogContent>
        <DialogTitle>Are you sure?</DialogTitle>
        <DialogDescription>This action cannot be undone.</DialogDescription>
        <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'flex-end' }}>
          <DialogClose asChild><Button variant="ghost">Cancel</Button></DialogClose>
          <Button variant="danger">Delete</Button>
        </div>
      </DialogContent>
    </Dialog>
  ),
}
```

**Dimension 7 — Slot / Children Axis:**
Show all possible children patterns:

```tsx
export const TextOnly: Story = { args: { children: 'Button' } }
export const WithLeadingIcon: Story = { args: { children: <><IconPlus /> Add Item</> } }
export const WithTrailingIcon: Story = { args: { children: <>Next <IconArrowRight /></> } }
export const IconOnly: Story = { args: { children: <IconSearch />, 'aria-label': 'Search' } }
export const WithBadge: Story = { args: { children: <>Inbox <Badge>3</Badge></> } }
```

**Dimension 8 — Polymorphic `as` / `asChild` Axis:**
If a component supports rendering as different elements:

```tsx
export const AsButton: Story = { args: { children: 'Button (default)' } }
export const AsLink: Story = {
  args: { asChild: true, children: <a href="#">As Link</a> },
}
export const AsRouterLink: Story = {
  args: { asChild: true, children: <Link href="/page">Router Link</Link> },
}
```

**Dimension 9 — Responsive Axis:**
Use Storybook viewport parameters:

```tsx
export const Mobile: Story = {
  parameters: { viewport: { defaultViewport: 'mobile1' } },
  args: { children: 'Mobile view', fullWidth: true },
}
export const Tablet: Story = {
  parameters: { viewport: { defaultViewport: 'tablet' } },
}
```

**Dimension 10 — Accessibility Axis:**
Keyboard navigation and focus management via play functions:

```tsx
export const KeyboardNavigation: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement)
    const trigger = canvas.getByRole('button')
    await userEvent.tab()  // focus trigger
    await userEvent.keyboard('{Enter}')  // open
    await userEvent.keyboard('{Escape}')  // close
  },
}

export const FocusTrap: Story = {
  name: 'Focus Trap (Dialog)',
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement)
    await userEvent.click(canvas.getByRole('button'))
    // Tab should cycle within dialog, not escape to background
    await userEvent.tab()
    await userEvent.tab()
    await userEvent.tab()
  },
}
```

**Dimension 11 — Edge Case Axis:**
Boundary conditions and unusual content:

```tsx
export const LongText: Story = {
  args: { children: 'This is a very long button label that should handle overflow gracefully' },
}
export const EmptyChildren: Story = { args: { children: '' } }
export const Overflow: Story = {
  decorators: [(Story) => <div style={{ width: '100px' }}><Story /></div>],
  args: { children: 'Overflow container test' },
}
```

**Coverage verification checklist** — After generating all stories, verify:

```
[ ] Every component has a .stories.tsx file
[ ] Every prop with discrete options has individual named stories + AllX grid story
[ ] Every interactive state has a story (disabled, loading, error if applicable)
[ ] Compound components have Basic, Full, and RealWorld composition stories
[ ] Theme comparison story exists for every component
[ ] Play functions test keyboard navigation for interactive components
[ ] Edge case stories exist (long text, empty, overflow)
[ ] Polymorphic as/asChild patterns have dedicated stories (if component supports it)
[ ] `npm run storybook` starts without errors
[ ] All stories render correctly in both light and dark themes
```

**Story count expectation by component type:**

| Component Type | Minimum Stories | Example |
|---------------|----------------|---------|
| Simple (Button, Badge) | 15-25 | Variants + Sizes + States + Slots + Theme + Edge |
| Form (Input, Select) | 10-20 | States + Validation + Composition + Accessibility |
| Compound (Dialog, Tabs) | 8-15 | Basic + Full + RealWorld + Keyboard + FocusTrap |
| Layout (Stack, Grid) | 5-10 | Directions + Spacing + Responsive + Nested |
| Typography (Heading, Text) | 5-8 | Levels + Weights + Truncation + As polymorphic |

**Step 4 — Storybook Dark Mode Decorator Configuration:**

The decorator in `{storybookRoot}/.storybook/preview.tsx` MUST match the `attribute` used by the app's
`ThemeProvider`. A mismatch means the Storybook toggle changes state but components
render with wrong theme styles.

```typescript
// {storybookRoot}/.storybook/preview.ts

// === Option A: data-attribute based (default for next-themes attribute="data-theme") ===
import { withThemeByDataAttribute } from '@storybook/addon-themes'

const preview = {
  decorators: [
    withThemeByDataAttribute({
      themes: {
        light: 'light',
        dark: 'dark',
      },
      defaultTheme: 'light',
      attributeName: 'data-theme',  // MUST match ThemeProvider's attribute prop
    }),
  ],
}

// === Option B: class based (for next-themes attribute="class" / Tailwind dark:) ===
import { withThemeByClassName } from '@storybook/addon-themes'

const preview = {
  decorators: [
    withThemeByClassName({
      themes: {
        light: '',       // no class = light mode
        dark: 'dark',    // class="dark" for Tailwind dark: variant
      },
      defaultTheme: 'light',
    }),
  ],
}
```

**CRITICAL attribute alignment rule:**

| ThemeProvider `attribute` | Storybook decorator | Storybook `attributeName` |
|--------------------------|---------------------|--------------------------|
| `"data-theme"` (default) | `withThemeByDataAttribute` | `"data-theme"` |
| `"class"` (Tailwind) | `withThemeByClassName` | N/A |
| `"data-mode"` (custom) | `withThemeByDataAttribute` | `"data-mode"` |

If the app uses `attribute="class"` but Storybook uses `withThemeByDataAttribute`,
or vice versa, dark mode will appear to work in the app but fail silently in Storybook.
Always verify both sides use the same mechanism.

## Fix Loop Checkpoint

After Storybook installation, configuration, and story generation, run the **Fix Loop Protocol** (see `operational-notes.md`):

```
Checks: typecheck, build (storybook build)
Max attempts: 5
```

If the Fix Loop exhausts all 5 attempts without passing, emit **Status: DONE_WITH_CONCERNS** — Fix Loop did not converge after 5 attempts. Proceed to Phase 8, but note that Storybook may have build warnings. Do NOT emit BLOCKED. Ensure `completedPhases` exists in config.json (initialize as `[]` if undefined). If `'phase-7'` is already present in the array, skip the append (idempotent). Otherwise, append `'phase-7'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Also update `config.backup.json`.

Common Storybook errors:

| Error Pattern | Root Cause | Fix |
|--------------|-----------|-----|
| `Cannot find module '@storybook/react'` | Missing devDependency in design system package | `{packageManager} --filter {designSystemPackage} add -D @storybook/react@latest` |
| `TS6142: Module was resolved to .stories.tsx but jsx is not set` | Stories not covered by tsconfig | Add `@storybook/react` types or check tsconfig include paths |
| `Addon version mismatch` | Storybook core and addon major versions differ | Align all @storybook/* packages to same major |

**Status: DONE** (Fix Loop: passed on attempt {N}/5) — Storybook configured with stories for all components, accessibility addon, and dark mode support. Proceed to Phase 8: Multi-Reviewer Verification.

Before emitting status, ensure `completedPhases` exists in config.json (initialize as `[]` if undefined), then append `'phase-7'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. If `'phase-7'` is already present, skip the append (idempotent). Also update `config.backup.json`.
