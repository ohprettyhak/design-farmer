# Phase 4: Architecture Design

## 4.1 Token Hierarchy (DTCG Standard)

Design a three-tier token structure following the Design Tokens Community Group format:

```json
// Tier 1: Primitive Tokens (raw values)
{
  "color": {
    "blue": {
      "50":  { "$value": "oklch(0.95 0.02 250)", "$type": "color" },
      "100": { "$value": "oklch(0.90 0.04 250)", "$type": "color" },
      "200": { "$value": "oklch(0.82 0.07 250)", "$type": "color" },
      "300": { "$value": "oklch(0.72 0.12 250)", "$type": "color" },
      "400": { "$value": "oklch(0.64 0.17 250)", "$type": "color" },
      "500": { "$value": "oklch(0.55 0.20 250)", "$type": "color" },
      "600": { "$value": "oklch(0.47 0.19 250)", "$type": "color" },
      "700": { "$value": "oklch(0.40 0.18 250)", "$type": "color" },
      "800": { "$value": "oklch(0.32 0.15 250)", "$type": "color" },
      "900": { "$value": "oklch(0.22 0.11 250)", "$type": "color" },
      "950": { "$value": "oklch(0.15 0.08 250)", "$type": "color" }
    }
  }
}

// Tier 2: Semantic Tokens (purpose-driven aliases)
{
  "surface": {
    "default":   { "$value": "{color.white}", "$type": "color" },
    "subtle":    { "$value": "{color.gray.50}", "$type": "color" },
    "inverse":   { "$value": "{color.gray.900}", "$type": "color" }
  },
  "text": {
    "primary":   { "$value": "{color.gray.900}", "$type": "color" },
    "secondary": { "$value": "{color.gray.600}", "$type": "color" },
    "inverse":   { "$value": "{color.white}", "$type": "color" },
    "brand":     { "$value": "{color.blue.500}", "$type": "color" }
  },
  "border": {
    "default":   { "$value": "{color.gray.200}", "$type": "color" },
    "strong":    { "$value": "{color.gray.400}", "$type": "color" },
    "brand":     { "$value": "{color.blue.500}", "$type": "color" }
  },
  "interactive": {
    "primary":        { "$value": "{color.blue.500}", "$type": "color" },
    "primary-hover":  { "$value": "{color.blue.700}", "$type": "color" },
    "primary-active": { "$value": "{color.blue.800}", "$type": "color" }
  }
}

// Tier 3: Component Tokens (component-specific)
{
  "button": {
    "primary": {
      "background":       { "$value": "{interactive.primary}", "$type": "color" },
      "background-hover": { "$value": "{interactive.primary-hover}", "$type": "color" },
      "text":             { "$value": "{text.inverse}", "$type": "color" },
      "border-radius":    { "$value": "{radius.md}", "$type": "dimension" }
    }
  }
}
```

## 4.2 Directory Structure

Generate based on the user's configuration:

```
{For monorepo — packages/design-system:}

packages/design-system/
  package.json
  tsconfig.json
  src/
    tokens/
      primitive/
        colors.ts          # OKLCH primitive color palette
        typography.ts       # Font families, sizes, weights
        spacing.ts          # Spacing scale
        radius.ts           # Border radius scale
        shadow.ts           # Shadow definitions
        motion.ts           # Animation/transition tokens
        z-index.ts          # Z-index scale
      semantic/
        colors.ts           # Purpose-driven color aliases
        typography.ts       # Text style compositions
      component/
        button.ts           # Button-specific tokens
        input.ts            # Input-specific tokens
        ...
      index.ts              # Token barrel export
      build.ts              # Token build script (JSON/TS -> CSS vars)
    themes/
      light.css             # Light theme CSS custom properties
      dark.css              # Dark theme CSS custom properties
      theme-provider.tsx    # Theme context and switching logic
    primitives/
      button/
        button.tsx          # Button component
        button.test.tsx     # Button tests
        button.css          # Button styles (CSS modules or vanilla)
        index.ts
      input/
        input.tsx
        input.test.tsx
        input.css
        index.ts
      ...
    components/
      ... (composed components built on primitives)
    hooks/
      use-theme.ts          # Theme hook
      use-media-query.ts    # Responsive hook
    utils/
      oklch.ts              # OKLCH utility functions
      contrast.ts           # APCA contrast checking
      cn.ts                 # Class merging utility (clsx + tailwind-merge)
    index.ts                # Public API barrel export
  __tests__/
    tokens.test.ts          # Token snapshot tests
    a11y.test.ts            # Accessibility test suite
    theme.test.ts           # Theme switching tests

{For single-repo — src/design-system:}

src/design-system/
  (same internal structure as above)
```

### 4.2.1 package.json Template

```json
{
  "name": "{designSystemPackage}",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.ts",
    "./styles": "./src/styles/index.css"
  },
  "scripts": {
    "build": "tsc -p tsconfig.build.json",
    "typecheck": "tsc -p tsconfig.build.json --noEmit",
    "test": "vitest run",
    "test:watch": "vitest"
  },
  "peerDependencies": {
    "react": ">=18",
    "react-dom": ">=18"
  },
  "sideEffects": ["*.css"],
  "devDependencies": {}
}
```

Notes:
- `"type": "module"` enables ESM throughout
- `exports` maps the package entry to source files (consumers import directly from source in a monorepo)
- `"build": "tsc -p tsconfig.build.json"` uses a separate build tsconfig to exclude tests/stories
- `"sideEffects": ["*.css"]` tells bundlers not to tree-shake CSS imports
- Add actual devDependencies when installing in Phase 5/6/7

### 4.2.2 TypeScript Configuration (Split Strategy)

Use **two tsconfig files** — one for IDE/typecheck, one for production build:

**`tsconfig.json`** (IDE + typecheck — includes everything):
```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "jsx": "react-jsx",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "noEmit": true,
    "types": ["vitest/globals"]
  },
  "include": ["src/**/*.ts", "src/**/*.tsx"]
}
```

**`tsconfig.build.json`** (production build — excludes tests/stories):
```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "declaration": true,
    "noEmit": false,
    "types": []
  },
  "exclude": [
    "src/**/*.stories.ts",
    "src/**/*.stories.tsx",
    "src/**/*.test.ts",
    "src/**/*.test.tsx",
    "src/test-setup.ts"
  ]
}
```

**Why split?**
- `tsconfig.json` includes stories (`.stories.tsx`) and tests (`.test.tsx`) so the IDE shows proper types for `@storybook/react` and `vitest` globals
- `tsconfig.build.json` excludes stories/tests and emits `.d.ts` declaration files for the published package
- `vitest/globals` types in `tsconfig.json` provide `describe`, `it`, `expect` etc. without needing explicit imports
- `"types": []` in `tsconfig.build.json` prevents vitest globals from leaking into production type declarations

## 4.3 Token Build Pipeline

```typescript
// build.ts — Generates CSS custom properties from token definitions

// Input: TypeScript token definitions with OKLCH values
// Output: CSS files with custom properties per theme

// Pipeline:
// 1. Read token source files (primitive -> semantic -> component)
// 2. Resolve token references ({color.blue.500} -> actual value)
// 3. Generate CSS custom properties
// 4. Output light.css and dark.css theme files
// 5. Generate TypeScript type definitions for type-safe usage
// 6. Run deterministic build verification (snapshot test)
```

**If Tailwind v4 detected**, additionally generate a Tailwind theme integration:

```css
/* tokens.css — Tailwind v4 @theme integration */
@import "tailwindcss";

/* Step 1: Register primitive values in @theme for utility class generation */
@theme {
  /* Primitive color palette → generates bg-primary-50, text-primary-500, etc. */
  --color-primary-50:  oklch(0.95 0.02 250);
  --color-primary-100: oklch(0.90 0.04 250);
  --color-primary-500: oklch(0.55 0.20 250);
  --color-primary-900: oklch(0.22 0.11 250);

  /* Spacing from token scale → generates p-1, m-2, gap-4, etc. */
  --spacing-0: 0px;
  --spacing-1: 4px;
  --spacing-2: 8px;
  --spacing-3: 12px;
  --spacing-4: 16px;
  --spacing-6: 24px;
  --spacing-8: 32px;

  /* Radius → generates rounded-sm, rounded-md, etc. */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-full: 9999px;
}

/* Step 2: Define semantic aliases in @layer tokens (NOT in @theme) */
/* These use var() references and are consumed by components directly. */
/* They do NOT generate utility classes — that is intentional. */
/* Declare layer order so the browser knows tokens cascade before components. */
@layer base, tokens, components, utilities;

@layer tokens {
  [data-theme="light"] {
    --surface-default:   var(--color-primary-50);
    --text-on-surface:   var(--color-primary-900);
    --interactive-primary: var(--color-primary-500);
  }

  [data-theme="dark"] {
    --surface-default:   var(--color-primary-900);
    --text-on-surface:   var(--color-primary-50);
    --interactive-primary: var(--color-primary-100);
  }
}

/* Components consume semantic tokens (var(--surface-default)), not primitive ones. */
/* Tailwind utilities use primitive tokens (bg-primary-500). */
/* This separation keeps a single source of truth while supporting both paradigms. */
```

This auto-generates Tailwind utility classes (e.g., `bg-primary-500`, `p-4`, `rounded-md`)
from your design tokens, maintaining a single source of truth.

**Alternative: Style Dictionary 4.x**

For projects requiring multi-platform token output (CSS + iOS Swift + Android Kotlin + React Native JS),
consider Style Dictionary 4.x as an alternative to the custom `build.ts` approach:

```js
// style-dictionary.config.js
import StyleDictionary from 'style-dictionary';

const sd = new StyleDictionary({
  source: ['src/tokens/**/*.json'],  // DTCG-format token files
  platforms: {
    css: {
      transformGroup: 'css',
      prefix: 'ds',  // generates --ds-color-* names; remove if your codebase uses --color-* (no prefix)
      buildPath: 'src/themes/',
      files: [
        { destination: 'light.css', format: 'css/variables', filter: token => token.$type === 'color' },
        { destination: 'dark.css',  format: 'css/variables', filter: token => token.$extensions?.mode === 'dark' },
      ],
    },
    ts: {
      transformGroup: 'js',
      buildPath: 'src/tokens/dist/',
      files: [{ destination: 'tokens.ts', format: 'javascript/esm' }],  // 'javascript/es6' was removed in SD 4.x
    },
    // ios: { ... }, android: { ... }  — add when targeting native platforms
  },
});

await sd.buildAllPlatforms();
```

**When to choose Style Dictionary vs custom build.ts:**

| Scenario | Recommendation |
|----------|---------------|
| Web-only output (CSS + TS) | Custom `build.ts` — simpler, fewer dependencies |
| Multi-platform (CSS + iOS + Android) | Style Dictionary — built-in transforms, active ecosystem |
| Design Token Community Group (DTCG) format already in use | Style Dictionary 4.x — native DTCG support |
| Team already uses Style Dictionary | Style Dictionary — avoid introducing a second build pipeline |

Style Dictionary 4.x natively supports the DTCG `$value`/`$type` format used in this design system.

## 4.4 CSS Layer Strategy

Use CSS cascade layers to control specificity and prevent style conflicts:

```css
/* Entry point: styles.css */
@layer base, tokens, components, utilities;

@layer base {
  /* CSS reset, font-face declarations, root element styles */
  *,
  *::before,
  *::after {
    box-sizing: border-box;
    margin: 0;
  }
}

@layer tokens {
  /* All CSS custom properties from the token build pipeline */
  /* Theme definitions (light.css, dark.css) live here */
  [data-theme="light"] { /* ... token values ... */ }
  [data-theme="dark"]  { /* ... token values ... */ }
}

@layer components {
  /* All component styles consume tokens from the layer above */
  /* Lower specificity than utilities — Tailwind classes always win */
  .button { /* ... */ }
  .input  { /* ... */ }
}

@layer utilities {
  /* Tailwind utilities (auto-injected) or custom utility classes */
  /* Highest specificity in the design system */
}
```

This prevents:
- Component styles accidentally overriding token definitions
- Utility classes losing to component specificity
- Third-party CSS interfering with the design system

**→ Continue in `phases/phase-4b-theming.md`** — Theme System (4b.1), Theme Provider (4b.2), Scoped Theming (4b.3), Dark Mode Checklist (4b.4), and Styling Approach Decision (4b.5).

**Status: DONE** — Architecture design complete. Token hierarchy, directory structure, build pipeline, and CSS layer strategy defined. Proceed to Phase 4b: Theme & Styling (phase-4b-theming.md).
