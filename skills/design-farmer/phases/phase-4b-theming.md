# Phase 4b: Theme & Styling

> Companion to Phase 4: Architecture Design. Load this file when the project
> has reached the theme system and styling approach decisions (§4b.1 onward).

## 4b.0 Theme Strategy Gate

Read `themeStrategy` from `DesignFarmerConfig` (set by Phase 1 Q5).

```
If themeStrategy = 'light-only':
  → Generate ONLY the light theme CSS in 4b.1 (skip [data-theme="dark"] block entirely)
  → Skip 4b.2 ThemeProvider (no theme switching needed — apply light tokens at :root)
  → Skip 4b.3 Scoped Theming
  → Skip 4b.4 Dark Mode Checklist
  → Proceed to 4b.5 Styling Approach Decision

If themeStrategy = 'light-dark', 'multi-brand', or 'custom':
  → Proceed to 4b.1 as written (generate both light and dark themes)
```

## 4b.1 Theme System

```css
/* light.css */
@layer tokens {
  [data-theme="light"] {
    /* Surface */
    --surface-default: oklch(1 0 0);
    --surface-subtle: oklch(0.97 0.005 250);
    --surface-muted: oklch(0.93 0.008 250);
    --surface-inverse: oklch(0.15 0.01 250);

    /* Text */
    --text-primary: oklch(0.15 0.01 250);
    --text-secondary: oklch(0.45 0.02 250);
    --text-inverse: oklch(1 0 0);
    --text-disabled: oklch(0.70 0.01 250);
    --text-tertiary: oklch(0.62 0.01 250);
    --text-brand: oklch(0.55 0.20 250);

    /* Interactive */
    --interactive-primary: oklch(0.55 0.20 250);
    --interactive-primary-hover: oklch(0.45 0.18 250);
    --interactive-bg: oklch(0.94 0.03 250);
    --interactive-text: oklch(0.45 0.18 250);
    --interactive-primary-active: oklch(0.38 0.16 250);

    /* Border */
    --border-default: oklch(0.87 0.01 250);
    --border-strong: oklch(0.70 0.02 250);
    --border-subtle: oklch(0.93 0.005 250);
    --border-focus: oklch(0.55 0.20 250);

    /* State */
    --state-success: oklch(0.55 0.18 145);
    --state-success-bg: oklch(0.94 0.05 145);
    --state-warning: oklch(0.65 0.18 75);
    --state-warning-text: oklch(0.45 0.14 75);
    --state-warning-bg: oklch(0.95 0.06 75);
    --state-error: oklch(0.55 0.22 25);
    --state-error-hover: oklch(0.45 0.20 25);
    --state-error-bg: oklch(0.95 0.06 25);
    --state-info: oklch(0.55 0.18 250);
    --state-info-bg: oklch(0.94 0.04 250);

    /* Shadows */
    --shadow-sm: 0 1px 3px oklch(0 0 0 / 0.06);
    --shadow-md: 0 4px 12px oklch(0 0 0 / 0.08);
    --shadow-lg: 0 8px 24px oklch(0 0 0 / 0.12);
    --shadow-xl: 0 16px 40px oklch(0 0 0 / 0.16);
  }

  /* dark.css — lightness inverted, hue/chroma preserved */
  [data-theme="dark"] {
    --surface-default: oklch(0.15 0.01 250);
    --surface-subtle: oklch(0.20 0.015 250);
    --surface-muted: oklch(0.25 0.018 250);
    --surface-inverse: oklch(0.97 0.005 250);

    --text-primary: oklch(0.95 0.005 250);
    --text-secondary: oklch(0.70 0.02 250);
    --text-inverse: oklch(0.15 0.01 250);
    --text-disabled: oklch(0.45 0.01 250);
    --text-tertiary: oklch(0.55 0.01 250);
    --text-brand: oklch(0.70 0.20 250);

    --interactive-primary: oklch(0.65 0.20 250);
    --interactive-primary-hover: oklch(0.72 0.18 250);
    --interactive-bg: oklch(0.22 0.04 250);
    --interactive-text: oklch(0.72 0.18 250);
    --interactive-primary-active: oklch(0.78 0.16 250);

    --border-default: oklch(0.30 0.015 250);
    --border-strong: oklch(0.45 0.02 250);
    --border-subtle: oklch(0.25 0.01 250);
    --border-focus: oklch(0.65 0.20 250);

    /* State */
    --state-success: oklch(0.65 0.18 145);
    --state-success-bg: oklch(0.20 0.05 145);
    --state-warning: oklch(0.72 0.18 75);
    --state-warning-text: oklch(0.82 0.14 75);
    --state-warning-bg: oklch(0.22 0.06 75);
    --state-error: oklch(0.65 0.22 25);
    --state-error-hover: oklch(0.72 0.20 25);
    --state-error-bg: oklch(0.22 0.06 25);
    --state-info: oklch(0.65 0.18 250);
    --state-info-bg: oklch(0.20 0.04 250);

    /* Shadows */
    --shadow-sm: 0 1px 3px oklch(0 0 0 / 0.20);
    --shadow-md: 0 4px 12px oklch(0 0 0 / 0.25);
    --shadow-lg: 0 8px 24px oklch(0 0 0 / 0.30);
    --shadow-xl: 0 16px 40px oklch(0 0 0 / 0.35);
  }
}
```

## 4b.2 Theme Provider Implementation

The theme provider depends on whether the user chose a library (Question 5-1) or custom:

**If using a library (next-themes, mode-watcher, etc.):**

Generate the following files based on the detected framework:

**Step 1 — Root layout (`app/layout.tsx` for Next.js):**

next-themes modifies `<html>` attributes on the client before hydration completes.
`suppressHydrationWarning` on `<html>` is **REQUIRED** to prevent React hydration mismatch
warnings. This prop only applies one level deep, so it does NOT mask errors in children.

```tsx
// app/layout.tsx
import { type ReactNode } from 'react'
import { ThemeProvider } from '@/components/theme-provider'

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head />
      <body>
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  )
}
```

**CRITICAL: `suppressHydrationWarning` MUST be on the `<html>` tag, not on `<body>` or
any other element. Without it, every page load will emit a React hydration mismatch
warning in the console because next-themes sets `data-theme` (or `class`) on `<html>`
before React hydrates.**

**Step 2 — ThemeProvider wrapper (client component):**

```tsx
// components/theme-provider.tsx
"use client"

import { type ReactNode } from 'react'
import { ThemeProvider as NextThemesProvider } from 'next-themes'

export function ThemeProvider({ children }: { children: ReactNode }) {
  return (
    <NextThemesProvider
      attribute="data-theme"          // matches our CSS selectors ([data-theme="dark"])
      defaultTheme="system"           // respect OS preference
      enableSystem                    // listen for OS changes
      disableTransitionOnChange       // prevent FOUC during switch
    >
      {children}
    </NextThemesProvider>
  )
}

// Re-export useTheme from the library for consumer convenience:
export { useTheme } from 'next-themes'
```

**Step 3 — Safe useTheme consumption (hydration guard):**

`useTheme()` returns `undefined` for `theme` on the server. Any component that renders
UI based on the current theme MUST guard against the mounting state to avoid hydration
mismatches:

```tsx
// Example: theme toggle component
"use client"

import { useState, useEffect } from 'react'
import { useTheme } from 'next-themes'

export function ThemeToggle() {
  const [mounted, setMounted] = useState(false)
  const { resolvedTheme, setTheme } = useTheme()

  useEffect(() => { setMounted(true) }, [])

  if (!mounted) return null  // or return a skeleton/placeholder

  return (
    <button onClick={() => setTheme(resolvedTheme === 'dark' ? 'light' : 'dark')}>
      {resolvedTheme === 'dark' ? '☀️' : '🌙'}
    </button>
  )
}
```

**IMPORTANT: Use `resolvedTheme` (not `theme`) when you need the actual current mode.
`theme` returns `'system'` when system preference is active, while `resolvedTheme`
always returns the resolved value (`'light'` or `'dark'`).**

**Step 4 — Tailwind CSS integration (if Tailwind detected):**

If using `attribute="class"` (for Tailwind `dark:` utilities), configure:

```js
// tailwind.config.js (v3) or tailwind.config.ts
module.exports = { darkMode: 'selector' }  // Tailwind >= 3.4.1
// or: darkMode: 'class'                   // Tailwind < 3.4.1
```

```css
/* Tailwind v4: dark mode is configured in CSS, not tailwind.config.js */
/* In your main CSS entry point (e.g., globals.css or tokens.css): */
@import "tailwindcss";

/* Option A: data-theme attribute strategy */
@custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *));

/* Option B: class strategy (for next-themes attribute="class") */
/* @custom-variant dark (&:where(.dark, .dark *)); */

/* After this, Tailwind's dark: variant works with your chosen strategy: */
/* dark:bg-primary-900, dark:text-primary-50, etc. */
```

When using `attribute="class"`, `ThemeProvider` toggles `class="dark"` on `<html>`,
which Tailwind's `dark:` variant reads. When using `attribute="data-theme"` (default),
configure Tailwind's dark mode selector accordingly:

```js
// tailwind.config.js (v3)
module.exports = { darkMode: ['selector', '[data-theme="dark"]'] }
```

**If custom implementation:**

```typescript
// theme-provider.tsx — full custom implementation
//
// Key responsibilities:
// 1. Read initial theme: check localStorage -> fallback to OS preference -> fallback to 'light'
// 2. SSR hydration safety: inject a blocking <script> in <head> that sets data-theme
//    BEFORE React hydrates. This prevents the dark-mode flash.
//
//    <!-- In document head (Next.js: app/layout.tsx, Vite: index.html) -->
//    <!-- IMPORTANT: Add suppressHydrationWarning to <html> in Next.js App Router -->
//    <html suppressHydrationWarning>
//    <script>
//      (function() {
//        var t = localStorage.getItem('theme');
//        if (!t) t = matchMedia('(prefers-color-scheme:dark)').matches ? 'dark' : 'light';
//        document.documentElement.setAttribute('data-theme', t);
//      })()
//    </script>
//
// 3. React context provides: { theme, setTheme, resolvedTheme, systemTheme }
// 4. Listen for OS preference changes via matchMedia change event
// 5. Sync to localStorage on every change
// 6. Apply data-theme attribute on documentElement
// 7. Provide a mounted guard hook for SSR-safe theme-dependent rendering
```

## 4b.3 Scoped Theming

Support nested themes for sections that need different color schemes within the same page:

```html
<!-- Main page uses light theme -->
<div data-theme="light">
  <header>...</header>
  <main>
    <!-- This section forces dark theme regardless of page theme -->
    <section data-theme="dark" class="hero-banner">
      <h1 style="color: var(--text-primary)">...</h1>
      <!-- CSS custom properties resolve from the nearest data-theme ancestor -->
    </section>
  </main>
</div>
```

Scoped theming works automatically with CSS custom property inheritance — no additional
JavaScript needed. The nearest `[data-theme]` ancestor wins. Components consume
`var(--token-name)` and automatically get the correct value for their theme context.

## 4b.4 Dark Mode Implementation Checklist & Common Failures

**MANDATORY verification after implementing dark mode. Check every item before proceeding.**

### Implementation Checklist

```
[ ] <html> has suppressHydrationWarning (Next.js App Router with next-themes)
[ ] ThemeProvider is a "use client" component
[ ] ThemeProvider wraps children inside <body>, NOT outside <html>
[ ] attribute prop matches CSS selectors ([data-theme] vs .dark class)
[ ] attribute prop matches Tailwind darkMode config (if Tailwind used)
[ ] attribute prop matches Storybook decorator type (if Storybook used)
[ ] All theme-dependent UI components use mounted guard pattern
[ ] resolvedTheme used (not theme) for runtime theme checks
[ ] disableTransitionOnChange set to prevent FOUC during switch
[ ] Both light AND dark token sets define ALL semantic tokens (no missing variables)
[ ] CSS selectors use [data-theme="dark"] or .dark consistently (never mixed)
[ ] No hardcoded color values in components — all via var(--token-name)
```

### Common Dark Mode Failure Patterns

| # | Failure | Root Cause | Fix |
|---|---------|-----------|-----|
| 1 | Hydration mismatch warning on every page load | Missing `suppressHydrationWarning` on `<html>` | Add `suppressHydrationWarning` to `<html>` in root layout |
| 2 | White flash before dark theme appears (FOUC) | Theme library script deferred by CDN (e.g. Cloudflare Rocket Loader) | Add `scriptProps={{ 'data-cfasync': 'false' }}` to ThemeProvider |
| 3 | Theme toggle works but UI doesn't change | Attribute mismatch: ThemeProvider uses `data-theme` but CSS targets `.dark` class | Align ThemeProvider `attribute` with CSS selectors |
| 4 | `theme` always returns `'system'` | Using `theme` instead of `resolvedTheme` | Use `resolvedTheme` for actual light/dark value |
| 5 | Theme-dependent icons/text render wrong on first load | Rendering theme UI without mount guard | Add `mounted` state check before rendering theme-dependent content |
| 6 | Storybook theme toggle has no effect | Storybook decorator type doesn't match app's attribute strategy | Match `withThemeByClassName` / `withThemeByDataAttribute` to app config |
| 7 | Some components stay light in dark mode | Component uses hardcoded colors instead of CSS variables | Replace all hardcoded colors with `var(--semantic-token)` |
| 8 | Dark mode colors look washed out or neon | Chroma (C) not adjusted for dark backgrounds in OKLCH | Reduce chroma slightly for dark mode surfaces; increase for accents |
| 9 | Text is unreadable in dark mode | Missing contrast re-validation for inverted lightness | Re-run APCA contrast check for all dark mode fg/bg pairs |
| 10 | Adding new theme requires touching component files | Components reference primitive tokens (e.g. `--color-gray-900`) | Enforce semantic-token-only rule: components use `--surface-*`, `--text-*` only |
| 11 | Tailwind `dark:` utilities don't activate | Tailwind `darkMode` config doesn't match ThemeProvider attribute | Set `darkMode: 'selector'` or `['selector', '[data-theme="dark"]']` |
| 12 | CSS transitions flash mid-theme-switch | Transitions fire during attribute change before new tokens resolve | Set `disableTransitionOnChange` on ThemeProvider |

### Attribute Alignment Reference

All three systems (ThemeProvider, CSS/Tailwind, Storybook) must agree on the same
attribute mechanism. Use this table to verify alignment:

```
Strategy A — data-theme attribute (recommended for CSS custom properties):
  ThemeProvider:   attribute="data-theme"
  CSS selectors:   [data-theme="dark"] { ... }
  Tailwind:        darkMode: ['selector', '[data-theme="dark"]']
  Storybook:       withThemeByDataAttribute({ attributeName: 'data-theme' })

Strategy B — class attribute (recommended for Tailwind-first projects):
  ThemeProvider:   attribute="class"
  CSS selectors:   .dark { ... }  or  :root.dark { ... }
  Tailwind:        darkMode: 'selector'  (or 'class' for Tailwind < 3.4.1)
  Storybook:       withThemeByClassName({ themes: { dark: 'dark' } })
```

**Pick ONE strategy and use it consistently. Mixing strategies is the #1 cause of
dark mode failures in design systems.**

## 4b.5 Styling Approach Decision

Based on the codebase analysis (Phase 2), recommend the appropriate styling strategy:

```
If Tailwind v4 detected:
  -> Use @theme for tokens + Tailwind utilities for components
  -> Component styles as Tailwind class compositions
  -> Example: <button class="bg-primary-500 text-on-primary rounded-md px-4 py-2">

If Tailwind v3 detected:
  -> Extend tailwind.config with token values
  -> Use @apply sparingly (prefer direct classes)
  -> Plan migration path to v4 @theme

If CSS Modules detected:
  -> Generate .module.css files per component consuming CSS custom properties
  -> Example: .button { background: var(--interactive-primary); }

If styled-components / Emotion detected:
  -> Generate theme object from tokens for ThemeProvider
  -> Components consume via theme prop or css`` template

If vanilla-extract detected (*.css.ts files, @vanilla-extract/css in package.json):
  -> Use createThemeContract + createTheme for token implementation
  -> Token hierarchy maps directly to vanilla-extract's contract structure:
     - Primitive tokens  → define raw scale values in a plain object (not a contract)
     - Semantic contract → createThemeContract({ color: { interactive: { primary: '' }, surface: { default: '' } } })
     - Light theme       → createTheme(contract, { color: { interactive: { primary: 'oklch(0.55 0.20 250)' }, surface: { default: 'oklch(0.98 0.00 0)' } } })
     - Dark theme        → createTheme(contract, { color: { interactive: { primary: 'oklch(0.70 0.18 250)' }, surface: { default: 'oklch(0.12 0.00 0)' } } })
  -> Components use style() or recipe() with contract references:
     background: vars.color.interactive.primary   // TypeScript-safe: key exists in contract
  -> Contract shape must exactly match consumption paths (vars.color.X.Y); mismatches are TypeScript errors
  -> Zero runtime overhead, RSC compatible, full TypeScript safety
  -> No separate CSS file needed — .css.ts files generate static CSS at build time

If Panda CSS detected (panda.config.ts, styled-system/ directory):
  -> Define tokens in panda.config defineConfig():
     theme: {
       tokens: { colors: { primary: { 500: { value: 'oklch(0.55 0.20 250)' } } } },
       semanticTokens: { colors: { surface: { value: { base: '{colors.primary.50}', _dark: '{colors.primary.900}' } } } }
     }
  -> The Panda config's tokens/semanticTokens structure mirrors this design system's
     primitive/semantic two-tier naming convention directly
  -> Components use css() or styled() with semantic token references
  -> Zero runtime overhead, RSC compatible, automatic dark mode via semanticTokens conditions
  -> Built-in OKLCH support: value: 'oklch(0.55 0.20 250)' works natively

If no styling framework detected:
  -> Default to CSS custom properties + vanilla CSS
  -> Lightweight, zero-dependency approach
  -> Consider recommending Tailwind v4 for utility-first workflow
```

**Status: DONE** — Theme system, provider implementation, dark mode checklist, and styling approach defined. Proceed to Phase 4.5: Design Source of Truth (DESIGN.md).
