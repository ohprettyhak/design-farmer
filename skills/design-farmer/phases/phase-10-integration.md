# Phase 10: App Integration

Via AskUserQuestion, ask:

> Your design system is built, tested, and documented. The final step is wiring it
> into your application so it's actually used.
>
> **Would you like me to integrate the design system into your app?**
>
> RECOMMENDATION: Choose A — automatic integration ensures correct import order,
> ThemeProvider placement, and token availability throughout your app.
>
> Options:
> - A) Yes, full integration — Update layout, imports, and dependencies automatically
> - B) Yes, guided — Show me exactly what to change (diff preview) and I'll approve each step
> - C) No, skip — I'll integrate manually using the documentation

**STOP. Do NOT proceed until user responds.**

If user chose A or B, execute the following steps.

**Mode behavior:**
- **Mode A (full):** Execute each step automatically. Only stop on errors.
- **Mode B (guided):** Before executing EACH step (10.1 through 10.5), show the user
  a diff preview of what will change and wait for explicit approval via AskUserQuestion:
  > Step {N}: {description}. Here's what will change:
  > ```diff
  > {preview of changes}
  > ```
  > Approve this change? (yes / no / skip)
  Only proceed after the user approves. If "no", ask what to adjust. If "skip", move
  to the next step.

**Mode B approval payload (MANDATORY before each step):**

Before asking "Approve this change?", include ALL of the following in the preview:
- `frameworkBranch`: detected framework branch (e.g., next-app-router, remix, nuxt)
- `targetFiles`: exact file paths that will be edited in this step
- `themeLibrary`: selected library from Question 5-1 (or `custom` / `none`)
- `cssEntryTarget`: the exact app entry CSS file (or `none` if not needed)
- `executionMode`: `guided`

If any field is unknown, STOP and ask a clarification question first. Do NOT execute
the step with inferred or omitted payload fields.

## 10.1 Dependency Installation

Compatibility gate (MANDATORY):

- Next.js -> `next-themes` or `custom`
- Astro -> `astro-color-scheme` or `custom`
- Remix -> `remix-themes` or `custom`
- SvelteKit -> `mode-watcher` or `custom`
- Nuxt -> `@nuxtjs/color-mode` or `custom`
- Plain React (Vite/CRA) -> `custom` or `use-dark-mode`

If `{themeLibrary}` does NOT match the detected framework's allowed set,
STOP and ask the user via AskUserQuestion:

> The selected theme library (`{themeLibrary}`) does not match the detected framework (`{framework}`).
> To avoid a broken integration, choose one:
> - A) Use framework-compatible library: {recommendedLibrary}
> - B) Use custom implementation
> - C) Keep current choice and skip automatic integration

Do NOT proceed until user responds.

```bash
# Install the design system's peer dependencies
# Detect package manager from lockfile (package-lock.json / pnpm-lock.yaml / bun.lockb / yarn.lock)
{packageManager} install

# If a theme library was chosen in Question 5-1, verify THAT exact package.
# Do not hardcode next-themes; use the user's selected library.
# Skip install when user chose a custom/no-library path.
if [ "{themeLibrary}" != "" ] && [ "{themeLibrary}" != "custom" ] && [ "{themeLibrary}" != "none" ]; then
  node -e "require.resolve('{themeLibrary}')" 2>/dev/null || {packageManager} add {themeLibrary}
fi
```

## 10.2 Root Layout Integration

Apply root integration based on the detected framework from Phase 0.
Do NOT assume Next.js App Router. Use ONLY the path that exists for the detected stack.

Framework decision matrix (MANDATORY):

| Framework Branch | Primary File(s) to Edit | Provider Insertion Point | CSS Entry Target | NEVER do this |
|---|---|---|---|---|
| Next.js App Router | `app/layout.tsx` | Inside `<body>`, wrap `{children}` | `app/layout.tsx` import block or app global CSS | Do NOT edit `pages/_app.tsx` in this branch |
| Next.js Pages Router | `pages/_app.tsx` (+ `pages/_document.tsx` only if needed) | Wrap `<Component {...pageProps} />` in `_app` | `pages/_app.tsx` import block or global CSS | Do NOT instruct edits to `app/layout.tsx` |
| Remix | `app/root.tsx` | Wrap `<Outlet />` tree in root component | `app/root.tsx`/root stylesheet linkage | Do NOT reference Next/Nuxt file paths |
| Astro | Main `.astro` layout/template (`src/layouts/*.astro` or project root layout) | Layout shell where slotted page content is rendered | Main Astro stylesheet entry | Do NOT instruct React-only provider wrappers |
| SvelteKit | `src/routes/+layout.svelte` | Root layout markup around `<slot />` | Root style import used by `+layout.svelte` | Do NOT reference React JSX wrappers |
| Nuxt | `app.vue` or `layouts/default.vue` | Root template wrapper around `<NuxtPage />` | Nuxt global CSS entry (config/layout import) | Do NOT reference Next/Remix paths |
| Plain React (Vite/CRA) | `src/main.tsx` / `src/main.jsx` or `src/index.tsx` / `src/index.jsx` | Root `createRoot(...).render(...)` tree | Root CSS import in main entry | Do NOT claim `app/layout.tsx` exists |

For the detected framework's root file:

```typescript
// 1. Add suppressHydrationWarning to <html>
// 2. Import and wrap with ThemeProvider
// 3. Import the design system's global CSS

// The agent MUST:
// - Read the existing detected root file first
// - Preserve ALL existing content (metadata, fonts, providers, analytics, etc.)
// - Add the ThemeProvider as the INNERMOST provider wrapping {children}
//   (do NOT remove or reorder existing providers)
// - Add the CSS import at the TOP of the import block
// - Add suppressHydrationWarning to <html> only when that tag is present in the edited file
```

If the framework does NOT render a literal `<html>` element in app code,
skip the `suppressHydrationWarning` step and apply the equivalent SSR-safe
theme bootstrap mechanism for that framework.

**CRITICAL: Never overwrite the user's existing layout. Read it first, then surgically
add only the necessary imports and wrapper. Preserve everything else exactly as-is.**

## 10.3 CSS Import Chain

Wire the design system's CSS into the application's import chain.

**IMPORTANT: Do NOT assume fixed file paths. The actual CSS output paths depend on the
token build pipeline configured in Phase 4.3. Scan the generated `{systemPath}` directory
to discover the actual file locations:**

```bash
# Discover generated CSS files — paths vary by project configuration
find {systemPath} -name '*.css' -type f | sort
```

Then import them in the correct order. Common output patterns:

```
// Pattern A — tokens/css/ directory (Style Dictionary output):
import '{systemPath}/tokens/css/tokens.css'
import '{systemPath}/tokens/css/light.css'
import '{systemPath}/tokens/css/dark.css'

// Pattern B — src/themes/ directory (custom build):
import '{systemPath}/src/themes/tokens.css'
import '{systemPath}/src/themes/light.css'
import '{systemPath}/src/themes/dark.css'

// Pattern C — Tailwind v4 @theme (no separate CSS files):
// Tokens are injected via @theme in the Tailwind config — no manual CSS import needed

// Component styles (if not using CSS modules):
import '{systemPath}/components/styles.css'  // or wherever component CSS was generated
```

Verify the import ORDER is correct:
1. Reset / base styles (if any)
2. Token definitions (primitives -> semantics)
3. Theme files (light.css, dark.css)
4. Component styles
5. Application-specific overrides (existing app CSS)

## 10.4 Replace Hardcoded Values (optional, if user chose A)

Scan the user's existing codebase for hardcoded values that should use design tokens:

```
Scan the application source files (NOT the design system directory) for hardcoded
values that should be replaced with design system tokens:

1. Color values: hex (#xxx), rgb(), hsl(), oklch() -> var(--surface-*), var(--text-*), etc.
2. Spacing values: arbitrary px/rem values -> var(--spacing-*) or spacing scale classes
3. Font sizes: hardcoded px/rem -> var(--font-size-*) or typography scale
4. Border radius: hardcoded values -> var(--radius-*)

For each found instance:
- Show the file, line number, and current value
- Suggest the matching design token
- Only replace if the mapping is unambiguous

DO NOT replace values inside:
- Third-party library code (node_modules)
- Generated files
- The design system directory itself
- SVG path data or image references
```

## 10.5 Integration Verification

```bash
# 1. Type check — ensure no type errors from new imports
{packageManager} run typecheck  # or npx tsc --noEmit

# 2. Lint — ensure no lint errors (NEVER suppress with biome-ignore or eslint-disable)
{packageManager} run lint

# 3. Dev server — verify the app starts without errors
{packageManager} run dev &
# Wait for ready, then verify no console errors

# 4. Visual check — verify tokens are applied
# - Background colors use design system surfaces
# - Text uses design system text tokens
# - Theme toggle works (if dark mode enabled)
```

## 10.6 Integration Completion Report

```
## App Integration Summary

### Changes Made
- Layout/root entry: {actual framework file path — added ThemeProvider + hydration-safe theming setup}
- CSS imports: {list of added imports with order}
- Dependencies: {list of added/updated packages}
- Token replacements: {count} hardcoded values -> design tokens (if applicable)

### Verified
- [ ] App starts without errors
- [ ] TypeScript compilation passes
- [ ] Lint passes with zero suppressions
- [ ] Theme toggle works
- [ ] Design tokens are visible in rendered output
```
