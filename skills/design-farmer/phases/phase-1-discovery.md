# Phase 1: Discovery Interview

**CRITICAL RULE: Ask questions ONE AT A TIME via AskUserQuestion. STOP after each question. Wait for the user's response before asking the next. Do NOT proceed until user responds. Do NOT batch multiple questions. Do NOT skip ahead.**

If the user expresses impatience after 3+ questions, offer to use sensible defaults for remaining questions and proceed.

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

**STOP. Do NOT proceed until user responds.**

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
> I'll use OKLCH for perceptual uniformity and generate a 9-step scale (50-950) with proper contrast ratios.

**STOP. Do NOT proceed until user responds.**

---

### Question 3: Component Scope

Via AskUserQuestion, ask:

> Let's define the initial component boundary.
>
> Based on your codebase analysis, these components appear most frequently:
> {top 5-10 component patterns found in the repo with usage counts}
>
> **Which component tier should I implement first?**
>
> RECOMMENDATION: Choose B — covers 80% of common UI needs and establishes patterns for everything else.
> Completeness: A=4/10, B=7/10, C=9/10, D=varies
>
> Options:
> - A) Foundation only — Tokens + Typography + Color + Spacing + Layout primitives
> - B) Core interactive — Foundation + Button, Input, Checkbox, Radio, Select, Dialog
> - C) Full starter kit — Core + Card, Toast, Tabs, Menu, Popover, Tooltip
> - D) Custom selection — Tell me which components you need
>
> Each component gets full accessibility (WCAG AA), keyboard navigation, and theme support.

**STOP. Do NOT proceed until user responds.**

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

**STOP. Do NOT proceed until user responds.**

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

**STOP. Do NOT proceed until user responds.**

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

**STOP. Do NOT proceed until user responds.**

---

### Question 5-1: Dark Mode Library (conditional)

**Only ask this if the user chose A (Light + Dark), C (Multi-brand), or D (Custom with dark mode) in Question 5. Skip if user chose B (Light only).**

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
> RECOMMENDATION: Choose B — for client-only React apps, a custom ThemeProvider
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

**STOP. Do NOT proceed until user responds.**

---

### Question 6: Accessibility Level

Via AskUserQuestion, ask:

> **What accessibility standard should we target?**
>
> RECOMMENDATION: Choose C — APCA pairs naturally with OKLCH's perceptual uniformity and provides more accurate contrast evaluation than traditional WCAG 2.x ratios.
>
> Options:
> - A) WCAG 2.2 AA — industry standard, legally required in many jurisdictions
> - B) WCAG 2.2 AAA — highest conformance, stricter contrast and interaction requirements
> - C) AA with APCA — modern contrast algorithm, better perceptual accuracy with OKLCH

**STOP. Do NOT proceed until user responds.**

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

**STOP. Do NOT proceed until user responds.**

---

### After All Questions Answered

Only after receiving ALL 7 responses, store answers in a structured format for subsequent phases:

```typescript
interface DesignFarmerConfig {
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
}
```

Summarize the user's choices back to them and ask for final confirmation:

Via AskUserQuestion, ask:
> Here's your design system configuration:
> {formatted summary of all 7 choices}
>
> **Is this correct? Ready to proceed?**
>
> Options:
> - A) Yes, proceed to repository analysis
> - B) I want to change some answers (specify which)

**STOP. Do NOT proceed until user confirms.**
