# Phase 10: App Integration

Read `DESIGN.md` to verify integration aligns with the approved design architecture and token system. All CSS import paths, ThemeProvider configuration, and token references must match the DESIGN.md source of truth.

**Config Validation:** Run the **Config Validation Protocol** (see `operational-notes.md`) before proceeding. Verify that `systemPath`, `framework`, and `themeStrategy` are present in `{systemPath}/.design-farmer/config.json`. If `themeStrategy` is not `'light-only'`, also verify that `themeLibrary` is present. If any required field is missing, emit **Status: BLOCKED** with recovery instructions: re-run the affected phase or manually correct the config.

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

If user chose C (skip integration), emit:

**Status: DONE** — User chose to integrate manually. Skipping integration steps. Proceed to Phase 11: Release Readiness & Handoff.

Set `integrationStatus: "skipped"` in `{systemPath}/.design-farmer/config.json`. Update `config.backup.json`.
Do NOT append `'phase-10'` to `completedPhases` — the phase was skipped by user choice, consistent with Phase 7 (Storybook) skip behavior.

Then stop — do NOT execute steps 10.1 through 10.7. No code changes were made, so the Fix Loop (step 10.7) is not required. The user is responsible for verifying the design system builds in their application context.

---

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

**Clarification question template:**
> Before executing Step {N}, I need to confirm the following:
>
> - `frameworkBranch`: {detected or "unknown"}
> - `targetFiles`: {detected or "unknown"}
> - `themeLibrary`: {from config or "unknown"}
> - `cssEntryTarget`: {detected or "none"}
>
> Please provide the missing value(s) so I can show you the correct diff preview.

## 10.1 Dependency Installation

**Light-only guard:** If `themeStrategy` is `'light-only'` (from config.json), skip ThemeProvider installation in steps 10.1–10.2. CSS token imports (step 10.3) still apply. Jump to step 10.3 after installing design system peer dependencies.

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
  # Check latest version before installing
  npm view {themeLibrary} version
  node -e "require.resolve('{themeLibrary}')" 2>/dev/null || {packageManager} add {themeLibrary}
  # Verify installed version
  node -e "console.log(require('{themeLibrary}/package.json').version)" 2>/dev/null || true
fi
```

## 10.2 Root Layout Integration

**Light-only guard:** If `themeStrategy` is `'light-only'`, skip ThemeProvider wrapping. Only add the CSS import (step 10.3) to the root layout. Do NOT add `suppressHydrationWarning` or any theme provider — light-only mode has no theme switching.

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

**Light-only guard:** If `themeStrategy` is `'light-only'`, skip importing `dark.css` — only import the light theme CSS file and token definitions.

Then import them in the correct order. Common output patterns:

```
// Pattern A — tokens/css/ directory (Style Dictionary output):
import '{systemPath}/tokens/css/tokens.css'
import '{systemPath}/tokens/css/light.css'
{if themeStrategy ≠ 'light-only':}
import '{systemPath}/tokens/css/dark.css'
{/if}

// Pattern B — src/themes/ directory (custom build):
import '{systemPath}/src/themes/tokens.css'
import '{systemPath}/src/themes/light.css'
{if themeStrategy ≠ 'light-only':}
import '{systemPath}/src/themes/dark.css'
{/if}

// Pattern C — Tailwind v4 @theme (tokens registered via @import "tailwindcss"):
// Import the design system's Tailwind entry CSS which contains @import "tailwindcss"
// and @source directives for monorepo setups.
// See "Tailwind v4 @source for Monorepo Consumers" subsection below.

import '{systemPath}/src/styles/index.css'
```

### Tailwind v4 `@source` for Monorepo Consumers

When the design system uses Tailwind v4 (`@import "tailwindcss"` in its CSS entry) and
the consuming app lives in a separate monorepo package (e.g., `apps/web/`, `apps/docs/`),
Tailwind's automatic source file detection may not scan the design system's component
source files. This causes utility classes used in design system components to not be
generated, resulting in missing styles in the consuming app.

**Root cause:** Tailwind v4 detects source files based on the CSS file's location and the
current working directory (CWD). When the design system's CSS is imported across package
boundaries, Tailwind may not reach the component source files in
`packages/{designSystemDir}/src/`.

**Where to add `@source`:** The `@source` directive must be in the **same physical file** as
`@import "tailwindcss"` — NOT in the consuming app's CSS entry, JS entry point, or layout
file. `@source` directives do not cascade across `@import` boundaries: importing a CSS
file that already contains both `@import "tailwindcss"` and `@source` works, but adding
`@source` in the importing file does not. This rule is documented consistently in
Phase 4 (Architecture), Phase 7 (Storybook), and this phase.

**Fix — add `@source` directives in the design system's Tailwind CSS entry:**

```css
/* packages/{designSystemDir}/src/styles/index.css */

/* Option A: Keep auto-detection, set base path relative to this CSS file */
/* From src/styles/, ".." resolves to src/ — the component source root */
@import "tailwindcss" source("..");

/* Option B: Disable auto-detection, register paths explicitly */
@import "tailwindcss" source(none);
@source "..";
@source "../../other-package/src";
```

**Framework-specific consumer setup:**

For each framework below, the consuming app only needs to import the design system's CSS
file — the `@source` directives inside that file handle source detection. The consuming
app does NOT need its own `@import "tailwindcss"` unless it also uses Tailwind utilities
directly in app code.

| Framework | App CSS Entry | Notes |
|-----------|--------------|-------|
| Next.js App Router | `app/globals.css` → `import '@{scope}/design-system/src/styles/index.css'` | No additional `@source` needed in app CSS |
| Next.js Pages Router | `styles/globals.css` → `import '@{scope}/design-system/src/styles/index.css'` | Same as App Router |
| Vite + React | `src/index.css` → `import '@{scope}/design-system/src/styles/index.css'` | No Vite plugin changes needed — `@source` is CSS-level |
| Remix | `app/root.tsx` → import in stylesheet linkage | No additional config |
| Astro | Main layout stylesheet → `import '@{scope}/design-system/src/styles/index.css'` | No additional config |
| SvelteKit | `src/routes/+layout.svelte` → style import | No additional config |
| Nuxt | `nuxt.config.ts` `css` array or layout import | No additional config |
| Plain React (Vite or CRA) | `src/index.css` → `import '@{scope}/design-system/src/styles/index.css'` | No additional config (Vite recommended; CRA is deprecated) |

**When `@source` is needed vs. not needed:**

| Scenario | `@source` Required? | Why |
|----------|-------------------|-----|
| Design system and app are in the same package (single repo) | No | Tailwind's default auto-detection covers the package |
| Design system at `packages/ds/`, app at `apps/web/`, same monorepo | Yes (in design system CSS) | CSS file location differs from component source — add `@source` in design system CSS. All consuming apps inherit the directives via workspace import |
| Multiple apps (Next.js, Remix, Nuxt) consume one design system | No (per app) | Add `@source` once in the design system's CSS — all consuming apps inherit it |
| Design system published to npm, consumed as external dependency | Design system author must handle | Published packages should include `@source` in their distributed CSS. Consumers cannot reliably add `@source` for external dependencies because source paths vary by build tool and installation layout |
| App also uses Tailwind utilities directly in its own components | Yes (in app CSS) | If the app has its own `@import "tailwindcss"`, add `@source` in the app's CSS pointing to `node_modules/{pkg}/src/` so the app's Tailwind instance scans design system classes too. Prefer letting the design system own Tailwind when possible |

**Common mistake:** Adding `@source` in the consuming app's CSS file or JS entry instead of
the design system's CSS file. The `@source` directive must be in the same file as
`@import "tailwindcss"`.

**Verification:** After integrating, start the dev server and confirm that utility classes
used in design system components (e.g., `bg-primary-500`, `p-4`, `rounded-md`) are applied
in the consuming app. If styles are missing, verify the `@source` path is correct relative
to the CSS file containing `@import "tailwindcss"`, not relative to the app's project root.

**Cross-references:**
- Phase 4 (Architecture) section 4.3 — `@source` in the token build pipeline
- Phase 7 (Storybook) Step 2.5 — Storybook-specific `@source` guidance and decision matrix

Verify the import ORDER is correct:
1. Reset / base styles (if any)
2. Token definitions (primitives -> semantics)
3. Theme files (light.css, dark.css if not light-only)
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
- Layout/root entry: {actual framework file path — {if themeStrategy='light-only': "added CSS token imports (no ThemeProvider — light-only mode)" else: "added ThemeProvider + hydration-safe theming setup"}}
- CSS imports: {list of added imports with order}
- Dependencies: {list of added/updated packages}
- Token replacements: {count} hardcoded values -> design tokens (if applicable)

### Verified
- [ ] App starts without errors
- [ ] TypeScript compilation passes
- [ ] Lint passes with zero suppressions
- [ ] {if themeStrategy='light-only': "Light theme tokens applied correctly" else: "Theme toggle works"}
- [ ] Design tokens are visible in rendered output
```

## 10.7 Fix Loop Checkpoint

Integration is the highest-risk phase for lint/build/type errors because the design system meets the application's existing code.

Run the **Fix Loop Protocol** (see `operational-notes.md`):

```
Checks: typecheck, lint, build
Max attempts: 5
```

Common integration errors and their root causes:

| Error Pattern | Root Cause | Fix |
|--------------|-----------|-----|
| `Cannot find module '@scope/design-system'` | Package not linked in monorepo | `{packageManager} install` or add workspace dependency |
| `Module has no exported member 'Button'` | Missing barrel export | Add export to `src/index.ts` |
| `Type 'string' is not assignable to 'ButtonVariant'` | Consumer passes untyped string | Import and use the variant type from the design system |
| `Could not resolve './styles/index.css'` | CSS entry point not in `exports` field | Add `"./styles"` to package.json exports map |
| `Duplicate identifier 'React'` | Conflicting React type versions | Align `@types/react` version across workspace |

Do NOT emit DONE until the Fix Loop passes on all three checks.

After the Fix Loop passes, set `integrationStatus: "completed"` in `{systemPath}/.design-farmer/config.json`. Update `config.backup.json`.

Before emitting status, append `'phase-10'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Ensure `completedPhases` exists in config.json (initialize as `[]` if undefined), then append `'phase-10'`. If `'phase-10'` is already present, skip the append (idempotent). Also update `config.backup.json`.

**Status: DONE** (Fix Loop: passed on attempt {N}/5) — Design system integrated into application. Theme toggle working, tokens visible in rendered output. Proceed to Phase 11: Release Readiness & Handoff.
