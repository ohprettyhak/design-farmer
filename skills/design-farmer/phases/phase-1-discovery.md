# Phase 1: Discovery Interview

**CRITICAL RULE: Ask questions ONE AT A TIME by calling the `AskUserQuestion` tool. Do NOT output questions as text — you MUST invoke the tool so the user gets an interactive prompt. STOP after each tool call and wait for the tool to return the user's response before asking the next question. Do NOT proceed until user responds. Do NOT batch multiple questions. Do NOT skip ahead.**

If the user expresses impatience after 3+ questions, offer to use sensible defaults for remaining questions and proceed.

---

### Re-entry Detection

Before asking Q0, check if `{systemPath}/.design-farmer/config.json` exists. Check two conditions for Phase 3.5 restart detection:
- `resetFromPhase` equals `"3.5"` (set by Phase 3.5 Option E reset logic)
- OR `completedPhases` includes `"phase-3.5"` (normal completion path)

If either is true, this is a restart from Phase 3.5.

Also check if `skippedPhases` exists in config.json — this indicates Phases 1–4 were intentionally bypassed via Phase 0→5 shortcut. If `skippedPhases` is present and includes `"phase-1"`, this is a re-entry from a shortcut path. Log the skipped phases and proceed with the interview (the user chose to re-run Phase 1 after the shortcut).

If `completedPhases` exists but is empty (`[]`), treat this as a partial Phase 0 run that didn't complete. Proceed to Phase 1 as normal (no re-entry shortcuts).

Load the following preserved fields from config.json and present them as pre-filled defaults alongside each question:

| Question | Preserved Field | Default Display |
|----------|----------------|-----------------|
| Q0 | `painPoint` | "Previous answer: {painPoint}" |
| Q1 | `vision` | "Previous answer: {vision}" |
| Q3 | `componentScope` | "Previous answer: {componentScope}" |
| Q3-1 | `headlessLibrary` | "Previous answer: {headlessLibrary}" (skip if componentScope = foundation) |
| Q5 | `themeStrategy` | "Previous answer: {themeStrategy}" |
| Q5-1 | `themeLibrary` | "Previous answer: {themeLibrary}" (skip if themeStrategy = light-only) |
| Q6 | `accessibilityLevel` | "Previous answer: {accessibilityLevel}" |
| Q7 | `targetPlatforms` | "Previous answer: {targetPlatforms}" |

Q2 (Brand & Color Direction) is NOT pre-filled — `brandColor` and `colorDirection` were cleared during the Phase 3.5 reset.
Q4 (Design System Location) uses `designSystemDir` which is preserved — present as default.

For each question, prepend the preserved value above the question text. The user can accept the default (choose the matching option or confirm) or provide a new answer.

---

### Question 0: Motivation & Pain Points

Via AskUserQuestion, ask:

> Before we start building, I want to understand what's driving this effort.
>
> **What is the biggest pain point this design system should solve?**
>
> Options:
> - A) Visual inconsistency — components look different across pages or teams
> - B) Accessibility failures — failing audits or user-reported issues
> - C) Developer experience — too much time spent on UI, slow onboarding
> - D) Designer-developer handoff — Figma decisions don't translate to code
> - E) Something else — describe in your own words
>
> Your answer shapes every recommendation that follows: accessibility pain → WCAG 2.x AA
> prioritized; handoff pain → Figma integration highlighted; DX pain → token-first approach.

**→ STOP — wait for user response before continuing.**

---

### Question 1: Project Vision

Via AskUserQuestion, ask:

> I've scanned your project. Here's what I found:
> - Repository type: {monorepo|single-repo}
> - Framework: {React|Vue|Svelte|Next.js|...}
> - Package manager: {bun|pnpm|npm|yarn}
> - TypeScript: {yes|no}
> - Existing UI components: {count} found in {paths}
>
> Before building your design system, I need to understand your vision.
>
> **What is the primary purpose of this design system?**
>
> RECOMMENDATION: Choose A for single-repo projects, B for monorepos with multiple apps.
>
> Options:
> - A) Internal product consistency — unify UI across one product
> - B) Multi-product system — shared library across multiple apps/teams
> - C) Open-source component library — public distribution
> - D) Design-to-code bridge — sync Figma tokens to code
>
> Each option shapes token naming, package boundaries, and versioning strategy.

**→ STOP — wait for user response before continuing.**

---

### Question 2: Brand & Color Direction

Via AskUserQuestion, ask:

> Now let's establish your visual identity foundation.
>
> I found these existing colors in your codebase:
> {extracted colors converted to OKLCH with their current usage context}
>
> **What is your brand's color direction?**
>
> RECOMMENDATION: Choose A if your existing colors are intentional. Choose B if you have a brand hex/rgb to start from.
>
> Options:
> - A) Keep existing palette — I'll convert everything to OKLCH and fill gaps
> - B) Fresh palette from brand color — provide one primary brand color, I'll generate the full system
> - C) Neutral-first — start with a grayscale system, add brand colors later
> - D) Custom palette — provide specific colors you want to use
>
> I'll use OKLCH for perceptual uniformity and generate an 11-step scale (50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950) with proper contrast ratios.

**→ STOP — wait for user response before continuing.**

---

### Question 3: Component Scope

Via AskUserQuestion, ask:

> Let's define the initial component boundary.
>
> Based on the Phase 0 pre-flight scan, here is a **preliminary maturity estimate**
> (Phase 2 will produce the formal score — use this as a directional guide only):
>
> - **Likely GREENFIELD**: no design token files, no `design-system/` or `primitives/` directory,
>   colors and spacing are hardcoded throughout the codebase
> - **Likely EMERGING**: some CSS custom properties or theme config found, partial component
>   library (5–15 components), inconsistent naming patterns
> - **Likely MATURE**: structured token system already in place, component library with consistent
>   API patterns, existing theme switching mechanism
>
> Based on your codebase analysis, these components appear most frequently:
> {top 5-10 component patterns found in the repo with usage counts}
>
> **Which component tier should I implement first?**
>
> RECOMMENDATION based on your preliminary maturity estimate:
> - GREENFIELD → **A (Foundation only)**: Start small, validate the token system, then expand.
>   Building 6+ interactive components before the token system is proven adds unnecessary risk.
> - EMERGING → **B (Core interactive)**: You have partial patterns — standardizing core components
>   gives the highest return on investment. Covers 80% of common UI needs.
> - MATURE → **C or D**: Your existing system is proven. Expand to the full starter kit
>   or select specific components that fill your current gaps.
> Completeness: A=4/10, B=7/10, C=9/10, D=varies
> **Scope & time:** Foundation (A) → fastest MVP (days); Core (B) → 1-2 weeks;
> Full starter kit (C) → 3-4 weeks; Custom (D) → varies. Choose based on your timeline
> as well as your maturity level.
>
> Options:
> - A) Foundation only — Tokens + Typography + Color + Spacing + Layout primitives
> - B) Core interactive — Foundation + Button, Input, Checkbox, Radio, Select, Dialog
> - C) Full starter kit — Core + Card, Toast, Tabs, Menu, Popover, Tooltip
> - D) Custom selection — Tell me which components you need
>
> Each component gets full accessibility (WCAG AA), keyboard navigation, and theme support.

**→ STOP — wait for user response before continuing.**

---

### Question 3-1: Headless Component Library (conditional)

**Only ask this if the user chose B (Core interactive), C (Full starter kit), or D (Custom) in Question 3. Skip if user chose A (Foundation only — no interactive components needed).**

Via AskUserQuestion, ask:

> Interactive components (Button, Dialog, Select, etc.) need complex behavior:
> keyboard navigation, focus trapping, ARIA state management, and screen reader
> announcements. A headless component library handles this behavior so you can
> focus on styling and design tokens.
>
> **Should we use a headless component library as the foundation?**
>
> {If React detected:}
> RECOMMENDATION: Choose A or B — both are production-proven. Radix has more opinionated
> defaults (faster start), Base UI is more flexible (lower-level primitives).
>
> Options:
> - A) Radix UI — Rich primitives with built-in accessibility, widely adopted (~12M weekly downloads)
> - B) Base UI (by MUI) — Unstyled primitives, maximum styling flexibility, used by Cloudflare Kumo
> - C) Ark UI — Framework-agnostic headless components (supports React, Vue, Solid)
> - D) No library — Build custom primitives from scratch (more control, more effort)
>
> {If Vue detected:}
> RECOMMENDATION: Choose A — Radix Vue is the most mature option for Vue.
>
> Options:
> - A) Radix Vue — Port of Radix UI for Vue, strong accessibility
> - B) Headless UI — By Tailwind Labs, designed for Tailwind integration
> - C) Ark UI — Framework-agnostic, supports Vue natively
> - D) No library — Build custom primitives from scratch
>
> {If Svelte detected:}
> RECOMMENDATION: Choose A — Melt UI is purpose-built for Svelte.
>
> Options:
> - A) Melt UI — Headless components designed for Svelte
> - B) Bits UI — Svelte port of Radix, styled with Tailwind
> - C) No library — Build custom primitives from scratch
>
> {If other framework:}
> Options:
> - A) Ark UI — Framework-agnostic headless components
> - B) No library — Build custom primitives from scratch
>
> Using a headless library saves weeks of accessibility engineering. The library handles
> keyboard navigation, ARIA, and focus management. You provide the visual layer using
> your design tokens and styling approach.
>
> (Note: Some headless libraries are framework-specific. If you selected a non-React headless library (e.g., Melt UI for Svelte, Radix Vue), Phase 6 will prompt you to choose a React-compatible replacement.)

**→ STOP — wait for user response before continuing.**

---

### Question 4: Design System Location

Via AskUserQuestion, ask:

> **Where should the design system live in your project?**
>
> {If monorepo detected:}
> RECOMMENDATION: Choose A — dedicated package enables independent versioning and future extraction.
>
> Options:
> - A) packages/design-system — dedicated package
> - B) packages/ui — shorter path, common convention
> - C) Custom path — specify your preferred location
>
> {If single-repo detected:}
> RECOMMENDATION: Choose A — dedicated directory keeps the system independent.
>
> Options:
> - A) src/design-system — dedicated directory
> - B) src/components/system — nested under components
> - C) Custom path — specify your preferred location
>
> Token files, component source, and tests all live here with their own build configuration.

**→ STOP — wait for user response before continuing.**

---

### Question 5: Theme Strategy

Via AskUserQuestion, ask:

> **How should theming work?**
>
> RECOMMENDATION: Choose A — light + dark covers the majority of use cases. Dark mode derived by inverting the OKLCH lightness scale while preserving hue and chroma.
> Completeness: A=8/10, B=5/10, C=10/10, D=varies
>
> Options:
> - A) Light + Dark — two themes with system preference detection
> - B) Light only — single theme, simpler setup
> - C) Multi-brand — multiple brand themes with light/dark each
> - D) Custom themes — specify your theme requirements
>
> Implementation: CSS custom properties with `data-theme` attribute switching. All colors stored as OKLCH values.

**→ STOP — wait for user response before continuing.**

---

### Question 5-1: Dark Mode Library (conditional)

**Only ask this if the user chose A (Light + Dark), C (Multi-brand), or D (Custom themes) in Question 5 and the user's custom requirements include dark mode. Skip if user chose B (Light only) or if D was chosen without dark mode.**

Detect the user's framework from Phase 0 pre-flight, then recommend the most popular
and battle-tested theme library for that framework.

Via AskUserQuestion, ask:

> You chose dark mode support. For reliable theme switching (SSR flash prevention,
> system preference sync, localStorage persistence), a dedicated library handles
> the edge cases better than a custom implementation.
>
> {If Next.js detected:}
> RECOMMENDATION: Choose A — next-themes is the de facto standard for Next.js with 5M+ weekly downloads.
>
> Options:
> - A) next-themes — SSR-safe, App Router compatible, zero-flash, system preference sync
> - B) Custom implementation — manual `data-theme` attribute + matchMedia + localStorage
>
> {If Astro detected:}
> RECOMMENDATION: Choose A — astro-color-scheme handles SSR and view transitions.
>
> Options:
> - A) astro-color-scheme — SSR-safe, view transition compatible
> - B) Custom implementation — inline script + data-theme attribute
>
> {If Remix detected:}
> RECOMMENDATION: Choose A — remix-themes handles SSR cookie-based theming.
>
> Options:
> - A) remix-themes — SSR-safe, cookie-based, session-aware
> - B) Custom implementation — manual cookie + data-theme attribute
>
> {If SvelteKit detected:}
> RECOMMENDATION: Choose A — mode-watcher is the community standard.
>
> Options:
> - A) mode-watcher — SSR-safe, reactive, localStorage sync
> - B) Custom implementation — manual store + matchMedia
>
> {If Nuxt detected:}
> RECOMMENDATION: Choose A — @nuxtjs/color-mode is the official module.
>
> Options:
> - A) @nuxtjs/color-mode — SSR-safe, auto-detection, cookie persistence
> - B) Custom implementation — manual plugin + data-theme attribute
>
> {If plain React (Vite/CRA) detected:}
> RECOMMENDATION: Choose A — for client-only React apps, a custom ThemeProvider
> is straightforward and avoids unnecessary dependencies.
>
> Options:
> - A) Custom ThemeProvider — React Context + matchMedia + localStorage (15 lines)
> - B) use-dark-mode — lightweight hook-based approach
>
> {If none of the above match:}
> Options:
> - A) Framework-recommended library — I'll research the best option for {framework}
> - B) Custom implementation — manual data-theme attribute + matchMedia + localStorage

**→ STOP — wait for user response before continuing.**

---

### Question 6: Accessibility Level

Via AskUserQuestion, ask:

> **What accessibility standard should we target?**
>
> {If Q0 answer was B (Accessibility failures): RECOMMENDATION: Choose A — WCAG 2.2 AA is the
> legally enforceable standard and directly addresses the audit failures you described. Add APCA
> on top once the baseline is met.}
> {Otherwise:} RECOMMENDATION: Choose C — APCA pairs naturally with OKLCH's perceptual uniformity
> and provides more accurate contrast evaluation than traditional WCAG 2.x ratios.
>
> Options:
> - A) WCAG 2.2 AA — industry standard, legally required in many jurisdictions
> - B) WCAG 2.2 AAA — highest conformance, stricter contrast and interaction requirements
> - C) AA with APCA — modern contrast algorithm, better perceptual accuracy with OKLCH
>   ⚠️ **Legal note:** APCA is part of the WCAG 3.0 Working Draft, not yet a W3C Recommendation.
>   Legal accessibility requirements (ADA, EN 301 549) mandate WCAG 2.x AA — passing APCA Lc 60
>   does **not** guarantee WCAG 2.x 4.5:1 compliance. If legal compliance is required, run
>   WCAG 2.x contrast checks alongside APCA.

**→ STOP — wait for user response before continuing.**

---

### Question 7: Target Platforms

Via AskUserQuestion, ask:

> **Which platforms should the design system support?**
>
> This determines token output formats, component rendering targets, and testing strategies.
>
> RECOMMENDATION: Choose A — start with web. The token pipeline can be extended to emit platform-specific formats (Swift, Kotlin, XML) when the need arises.
> Completeness: A=7/10, B=8/10, C=8/10, D=10/10
>
> Options:
> - A) Web only — CSS custom properties, browser-based components
> - B) Web + React Native — shared tokens with platform-specific component implementations
> - C) Web + Mobile (hybrid) — tokens exported for CSS and native mobile (iOS/Android)
> - D) Multi-platform — full cross-platform support with platform adapters

**→ STOP — wait for user response before continuing.**

---

### After All Questions Answered

Only after receiving ALL 8 responses (Q0 through Q7, plus any applicable conditional questions), store answers in a structured format for subsequent phases:

```typescript
interface DesignFarmerConfig {
  // Q0–Q7 answers
  painPoint?: 'inconsistency' | 'accessibility' | 'dx' | 'handoff' | 'other';
  painPointDetail?: string; // if 'other'
  vision: 'internal' | 'multi-product' | 'open-source' | 'design-bridge';
  colorDirection: 'keep' | 'brand' | 'neutral' | 'custom';
  brandColor?: string; // OKLCH primary
  componentScope: 'foundation' | 'core' | 'full' | 'custom';
  headlessLibrary?: 'radix' | 'base-ui' | 'ark' | 'headless-ui' | 'melt' | 'bits' | 'none';
  customComponents?: string[];
  systemPath: string;
  themeStrategy: 'light-dark' | 'light-only' | 'multi-brand' | 'custom';
  themeLibrary?: string; // e.g., 'next-themes', 'custom', 'mode-watcher', etc.
  accessibilityLevel: 'aa' | 'aaa' | 'apca';
  targetPlatforms: 'web' | 'web-native' | 'web-hybrid' | 'multi-platform';
  // Detected from Phase 0/2 — carried into all subsequent phases
  packageManager: 'bun' | 'pnpm' | 'npm' | 'yarn';
  framework: string; // e.g., 'next-app-router', 'next-pages-router', 'vite-react', 'astro', 'sveltekit', 'nuxt', 'remix'
  isMonorepo: boolean;
  // Derived identifiers (computed from systemPath / package.json in Phase 0/2)
  productName: string;       // e.g., 'Acme UI' — from package.json name or user input
  designSystemDir: string;   // directory name only, e.g., 'design-system' (= basename(systemPath))
  designSystemPackage: string; // npm package name, e.g., '@acme/design-system' (= package.json name)
  // Set from Phase 2 output — propagate to all subsequent phases
  designMaturity?: 'greenfield' | 'emerging' | 'mature';
  maturityScore?: number; // 0–10 from Phase 2 scoring criteria (output-only — displayed in DESIGN.md; branching uses designMaturity string)
  maturityJustification?: string; // Created in Phase 2. Brief justification of maturity score (e.g., '4/10 — has dedicated component dir (✓), tokens (✗)')
  // Phase 4 output — styling approach determination
  stylingApproach?: string; // Determined in Phase 4. One of: 'tailwind-v4', 'tailwind-v3', 'css-modules', 'styled-components', 'vanilla-extract', 'panda-css', 'vanilla'
  // Phase 0 strategy selection — consumed by Phase 4 and Phase 10
  strategy?: 'extend' | 'migrate' | 'greenfield';
  // Pipeline state — managed automatically, not user-facing
  completedPhases?: string[]; // e.g., ["phase-0","phase-1","phase-2"] — tracks which phases have finished
  skippedPhases?: string[]; // e.g., ["phase-1","phase-2"] — phases intentionally skipped (Phase 0→5 shortcut)
  createdAt?: string; // ISO 8601 timestamp of initial config creation
  lastReviewScore?: number; // Phase 8 aggregate review score (0–10)
  lastReviewDate?: string; // ISO 8601 timestamp of last Phase 8 review
  generatePreview?: boolean; // whether to generate HTML preview in Phase 3.5 (consumed by Phase 3.5 to decide preview behavior)
  previewOutcome?: 'generated' | 'skipped' | 'failed'; // Phase 3.5 internal state — distinguishes generation result from intentional skip
  storybookSkipped?: boolean; // true when Phase 6 non-React skip also skips Phase 7 (consumed by Phase 8)
  integrationStatus?: 'skipped' | 'completed'; // Set in Phase 10. Tracks whether app integration was performed or skipped
  visualQASkipped?: boolean; // Phase 8.5 skipped due to no dev server or Storybook
  visualQAMode?: 'auto' | 'manual' | 'skipped'; // Phase 8.5 execution mode
  resetFromPhase?: string; // Phase that triggered a reset (e.g., "3.5" for Phase 3.5 restart → Phase 1 re-entry)
}

// derivation rules:
// designSystemDir = path.basename(systemPath)
// designSystemPackage = the "name" field from {systemPath}/package.json
// systemPackageName (used in some phase files) = designSystemPackage (same thing, use designSystemPackage)
// productName = derived from designSystemPackage (strip @scope/ prefix, title-case)
```

Summarize the user's choices back to them and ask for final confirmation:

Via AskUserQuestion, ask:
> Here's your design system configuration:
> {formatted summary of all 8 choices (Q0 pain point through Q7 platforms),
>  plus Q3-1 headless library choice (if asked) and Q5-1 theme library choice (if asked)}
>
> **Is this correct? Ready to proceed?**
>
> Options:
> - A) Yes, proceed to repository analysis
> - B) I want to change some answers (specify which)

**→ STOP — wait for user response before continuing.**

After user confirms (chose A), persist the config to disk so subsequent phases can load it
even if earlier context has been compressed:

```bash
mkdir -p {systemPath}/.design-farmer
# Write DesignFarmerConfig as JSON to {systemPath}/.design-farmer/config.json
# Also copy to config.backup.json in the same directory
# Set createdAt to the current ISO 8601 timestamp
# Initialize completedPhases as ["phase-0"] if undefined; preserve existing array on re-entry
# Preserve skippedPhases if present (set by Phase 0→5 shortcut)

# Read-after-write validation: Read back config.json to verify the write succeeded.
# If the file is missing or invalid JSON, emit **Status: BLOCKED** with recovery
# instructions: re-run Phase 1 or manually correct the config.
```

Before emitting status, ensure `completedPhases` exists in config.json (initialize as `[]` if undefined), then append `'phase-1'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. If `'phase-1'` is already present in the array, skip the append (idempotent). Also update `config.backup.json`.

**Status: DONE** — Discovery interview complete. `DesignFarmerConfig` built and persisted. Proceed to Phase 2: Repository Analysis.
