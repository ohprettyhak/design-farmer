---
name: design-farmer
version: 1.0.0
description: |
  Automated design system construction from repository analysis to production-ready implementation.
  Analyzes codebases, extracts design patterns, builds token hierarchies with OKLCH color management,
  implements accessible components with tests, and verifies through multi-reviewer panels.
  Use when: "build design system", "design tokens", "component library", "design-farmer"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
  - WebFetch
  - WebSearch
---

# Design Farmer

> From seed to system — cultivate a production-ready design system from any codebase.

Design Farmer analyzes your repository, extracts existing design patterns, and grows them into
a structured, accessible, OKLCH-native design system with tokens, components, tests, and documentation.

---

## Companion Documentation

To reduce maintenance risk in this large single-file spec, operational guidance is split into companion docs:

- `docs/PHASE-INDEX.md` — concise phase-by-phase responsibilities and handoff map
- `docs/QUALITY-GATES.md` — verification standards and release readiness criteria
- `docs/MAINTENANCE.md` — update workflow, anti-drift checks, and contribution checklist

`SKILL.md` remains the canonical runtime instruction file. Companion docs are maintainability aids and must stay aligned.

---

## Voice & Tone

- Speak like a senior design engineer pairing with the user — direct, specific, opinionated with reasoning.
- Name the file, the token, the component. Never speak in abstractions when a concrete path exists.
- One decision per question. Never batch multiple choices into a single prompt.
- Recommend the complete option. With AI assistance, thoroughness costs seconds more than shortcuts.
- When uncertain about the user's intent, ask. When certain, act and explain.

---

## Completion Status Protocol

Every phase concludes with one of:
- **DONE** — Phase complete with evidence (files created, tests passing, screenshots captured).
- **DONE_WITH_CONCERNS** — Phase complete but issues flagged for user awareness.
- **BLOCKED** — Cannot proceed. State what is missing and what would unblock.
- **NEEDS_CONTEXT** — Missing information that only the user can provide. Ask one question.

---

## Phase 0: Pre-flight

Run these checks before any other work:

```bash
# 1. Detect project root markers
ls package.json pnpm-workspace.yaml lerna.json turbo.json nx.json bun.lockb yarn.lock 2>/dev/null

# 2. Check for existing design system artifacts
find . -type f \( -name "tokens.*" -o -name "theme.*" -o -name "design-tokens.*" \) 2>/dev/null | head -20
find . -type d \( -name "design-system" -o -name "design-tokens" -o -name "primitives" -o -name "ui" \) 2>/dev/null | head -20

# 3. Check for existing component libraries
find . -path "*/components/*" -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" 2>/dev/null | head -30

# 4. Check for Storybook
ls .storybook/main.* 2>/dev/null

# 5. Detect existing color definitions
grep -r "oklch\|hsl\|rgb\|#[0-9a-fA-F]\{3,8\}" --include="*.css" --include="*.scss" --include="*.ts" --include="*.tsx" -l 2>/dev/null | head -20
```

If an existing design system is detected, report findings and ask:
> "An existing design system was found at `{path}`. Should I extend it, migrate it to the Design Farmer standard, or start fresh alongside it?"

---

## Phase 1: Discovery Interview

**CRITICAL RULE: Ask questions ONE AT A TIME via AskUserQuestion. STOP after each question. Wait for the user's response before asking the next. Do NOT proceed until user responds. Do NOT batch multiple questions. Do NOT skip ahead.**

If the user expresses impatience after 3+ questions, offer to use sensible defaults for remaining questions and proceed.

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

---

## Phase 2: Repository Analysis

Perform deep analysis of the codebase. Token budget is not a concern — thoroughness matters.

### 2.1 Project Structure Detection

```bash
# Monorepo detection
ls pnpm-workspace.yaml turbo.json nx.json lerna.json 2>/dev/null

# Package manager detection
if [ -f "bun.lockb" ]; then echo "bun"
elif [ -f "pnpm-lock.yaml" ]; then echo "pnpm"
elif [ -f "yarn.lock" ]; then echo "yarn"
elif [ -f "package-lock.json" ]; then echo "npm"
fi

# Framework detection
grep -l "react\|next\|vue\|nuxt\|svelte\|astro\|solid\|angular" package.json */package.json 2>/dev/null

# TypeScript detection
ls tsconfig.json tsconfig.*.json 2>/dev/null

# Build tool detection
ls vite.config.* next.config.* webpack.config.* turbo.json esbuild.* rollup.config.* 2>/dev/null

# Tailwind detection and version
ls tailwind.config.* 2>/dev/null
grep '"tailwindcss"' package.json 2>/dev/null  # Version check

# CI/CD pipeline detection
ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null  # GitHub Actions
ls .gitlab-ci.yml 2>/dev/null                                     # GitLab CI
ls vercel.json netlify.toml fly.toml 2>/dev/null                  # Platform configs

# Test framework detection
grep -l '"vitest"\|"jest"\|"@testing-library"\|"playwright"\|"cypress"' package.json 2>/dev/null
ls vitest.config.* jest.config.* playwright.config.* cypress.config.* 2>/dev/null

# Lint/format tooling
ls .eslintrc* eslint.config.* .prettierrc* biome.json oxlint* 2>/dev/null
```

### 2.1.1 Design Maturity Assessment

After scanning, classify the project into one of three maturity levels:

```
GREENFIELD (score 0-2):
  - No design tokens or CSS custom properties
  - Colors/spacing are hardcoded throughout
  - No consistent component patterns
  - Action: Follow best-practices.md reference for all sizing/styling decisions

EMERGING (score 3-5):
  - Some CSS variables or theme config exists
  - Partial component library (5-15 components)
  - Inconsistent naming or mixing of patterns
  - Action: Analyze existing patterns, standardize and extend

MATURE (score 6+):
  - Structured token system already in place
  - Component library with consistent API patterns
  - Theme switching exists (even if incomplete)
  - Action: Audit, identify gaps, migrate to OKLCH, add missing layers

Scoring criteria (1 point each):
  [ ] CSS custom properties or theme variables exist
  [ ] Token naming follows a pattern (e.g., --color-primary-500)
  [ ] Components are in a dedicated directory
  [ ] Component props follow consistent patterns
  [ ] Accessibility attributes present on interactive components
  [ ] Tests exist for UI components
  [ ] Dark mode or theming mechanism exists
  [ ] Typography uses a defined scale
  [ ] Spacing values follow a consistent base unit
  [ ] Documentation exists for component usage
```

Report the maturity level and score in the analysis report. This determines whether
to follow the **greenfield path** (build from best practices) or the **enhancement path**
(analyze and extend existing patterns) in subsequent phases.

### 2.2 Existing Pattern Extraction

Use the following analysis brief by default when your environment supports specialized delegation; otherwise perform the same scan directly:

```
Scan the codebase for:
1. All color values (hex, rgb, hsl, oklch, CSS custom properties with color values)
2. Typography definitions (font-family, font-size, line-height, font-weight)
3. Spacing values (margin, padding, gap with numeric values)
4. Border radius values
5. Shadow definitions
6. Breakpoint definitions
7. Z-index values
8. Animation/transition patterns

For each category, report:
- The exact values found
- File paths where they appear
- Frequency of use (how many files reference each value)
- Whether they use CSS variables, theme objects, or hardcoded values

Output as structured data.
```

### 2.3 Component Inventory

```bash
# Find all component-like files
find . -path "*/components/*" \( -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" \) | head -50

# Extract component names and prop interfaces
grep -r "export.*function\|export.*const\|export default" --include="*.tsx" --include="*.vue" -l | head -30

# Find styled-components, CSS modules, Tailwind usage
grep -rl "styled\.\|css`\|module\.css\|className=" --include="*.tsx" --include="*.ts" | head -20
grep -rl "tailwind\|@apply\|tw`" --include="*.css" --include="*.tsx" --include="*.ts" --include="*.config.*" | head -10
```

### 2.4 Analysis Report

Produce a structured report:

```markdown
## Repository Analysis Report

### Tech Stack
- Runtime: {Node.js version}
- Framework: {React 19 / Next.js 15 / etc.}
- Language: {TypeScript 5.x / JavaScript}
- Package Manager: {bun / pnpm / npm / yarn}
- Build Tool: {Vite / webpack / Turbopack / esbuild / Rollup}
- Styling: {CSS Modules / Tailwind v{version} / styled-components / vanilla CSS}
- Testing: {Vitest / Jest / Playwright / Cypress / none}
- Linting: {ESLint / Biome / oxlint / none}
- CI/CD: {GitHub Actions / GitLab CI / Vercel / Netlify / none}

### Repository Structure
- Type: {monorepo / single-repo}
- Packages: {list if monorepo}
- Component Location: {path}

### Design Maturity Assessment
- Score: {N}/10
- Level: {GREENFIELD / EMERGING / MATURE}
- Path: {greenfield — follow best practices / enhancement — analyze and extend}

### Existing Design Patterns
- Colors: {count} unique values ({count} hardcoded, {count} tokenized)
- Typography: {count} font-size values, {count} font-family values
- Spacing: {count} unique spacing values
- Other: {border-radius, shadows, z-index, breakpoints}
- Tailwind Config: {custom theme extensions found / default only / not using Tailwind}

### Recommendations
- Migration effort: {low/medium/high}
- Suggested approach: {extend existing / replace / greenfield}
- Styling strategy: {Tailwind v4 @theme / CSS Modules / CSS custom properties only}
- Headless library compatibility: {confirmed compatible / needs adapter / N/A}
```

---

## Phase 3: Design Pattern Extraction & OKLCH Conversion

### 3.1 Color Extraction & Conversion

Extract all color values and convert to OKLCH:

```
For each extracted color:
1. Parse the original format (hex, rgb, hsl)
2. Convert to OKLCH: oklch(L C H)
   - L (Lightness): 0 to 1
   - C (Chroma): 0 to ~0.4
   - H (Hue): 0 to 360 degrees
3. Group by hue similarity (within 15 degrees)
4. Identify the most-used color per hue group as the "base" color
```

### 3.2 OKLCH Palette Generation

For each identified base color, generate a 9-step palette:

```
Steps: 50, 100, 200, 300, 500, 700, 800, 900, 950

Algorithm:
1. Establish lightness bounds:
   - Delta = 0.4 (standard range)
   - L_min = max(0.05, base_L - delta/2)
   - L_max = min(0.95, base_L + delta/2)

2. Distribute lightness evenly across 9 steps:
   - Step 50:  L_max (lightest)
   - Step 950: L_min (darkest)
   - Step 500: base_L (midpoint)

3. Clamp chroma per step:
   - Use maxChroma(L, H, 'srgb') to ensure gamut safety
   - Reduce C while maintaining L and H if out of gamut

4. Maintain constant hue across all steps:
   - H never changes within a palette
   - If source had hue drift (HSL artifact), normalize to constant H
```

### 3.3 Contrast Validation (APCA)

```
For every foreground/background pair in the palette:
- Light backgrounds (L > 0.85): foreground L must be <= 0.45
- Dark backgrounds (L < 0.25): foreground L must be >= 0.75
- APCA thresholds: Lc 60 (pass), Lc 75 (preferred)
- NEVER adjust chroma for contrast — only modify the L channel
```

### 3.4 Dark Mode Derivation

```
Dark mode palette = reverse the lightness mapping:
- Light step 50  (L=0.95) -> Dark step 50  (L=0.15)
- Light step 950 (L=0.15) -> Dark step 950 (L=0.95)
- Preserve H and C percentages across the inversion
- Re-validate APCA contrast for all pairs in dark mode
```

### 3.5 Gamut Safety

```
For every generated color:
1. Check sRGB gamut boundary
2. If out-of-gamut: reduce C while preserving L and H
3. Optionally provide Display P3 enhanced version:
   @media (color-gamut: p3) {
     --color-primary-500: oklch(0.623 0.214 250);
   }
4. P3 gains by hue: greens/cyans +35% chroma, blues/purples +10-13%
```

### 3.6 Typography Extraction

```
Extract and normalize:
- Font families -> map to font-family tokens
- Font sizes -> normalize to a modular scale (1.125, 1.2, or 1.25 ratio)
- Line heights -> map to unitless ratios (1.2, 1.4, 1.5, 1.6)
- Font weights -> map to standard weight tokens (400, 500, 600, 700)
- Letter spacing -> map to tracking tokens
```

### 3.7 Spacing Extraction

```
Extract and normalize:
- All margin/padding/gap values
- Normalize to a base-4 or base-8 scale
- Generate spacing tokens: 0, 1(4px), 2(8px), 3(12px), 4(16px), 5(20px),
  6(24px), 8(32px), 10(40px), 12(48px), 16(64px), 20(80px), 24(96px)
```

---

## Phase 4: Architecture Design

### 4.1 Token Hierarchy (DTCG Standard)

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
      "500": { "$value": "oklch(0.55 0.20 250)", "$type": "color" },
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
    "primary":   { "$value": "{color.white}", "$type": "color" },
    "secondary": { "$value": "{color.gray.50}", "$type": "color" },
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

### 4.2 Directory Structure

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
      classnames.ts         # Class merging utility
    index.ts                # Public API barrel export
  __tests__/
    tokens.test.ts          # Token snapshot tests
    a11y.test.ts            # Accessibility test suite
    theme.test.ts           # Theme switching tests

{For single-repo — src/design-system:}

src/design-system/
  (same internal structure as above)
```

### 4.3 Token Build Pipeline

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

@theme {
  /* Colors from OKLCH palette */
  --color-primary-50: oklch(0.95 0.02 250);
  --color-primary-100: oklch(0.90 0.04 250);
  --color-primary-500: oklch(0.55 0.20 250);
  --color-primary-900: oklch(0.22 0.11 250);

  /* Semantic aliases */
  --color-surface: var(--surface-primary);
  --color-on-surface: var(--text-primary);

  /* Spacing from token scale */
  --spacing-0: 0px;
  --spacing-1: 4px;
  --spacing-2: 8px;
  --spacing-3: 12px;
  --spacing-4: 16px;
  --spacing-6: 24px;
  --spacing-8: 32px;

  /* Radius from token scale */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-full: 9999px;
}
```

This auto-generates Tailwind utility classes (e.g., `bg-primary-500`, `p-4`, `rounded-md`)
from your design tokens, maintaining a single source of truth.

### 4.4 CSS Layer Strategy

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

### 4.5 Theme System

```css
/* light.css */
@layer tokens {
  [data-theme="light"] {
    /* Surface */
    --surface-primary: oklch(1 0 0);
    --surface-secondary: oklch(0.97 0.005 250);
    --surface-inverse: oklch(0.15 0.01 250);

    /* Text */
    --text-primary: oklch(0.15 0.01 250);
    --text-secondary: oklch(0.45 0.02 250);
    --text-inverse: oklch(1 0 0);

    /* Interactive */
    --interactive-primary: oklch(0.55 0.20 250);
    --interactive-primary-hover: oklch(0.45 0.18 250);

    /* Border */
    --border-default: oklch(0.87 0.01 250);
    --border-strong: oklch(0.70 0.02 250);
  }

  /* dark.css — lightness inverted, hue/chroma preserved */
  [data-theme="dark"] {
    --surface-primary: oklch(0.15 0.01 250);
    --surface-secondary: oklch(0.20 0.015 250);
    --surface-inverse: oklch(0.97 0.005 250);

    --text-primary: oklch(0.95 0.005 250);
    --text-secondary: oklch(0.70 0.02 250);
    --text-inverse: oklch(0.15 0.01 250);

    --interactive-primary: oklch(0.65 0.20 250);
    --interactive-primary-hover: oklch(0.72 0.18 250);

    --border-default: oklch(0.30 0.015 250);
    --border-strong: oklch(0.45 0.02 250);
  }
}
```

### 4.6 Theme Provider Implementation

The theme provider depends on whether the user chose a library (Question 5-1) or custom:

**If using a library (next-themes, mode-watcher, etc.):**

Generate the following files based on the detected framework:

**Step 1 — Root layout (`app/layout.tsx` for Next.js):**

next-themes modifies `<html>` attributes on the client before hydration completes.
`suppressHydrationWarning` on `<html>` is **REQUIRED** to prevent React hydration mismatch
warnings. This prop only applies one level deep, so it does NOT mask errors in children.

```tsx
// app/layout.tsx
import { ThemeProvider } from '@/components/theme-provider'

export default function RootLayout({ children }: { children: React.ReactNode }) {
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

import { ThemeProvider as NextThemesProvider } from 'next-themes'

export function ThemeProvider({ children }: { children: React.ReactNode }) {
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

### 4.7 Scoped Theming

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

### 4.8 Dark Mode Implementation Checklist & Common Failures

**MANDATORY verification after implementing dark mode. Check every item before proceeding.**

#### Implementation Checklist

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

#### Common Dark Mode Failure Patterns

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

#### Attribute Alignment Reference

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

### 4.9 Styling Approach Decision

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

If no styling framework detected:
  -> Default to CSS custom properties + vanilla CSS
  -> Lightweight, zero-dependency approach
  -> Consider recommending Tailwind v4 for utility-first workflow
```

---

## Phase 5: Token Implementation

Implement tokens in this order. Use the following implementation brief by default when specialized delegation is available; otherwise execute the same work directly:

### 5.1 OKLCH Utility Functions

```typescript
// src/utils/oklch.ts
// - oklchToString(l, c, h, alpha?): string
// - parseOklch(value: string): { l, c, h, alpha }
// - generatePalette(baseColor: string, steps?: number[]): Record<string, string>
// - clampToGamut(l: number, c: number, h: number, colorSpace?: string): { l, c, h }
// - maxChroma(l: number, h: number, colorSpace?: string): number
```

### 5.2 Contrast Utilities

```typescript
// src/utils/contrast.ts
// - apcaContrast(fgL: number, bgL: number): number
// - meetsContrastThreshold(fg: string, bg: string, level?: 'pass' | 'preferred'): boolean
// - suggestForegroundL(bgL: number, minContrast?: number): number
```

### 5.3 Primitive Tokens

Implement all primitive token files based on extracted patterns and user choices.
Each file exports typed constants and generates corresponding CSS custom properties.

### 5.4 Semantic Tokens

Map primitives to semantic purposes. Ensure components ONLY consume semantic tokens,
never primitive tokens directly. This enables theming without component API changes.

### 5.5 Token Snapshot Tests

```typescript
// __tests__/tokens.test.ts
// - Verify generated CSS is deterministic (snapshot comparison)
// - Verify all semantic tokens resolve to valid OKLCH values
// - Verify light/dark theme CSS files contain identical property names
// - Verify no primitive token is directly consumed by any component
```

Optional implementation brief:
```
Implement the token system at {systemPath}/src/tokens/ following the architecture
defined in Phase 4. Use OKLCH values throughout. Generate light.css and dark.css
theme files. Include TypeScript type exports for all tokens.
Config: {serialized DesignFarmerConfig}
Extracted patterns: {serialized extraction results}
```

---

## Phase 6: Component Implementation

Implement components ONE AT A TIME, in dependency order.

The implementation path depends on **Design Maturity** (from Phase 2) and **Headless Library**
choice (from Question 3-1):

### 6.0 Path Selection

```
If Design Maturity = GREENFIELD (score 0-2):
  -> Use research/best-practices.md as sizing/styling reference
  -> If headless library chosen: wrap headless primitives with styled layer
  -> If no library: build custom primitives from scratch
  -> Every sizing decision (height, padding, font-size, radius) comes from best-practices.md

If Design Maturity = EMERGING (score 3-5):
  -> Analyze existing component patterns first
  -> Identify inconsistencies vs. best-practices.md
  -> Standardize existing patterns, fill gaps with best-practices.md defaults
  -> Migrate to headless library gradually if chosen

If Design Maturity = MATURE (score 6+):
  -> Deep analysis of existing component API patterns
  -> Preserve existing props interface where possible
  -> Add missing accessibility, token integration, and theme support
  -> Do NOT break existing consumer code without explicit user approval
```

### 6.1 Headless Component Wrapping Pattern

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
// Sizing values from research/best-practices.md:
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

### 6.2 Component Implementation Cycle

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
   Reference `research/best-practices.md` for sizing values when building greenfield.

2. **Implementation** — Build the component:
   ```
   Implement {ComponentName} at {systemPath}/src/primitives/{component}/

   Design maturity: {GREENFIELD|EMERGING|MATURE}
   Headless library: {radix|base-ui|ark|none}
   Styling approach: {tailwind|css-modules|css-custom-properties}

   Contract: {props interface}
   Sizing reference: {values from research/best-practices.md for this component}
   Token dependencies: {semantic tokens this component uses}

   Requirements:
   - If headless library: wrap the library's primitive with styled layer
   - If no library: implement ARIA attributes, keyboard nav, focus management from scratch
   - Consume ONLY semantic tokens (never primitive tokens directly)
   - All sizes from best-practices.md reference (height, padding, font-size, radius)
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
   - All variants × all sizes (e.g., Button: 5 variants × 5 sizes = 25 combinations)
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

### 6.3 Component Priority Order

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

---

## Phase 7: Storybook Integration

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

**STOP. Do NOT proceed until user responds.**

If user chose A or B:

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
Storybook releases frequently (7.x → 8.x → 9.x → ...) and addons must match the
installed Storybook major version. Always verify compatibility before installing.

**Step 2 — Delegate installation:**

```
Install and configure Storybook for the design system at {systemPath}:

IMPORTANT: First run `npm view storybook version` to determine the latest stable version.
Use that version throughout — do NOT assume any specific major version number.

1. Install: npx storybook@latest init (or bun/pnpm equivalent based on detected package manager)
   - Verify the installed version after init: npx storybook --version
2. Configure addons (ensure versions match the installed Storybook major version):
   - @storybook/addon-a11y (accessibility checking)
   - @storybook/addon-themes (dark mode toggle)
   - @storybook/addon-docs (auto documentation)
3. Configure .storybook/preview.ts:
   - Import the design system's global CSS (tokens, reset, theme files)
   - Set up theme decorator for dark mode toggle (see 'Storybook Dark Mode Decorator' below)
   - Configure viewport presets (mobile: 375px, tablet: 768px, desktop: 1280px)
   - Enable autodocs for automatic API documentation generation
4. Create stories for every implemented component following the Polymorphic Coverage
   Matrix defined in Step 3 below.
```

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
export const Small: Story = { args: { size: 'sm', children: 'Small' } }
export const Medium: Story = { args: { size: 'md', children: 'Medium' } }
export const Large: Story = { args: { size: 'lg', children: 'Large' } }

export const AllSizes: Story = {
  render: () => (
    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
      {['sm', 'md', 'lg'].map(s => (
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
Theme decorator already applied globally (Step 3 above). Add a dedicated side-by-side
comparison story per component:

```tsx
export const ThemeComparison: Story = {
  render: () => (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
      <div data-theme="light" style={{ padding: '1rem', background: 'var(--surface-primary)' }}>
        <Button variant="primary">Light Mode</Button>
      </div>
      <div data-theme="dark" style={{ padding: '1rem', background: 'var(--surface-primary)' }}>
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
        <DialogDescription>Description text</DialogDescription>
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

**Step 3 — Storybook Dark Mode Decorator Configuration:**

The decorator in `.storybook/preview.ts` MUST match the `attribute` used by the app's
`ThemeProvider`. A mismatch means the Storybook toggle changes state but components
render with wrong theme styles.

```typescript
// .storybook/preview.ts

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

---

## Phase 8: Multi-Reviewer Verification

Five specialized reviewers evaluate the design system. Each role is defined inline — no external
plugins or agent frameworks required. Run every reviewer pass; execute them in parallel by default when your environment supports independent work, otherwise run them sequentially without skipping any pass.

**Finding format (all reviewers):** `[SEVERITY] (confidence: N/10) file:line — description`

**Severity levels:**
- **CRITICAL** — blocks completion; must fix before proceeding
- **HIGH** — should fix; significant quality concern
- **MEDIUM** — consider fixing; minor quality concern
- **LOW** — style/polish; note for future improvement

**Confidence scoring:**
- 9-10: Verified by reading specific code. Concrete bug demonstrated.
- 7-8: High-confidence pattern match.
- 5-6: Moderate confidence, possible false positive. Show with caveat.
- 3-4: Low confidence. Suppress to appendix.
- 1-2: Speculation. Suppress entirely.

---

### 8.1 Design System Critic

**Role:** You are a senior design systems architect who has built and maintained design
systems at scale. You think in contracts, not code. Your job is to verify that the
system's structural promises are kept — token hierarchy integrity, theming contracts,
and cross-component consistency. You are opinionated but evidence-driven: every claim
cites a specific file and line.

```
You are a Design System Critic reviewing {systemPath}.

## Your Perspective
Think like an architect who maintains a design system consumed by 20+ product teams.
Your priority is systemic integrity — one broken contract causes cascading failures.

## Evaluation Criteria (weighted)

| Criterion | Weight | Pass Threshold |
|-----------|--------|---------------|
| Token hierarchy integrity | 20% | Zero direct primitive token usage in components |
| OKLCH consistency | 15% | All color values are valid oklch() format |
| Contrast compliance | 20% | All text/bg pairs meet APCA Lc 60+ |
| API consistency | 15% | Similar components share identical prop naming patterns |
| Theme completeness | 15% | Light and dark CSS files define identical custom property names |
| Test coverage | 15% | Every component has unit test + axe a11y test |

## Audit Process
1. Read every token file. Verify three-tier hierarchy: primitive -> semantic -> component.
2. Grep all component files for hardcoded color values or direct primitive token references.
3. For each semantic token pair (text + surface), compute APCA contrast from OKLCH L values.
4. Compare prop interfaces across similar components (Button vs IconButton, Input vs TextArea).
5. Diff the custom property names between light.css and dark.css.
6. Check that every component directory contains a .test file with axe assertions.

## Scoring
quality_score = max(0, 10 - (critical_count * 2 + high_count * 1 + medium_count * 0.3))

## Output
For each criterion: score (1-10), evidence (file:line), and specific failures.
Final verdict: PASS (all criteria >= 7) or FAIL (any < 7).
If FAIL, list exact fixes required with file paths.
```

**STOP. Read the critic's output. If CRITICAL findings exist, fix them before running other reviewers.**

---

### 8.2 Code Quality Reviewer

**Role:** You are a staff frontend engineer obsessed with code correctness and
maintainability. You've seen design systems rot from sloppy imports, leaky abstractions,
and `any` types. You review like it's a PR that will be consumed by every engineer in
the company.

```
You are a Code Quality Reviewer for the design system at {systemPath}.

## Your Perspective
Review this as production library code that will be imported by dozens of consumer apps.
Every public export is a contract. Every `any` type is a hole in the contract.

## Checklist (run in order)

### TypeScript Strictness (weight: 25%)
- [ ] Zero `any` types in public API surface
- [ ] All component props use explicit interfaces (not inline object types)
- [ ] Union types are exhaustive (switch statements have default case or exhaustive check)
- [ ] Generic components are properly constrained
- [ ] Re-exported types match source types (no accidental widening)

### Component Patterns (weight: 25%)
- [ ] forwardRef used on all components that render DOM elements
- [ ] Event handlers typed with React event types (not generic Function)
- [ ] children typed correctly (ReactNode for containers, never for leaf components)
- [ ] displayName set for forwardRef components (debugging support)
- [ ] Default props use parameter defaults, not defaultProps

### Lint Suppression (weight: mandatory — any violation is CRITICAL)
- [ ] ZERO `biome-ignore` comments in generated code
- [ ] ZERO `eslint-disable` or `eslint-disable-next-line` comments
- [ ] ZERO `@ts-ignore` comments — use `@ts-expect-error` with explanation only if genuinely unavoidable
- [ ] ZERO `// @ts-nocheck` files
- [ ] If a lint rule fires, FIX the underlying code — never suppress the warning
- [ ] If a lint rule is a false positive, document why and fix the rule config, not the code

**CRITICAL: Lint suppression comments are NEVER acceptable in generated design system code.
They mask real issues and create technical debt from day one. If the code triggers a lint
error, the code is wrong — fix it. If the lint rule is wrong for this project, update the
lint configuration (eslintrc, biome.json, etc.) instead.**

### Deprecated React Patterns (weight: mandatory — any violation is CRITICAL)
- [ ] NEVER use `React.FC` or `React.FunctionComponent` — use explicit return types or infer
- [ ] NEVER use `React.ElementRef<T>` (deprecated) — use `React.ComponentRef<T>` instead
- [ ] For component prop types, use `React.ComponentPropsWithoutRef<T>` — the ref is
  handled separately by forwardRef's generic parameter, not via props
- [ ] NEVER use `defaultProps` — use parameter defaults in destructuring
- [ ] NEVER use `propTypes` — use TypeScript interfaces exclusively
- [ ] NEVER use legacy string refs — only callback refs or useRef

**Modern component typing reference:**

```typescript
// CORRECT — modern pattern
import { forwardRef } from 'react'

interface ButtonProps extends React.ComponentPropsWithoutRef<'button'> {
  variant?: 'primary' | 'secondary' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', size = 'md', ...props }, ref) => {
    return <button ref={ref} {...props} />
  }
)
Button.displayName = 'Button'

// WRONG — deprecated patterns
const Button: React.FC<ButtonProps> = (props) => { ... }  // ❌ React.FC
type Ref = React.ElementRef<typeof SomeComponent>          // ❌ React.ElementRef
Button.defaultProps = { variant: 'primary' }               // ❌ defaultProps
```

### CSS Architecture (weight: 20%)
- [ ] Zero hardcoded color/spacing/radius values in component CSS
- [ ] All styles reference CSS custom properties from semantic tokens only
- [ ] No !important usage
- [ ] CSS specificity stays flat (max 0-2-0 for component styles)
- [ ] No global selectors that could leak to consumers

### Import Hygiene (weight: 15%)
- [ ] No circular dependencies (verify with: check import chains)
- [ ] Barrel exports (index.ts) re-export only public API
- [ ] No side effects in module scope (safe for tree-shaking)
- [ ] Internal utilities not exposed in public barrel

### Bundle Impact (weight: 15%)
- [ ] Each component independently importable (no pulling entire library)
- [ ] CSS is co-located or lazy-loaded (not bundled into JS)
- [ ] No runtime dependencies on heavy libraries (lodash, moment, etc.)
- [ ] Package.json has correct sideEffects field

## Finding Format
[SEVERITY] (confidence: N/10) file:line — description

## Output
Findings grouped by checklist section.
Summary: X critical, Y high, Z medium, W low.
quality_score = max(0, 10 - (critical * 2 + high * 1 + medium * 0.3))
```

---

### 8.3 Token & Color Scientist

**Role:** You are a color science and design token specialist. You validate with
data, not opinions. You run computations on every color value, measure every spacing
ratio, and count every token reference. If a claim can be quantified, you quantify it.

```
You are a Token & Color Scientist analyzing the design system at {systemPath}.

## Your Perspective
You trust numbers, not aesthetics. Your job is to verify that the mathematical
foundations of this design system are correct — that OKLCH palettes are properly
generated, contrast ratios actually pass, and tokens are actually used.

## Analysis Tasks

### 1. Token Coverage Audit (weight: 30%)
Run these exact checks:
a) Count total CSS custom properties defined across all theme files
b) Grep all component files for each defined property — count references
c) List any defined-but-never-used tokens (dead tokens)
d) Grep component files for hardcoded values that should be tokens:
   - Color values: hex, rgb(), hsl() not wrapped in var()
   - Spacing values: px/rem values not referencing spacing tokens
   - Font values: font-size/font-weight not referencing typography tokens
e) Calculate: coverage_ratio = used_tokens / defined_tokens

Pass threshold: coverage_ratio >= 0.85, zero hardcoded colors in components

### 2. OKLCH Color Validation (weight: 40%)
For every oklch() value in the token files:
a) Parse L, C, H values
b) Verify L is within [0.05, 0.95] (clamped range)
c) Verify C does not exceed maxChroma for the given L and H in sRGB gamut
d) For each 9-step palette, verify lightness distribution:
   - Step 50 should have highest L, step 950 lowest L
   - Steps should be roughly evenly distributed
   - Hue (H) must be constant across all steps (tolerance: ±0.5 degrees)
e) Contrast matrix: for every text token + surface token combination:
   - Compute APCA contrast from L values
   - Light bg (L > 0.85): fg L must be <= 0.45
   - Dark bg (L < 0.25): fg L must be >= 0.75
   - Flag any pair below Lc 60

Pass threshold: zero out-of-gamut colors, zero contrast failures, constant hue per palette

### 3. Spacing & Scale Consistency (weight: 15%)
a) Extract all spacing token values
b) Verify they follow a consistent base (base-4 or base-8)
c) Check no intermediate values break the scale (e.g., 13px in a base-4 system)
d) Verify border-radius values form a coherent progression

### 4. Component Metrics (weight: 15%)
a) For each component CSS file: count selectors, measure max specificity
b) Flag any selector with specificity > 0-2-1
c) Count total CSS rules per component (flag if > 100 rules)

## Output Format
Structured data tables for each analysis.
Pass/fail per section with numeric evidence.
Overall: PASS (all sections pass) or FAIL (list failures with data).
```

---

### 8.4 Visual Design Reviewer

**Role:** You are a senior product designer who thinks like a designer, not a QA
engineer. You evaluate whether things feel right and look intentional. You care about
visual hierarchy, rhythm, proportion, and the emotional tone of the system. You flag
generic, AI-sloppy, or inconsistent design choices.

```
You are a Visual Design Reviewer evaluating the design system at {systemPath}.

## Your Perspective
Think like a designer reviewing a Figma library before approving it for production.
You care about intentionality — does this system have a point of view, or is it
generic Bootstrap-with-extra-steps?

## Evaluation Categories (10 areas, letter grade A-F each)

### 1. Visual Hierarchy & Composition (weight: 15%)
- Typography scale creates clear hierarchy (display > h1 > h2 > body > caption)
- Whitespace usage is intentional (not just 'add padding until it looks ok')
- Component density is appropriate for the stated purpose

### 2. Typography System (weight: 15%)
- Font choices complement each other (display vs body)
- Size scale follows a consistent mathematical ratio
- Line heights ensure comfortable reading (1.4-1.6 for body)
- Letter spacing is intentional, not default

### 3. Color Harmony (weight: 15%)
- OKLCH palettes maintain perceptual uniformity across hues
- Color system has a recognizable personality (not generic blue)
- Interactive states (hover/active/focus) feel natural and progressive
- Danger/warning/success semantics are distinct and intuitive

### 4. Spacing & Rhythm (weight: 10%)
- Spacing scale values are harmonious (consistent ratio between steps)
- Internal component spacing feels balanced
- Spacing between components creates clear groupings

### 5. Component Craft (weight: 10%)
- Border radii are consistent and proportional to component size
- Shadows create a coherent elevation system (not random drops)
- Focus indicators are visible but not jarring
- Disabled states are clearly disabled but not ugly

### 6. Interactive States (weight: 10%)
- Hover gives immediate feedback
- Active/pressed feels responsive
- Focus ring is keyboard-visible but not mouse-visible (or acceptable for both)
- Loading states communicate progress

### 7. Dark Mode Quality (weight: 10%)
- INFRASTRUCTURE: suppressHydrationWarning on `<html>`, correct ThemeProvider setup
- Attribute alignment: ThemeProvider = CSS selectors = Tailwind config = Storybook decorator
- No FOUC: page loads in correct theme without flash
- Theme toggle works and persists across page reload
- Dark theme has its own personality (not just inverted lightness)
- Contrast is maintained without eye strain (APCA Lc 60+)
- Colored elements adapt naturally (not washed out or neon)
- All semantic tokens defined in both light and dark sets
- No hardcoded color values in components
- Theme-dependent UI uses mounted guard pattern

### 8. Responsive Awareness (weight: 5%)
- Token values account for viewport variations
- Typography scale has responsive adjustments defined

### 9. AI Slop Detection (weight: 5%)
Flag if ANY of these patterns are present in the design decisions:
- Purple/violet gradients as primary aesthetic choice
- Uniform bubbly border-radius on every element
- Icons in colored circles as decoration
- Generic SaaS card grid layout as default pattern
- Overly safe, personality-free color choices (plain blue + gray)

### 10. System Coherence (weight: 5%)
- All tokens feel like they belong to the same visual language
- Adding a new component would be straightforward given the established patterns
- The system has a recognizable identity, not a random collection

## Scoring
| Grade | Meaning |
|-------|---------|
| A | Intentional, polished — shows design thinking |
| B | Solid fundamentals — professional, minor inconsistencies |
| C | Functional, generic — works but has no point of view |
| D | Noticeable problems — unfinished or careless |
| F | Actively harmful — significant rework required |

Each High-impact finding drops one letter grade.
Each Medium-impact finding drops half a letter grade.

## Output
Per-category grade with specific evidence.
Overall Design Quality grade (weighted).
Top 3 strengths and top 3 improvements with actionable suggestions.
```

---

### 8.5 Design Systems Engineer

**Role:** You are a principal engineer who specializes in design system infrastructure.
You evaluate the system's ability to scale, perform, and provide a great developer
experience. You think in terms of build pipelines, bundle sizes, API surfaces, and
the daily life of the consuming developer.

```
You are a Design Systems Engineer reviewing {systemPath}.

## Your Perspective
You've maintained design systems consumed by 50+ engineers. You know that a design
system's success depends more on DX and reliability than on visual beauty. Your review
focuses on what happens when a team of 20 starts using this tomorrow.

## Evaluation Areas

### 1. Scalability (weight: 25%)
- Can a new component be added by creating a new directory without modifying existing files?
- Can a new theme be added by creating a new CSS file without touching components?
- Can a new token type (e.g., motion) be added without restructuring the pipeline?
- Is the token build pipeline self-contained and deterministic?
- Are component boundaries clean (no component importing from another's internals)?

### 2. Performance (weight: 25%)
- CSS custom properties: are they organized to minimize re-computation on theme switch?
- Components: do theme changes cause unnecessary re-renders beyond the theme provider?
- Bundle: can a consumer import Button without pulling the entire design system?
- Tree-shaking: is the package.json sideEffects field correct?
- CSS size: is the total CSS output reasonable for the number of components?

### 3. Developer Experience (weight: 25%)
- TypeScript: does autocompletion work well? (specific prop names, not string unions of 50 items)
- Error surface: if a consumer uses an invalid variant, does TypeScript catch it at compile time?
- Import paths: are they intuitive? (import { Button } from 'design-system')
- Documentation: can a developer use a component in < 5 minutes from reading the API?
- Migration: if a token value changes, can consumers find all affected usages?

### 4. Reliability (weight: 25%)
- Tests: are they testing behavior, not implementation details?
- Build: is the output deterministic (same input → same output, always)?
- Dependencies: are peer dependencies minimal and clearly specified?
- Versioning: is the package set up for proper semver?
- CI readiness: can tests, typecheck, and build run in a single command?

## Scoring
Each area scored 1-10. Overall = weighted average.

## Verdicts
- **APPROVED** — all areas >= 7, zero CRITICAL findings
- **APPROVED_WITH_CHANGES** — all areas >= 5, specific changes listed
- **NEEDS_REWORK** — any area < 5, fundamental issues identified

## Output
Per-area score with evidence (file:line references).
If not APPROVED: numbered list of required changes, ordered by impact.
```

---

### 8.6 Review Aggregation & Risk Regulation

After all reviewers complete, aggregate results.

**Risk heuristic** (cumulative during fix iterations):
```
Base: 0%
+ 15% per reverted fix
+ 5% per fix touching > 3 files
+ 1% per fix after the 15th fix
```

If risk > 20%: STOP and ask user whether to continue.
Hard cap: 30 fixes maximum.

**Aggregation logic:**

```
1. Collect all findings across all 5 reviewers
2. Deduplicate: same file:line from multiple reviewers = single finding at highest severity
3. Sort by severity: CRITICAL -> HIGH -> MEDIUM -> LOW

4. If zero CRITICAL findings across all reviewers:
   -> Status: DONE
   -> Proceed to Phase 9 (Documentation)

5. If any CRITICAL findings:
   -> Fix CRITICAL issues (one at a time, atomic commits)
   -> Re-run ONLY the reviewer(s) that flagged the CRITICAL finding
   -> Loop until zero CRITICAL findings remain

6. If HIGH findings exist but no CRITICAL:
   -> Present HIGH findings to user via AskUserQuestion
   -> User decides: fix now, defer, or accept as-is
   -> STOP. Do NOT proceed until user responds.

7. If same issue persists after 3 fix attempts:
   -> Status: BLOCKED
   -> Report to user with analysis of why the fix isn't working
   -> STOP. Do NOT proceed until user responds.
```

**Final review report format:**

```
## Design System Review Report

### Scores
| Reviewer | Score | Verdict |
|----------|-------|---------|
| Critic | {N}/10 | PASS/FAIL |
| Code Quality | {N}/10 | {X}C {Y}H {Z}M {W}L |
| Token Scientist | PASS/FAIL | {coverage}% token coverage |
| Visual Design | {grade} | {weighted grade} |
| Systems Engineer | {N}/10 | APPROVED/CHANGES/REWORK |

### Critical Findings: {count}
### High Findings: {count}
### Total Findings: {count}
### Fixes Applied: {count}
### Risk Level: {percentage}%
```

---

## Phase 8.5: Design Review (Live Visual QA)

After code-level reviewers pass, evaluate the design system's **rendered output** — not just
the source code. This phase catches visual issues that code review cannot: spacing that looks
wrong despite correct token values, color combinations that feel off, and interaction patterns
that don't feel responsive.

**Pre-requisite:** A running dev server or Storybook instance where components can be viewed.

### 8.5.1 Browser Tooling Discovery & Setup

Before visual QA begins, detect whether the repository already includes supported browser
tooling. Do not assume unrelated CLIs, and do not trigger package installation or network
access just to probe availability.

```bash
# Prefer browser tooling already declared in the project
if ls playwright.config.* >/dev/null 2>&1 || grep -q '"@playwright/test"\|"playwright"' package.json 2>/dev/null; then
  echo "VISUAL_TOOL=playwright"
else
  echo "VISUAL_TOOL=none"
fi
```

**Option A — Project-declared browser tooling (preferred if already configured):**
- Use the repository's existing browser tooling against the running dev server or Storybook
- Capture screenshots per component per theme
- Responsive viewport testing via viewport configuration

**Option B — Manual verification fallback:**
- If no project browser tool is available, scope Phase 8.5 as manual verification
- Generate a structured checklist for user-provided screenshots
- Document limitation in completion report

```bash
# Start the dev server or Storybook in background
{packageManager} run dev &          # or: {packageManager} run storybook
# Wait for server to be ready
sleep 5
```

If no dev server is available (e.g., library-only package without a preview app),
use Storybook stories as the evaluation target.

If neither a dev server nor Storybook is available, skip this phase
and note it in the completion report.

**No project browser tooling fallback:**
```
Log: "Visual tooling unavailable. Phase 8.5 running in manual verification mode."
Generate a markdown checklist at {systemPath}/docs/visual-qa-checklist.md
Prompt user: "No browser tooling detected. Please provide screenshots of each component
in both light and dark themes for visual QA review."
```

### 8.5.2 Visual Design Audit (10 Categories)

Evaluate each rendered component against these 10 categories. For each finding,
capture a screenshot as evidence.

For each finding:
1. Capture BEFORE screenshot (or prompt user to provide one)
2. Apply fix
3. Capture AFTER screenshot
4. Compare and classify outcome

```
Category                        Weight   Items
─────────────────────────────────────────────────
1. Visual Hierarchy              15%     Element sizing creates clear importance order
                                         Primary actions are visually dominant
                                         Whitespace guides the eye naturally

2. Typography                    15%     Scale creates readable hierarchy
                                         Line heights provide comfortable reading
                                         Font weights differentiate headings from body
                                         Letter-spacing is intentional

3. Color & Contrast              15%     OKLCH palettes look perceptually even
                                         Interactive colors stand out from static content
                                         Semantic colors (danger/success/warning) are distinct
                                         Text meets APCA Lc 60+ on all backgrounds

4. Spacing & Rhythm              10%     Component internal spacing is balanced
                                         Spacing between elements creates clear groups
                                         Scale is consistent (no arbitrary values)

5. Interactive States            10%     Hover gives immediate visual feedback
                                         Focus ring is clearly visible on keyboard nav
                                         Active/pressed feels responsive
                                         Disabled is recognizable but not ugly
                                         Loading communicates progress

6. Component Consistency         10%     Similar components share visual language
                                         Size variants align across component types
                                         (sm Button same height as sm Input)
                                         Icon sizing is proportional

7. Dark Mode Quality             10%     INFRASTRUCTURE:
                                         <html> has suppressHydrationWarning (Next.js)
                                         ThemeProvider is "use client" with correct attribute
                                         Attribute alignment: ThemeProvider = CSS = Tailwind = Storybook
                                         No FOUC: page loads in correct theme without flash
                                         Theme toggle works and persists across page reload
                                         System preference detection works (prefers-color-scheme)
                                         VISUAL:
                                         Dark theme has appropriate contrast (APCA Lc 60+)
                                         Colors don't look washed out or neon
                                         Shadows/elevation adapt (lighter/subtler in dark mode)
                                         No pure white (#fff) text on dark backgrounds
                                         All semantic tokens defined in BOTH light and dark sets
                                         No hardcoded colors in components (all via CSS variables)
                                         COMPONENT-LEVEL:
                                         Theme-dependent UI uses mounted guard pattern
                                         resolvedTheme used (not theme) for runtime checks
                                         Storybook stories render correctly in both themes
                                         Focus rings visible in both light and dark mode

8. Responsive Behavior            5%     Components adapt to narrow containers
                                         Text doesn't overflow or clip
                                         Touch targets are >= 44px on mobile

9. Motion & Transitions           5%     Hover/focus transitions feel smooth
                                         Dialog/popover open/close is animated
                                         No janky or jarring animations
                                         prefers-reduced-motion is respected

10. AI Slop Detection             5%     No generic purple gradients
                                         No uniform bubbly border-radius everywhere
                                         No cookie-cutter 3-column feature grids
                                         Design has a recognizable identity
```

### 8.5.3 Responsive Viewport Testing

If browser tooling available, test each component at:
- Mobile: 375×667 (iPhone SE)
- Tablet: 768×1024 (iPad)
- Desktop: 1280×720 (standard)

For each viewport:
- Verify no horizontal overflow
- Verify touch targets >= 44px on mobile
- Verify text remains readable
- Verify spacing adapts appropriately

### 8.5.4 Scoring Rubric

Each category receives a letter grade:

| Grade | Meaning | Threshold |
|-------|---------|-----------|
| **A** | Intentional, polished — shows design thinking | 0 high findings, ≤1 medium |
| **B** | Solid fundamentals — professional with minor issues | 0 high, ≤3 medium |
| **C** | Functional, generic — works but lacks personality | ≤1 high, ≤5 medium |
| **D** | Noticeable problems — unfinished or careless | ≤3 high |
| **F** | Actively harmful — significant rework needed | >3 high |

**Grading formula:**
- Each HIGH finding drops one letter grade
- Each MEDIUM finding drops half a letter grade
- POLISH findings are noted but don't affect grade

**Overall Design Score** = weighted average of all 10 category grades.

### 8.5.5 Finding Format

Each visual finding is documented as:

```
ID: VIS-{NNN}
Category: {1-10 from above}
Impact: HIGH / MEDIUM / POLISH
Component: {component name or "system-wide"}
Description: "I notice {observation}. What if {suggestion}?"
Evidence: {screenshot before fix}
```

Findings are appended immediately upon discovery — never batch.

### 8.5.6 Fix Loop

For each finding, starting from HIGH impact down to MEDIUM:

```
1. Identify the source:
   - Which CSS file / component / token is responsible?
   - Is this a token value issue or a component styling issue?

2. Apply minimal fix:
   - CSS/token changes preferred over structural component changes
   - One fix per commit: git commit -m "style(design-review): VIS-{NNN} — {description}"

3. Re-verify:
   - Reload the component in dev server / Storybook
   - Capture after-screenshot
   - Compare before/after

4. Classify outcome:
   - VERIFIED: fix works, no side effects on other components
   - BEST_EFFORT: partially improved, acceptable trade-off
   - REVERTED: caused regression, reverted the commit
   - DEFERRED: requires design decision from user, logged as TODO
```

### 8.5.7 Risk Regulation

Track cumulative fix risk to prevent quality degradation:

```
Base: 0%
+ 15% per reverted fix
+ 0% per CSS/token-only change
+ 5% per component JSX/TSX change
+ 1% per fix (after 10th fix)
+ 20% per unrelated file touch

Thresholds:
  > 20%: STOP. Ask user whether to continue via AskUserQuestion.
  > 30%: Hard stop. Report remaining findings as TODO items.
  Maximum: 30 fixes per review session.
```

### 8.5.8 Design Review Triage

Via AskUserQuestion, ask:

> ## Design Review Results
>
> Overall Score: {grade}
> Categories with issues: {list categories below B}
>
> Findings breakdown:
> - HIGH: {count} (will fix)
> - MEDIUM: {count} (fix if within risk budget)
> - POLISH: {count} (noted for future)
>
> **How should I proceed?**
>
> Options:
> - A) Fix all HIGH + MEDIUM findings (Recommended — full quality pass)
> - B) Fix HIGH only — defer MEDIUM to backlog
> - C) Review findings list first — I'll choose which to fix
> - D) Skip fixes — accept current quality and proceed to documentation

**STOP. Do NOT proceed until user responds.**

After fixing, re-score the affected categories. Include before/after grades in
the completion report.

---

## Phase 9: Documentation & Completion

### 9.1 Generate Documentation

Create documentation at `{systemPath}/docs/` or inline in source:

```
- README.md: Getting started, installation, usage
- TOKENS.md: Token naming conventions, usage rules, adding new tokens
- COMPONENTS.md: Component API reference, variant guide, accessibility notes
- THEMING.md: Theme creation, customization, dark mode setup
- CONTRIBUTING.md: How to add components, testing requirements, review process
```

### 9.2 Final Verification

```bash
# Run all tests
{packageManager} test

# Type check
{packageManager} run typecheck  # or npx tsc --noEmit

# Lint
{packageManager} run lint

# Build (if applicable)
{packageManager} run build

# Storybook build (if installed)
{packageManager} run build-storybook
```

All must pass with zero errors before declaring completion.

### 9.3 Completion Report

```
## Design Farmer — Completion Report

### System Overview
- Location: {systemPath}
- Components: {count} implemented
- Tokens: {count} primitive, {count} semantic, {count} component
- Themes: {light/dark/multi-brand}
- Tests: {count} total ({count} unit, {count} a11y, {count} snapshot)
- Storybook: {yes/no}

### Color System
- Color space: OKLCH
- Palettes: {count} hue palettes, 9 steps each
- Contrast: APCA validated, all pairs meet Lc 60+ threshold
- Gamut: sRGB safe with P3 enhancement where supported

### Reviewer Verdicts
- Critic: {PASS/FAIL} ({score}/10 average)
- Code Reviewer: {findings summary}
- Scientist: {data validation summary}
- Designer: {grade}
- Design Engineer: {APPROVED/APPROVED_WITH_CHANGES}

### Next Steps
See Phase 10 (App Integration) to wire the design system into your application.
```

---

## Phase 10: App Integration

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

### 10.1 Dependency Installation

Compatibility gate (MANDATORY):

- Next.js → `next-themes` or `custom`
- Astro → `astro-color-scheme` or `custom`
- Remix → `remix-themes` or `custom`
- SvelteKit → `mode-watcher` or `custom`
- Nuxt → `@nuxtjs/color-mode` or `custom`
- Plain React (Vite/CRA) → `custom` or `use-dark-mode`

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

### 10.2 Root Layout Integration

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

### 10.3 CSS Import Chain

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
2. Token definitions (primitives → semantics)
3. Theme files (light.css, dark.css)
4. Component styles
5. Application-specific overrides (existing app CSS)

### 10.4 Replace Hardcoded Values (optional, if user chose A)

Scan the user's existing codebase for hardcoded values that should use design tokens:

```
Scan the application source files (NOT the design system directory) for hardcoded
values that should be replaced with design system tokens:

1. Color values: hex (#xxx), rgb(), hsl(), oklch() → var(--surface-*), var(--text-*), etc.
2. Spacing values: arbitrary px/rem values → var(--spacing-*) or spacing scale classes
3. Font sizes: hardcoded px/rem → var(--font-size-*) or typography scale
4. Border radius: hardcoded values → var(--radius-*)

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

### 10.5 Integration Verification

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

### 10.6 Integration Completion Report

```
## App Integration Summary

### Changes Made
- Layout/root entry: {actual framework file path — added ThemeProvider + hydration-safe theming setup}
- CSS imports: {list of added imports with order}
- Dependencies: {list of added/updated packages}
- Token replacements: {count} hardcoded values → design tokens (if applicable)

### Verified
- [ ] App starts without errors
- [ ] TypeScript compilation passes
- [ ] Lint passes with zero suppressions
- [ ] Theme toggle works
- [ ] Design tokens are visible in rendered output
```

---

## Operational Notes

### Agent Delegation Strategy

Use the closest available specialist in your environment. Do not assume these labels map
to literal built-in agents; tooling names and delegation APIs vary by runtime.

If your environment exposes delegation through a call such as `Agent(prompt="...")`,
pass the reusable briefs in this document through that interface. Otherwise execute the
same briefs directly with the tools and specialists available in your runtime.

| Task | Preferred capability | Effort |
|------|----------------------|--------|
| Codebase scanning | Repository exploration specialist | Low |
| Pattern analysis | Design-system analysis specialist | Medium |
| Token implementation | Implementation specialist | Medium |
| Component implementation | Implementation specialist | Medium |
| Test writing | Test-focused specialist | Medium |
| Storybook setup | Documentation/setup specialist | Medium |
| Architecture review | Architecture reviewer | High |
| Critical review | Skeptical reviewer | High |
| Code review | Code reviewer | Medium |
| Design review | Visual/design reviewer | Medium |
| Documentation | Documentation specialist | Low |

### Escalation Rules

- Stop after 3 failed attempts at the same task and report to user.
- If a component requires a pattern not covered by the token system, add the token first.
- If OKLCH conversion produces an out-of-gamut color, fall back to maximum in-gamut chroma.
- If the user's existing codebase uses a fundamentally incompatible pattern, ask before overriding.

### OKLCH Quick Reference

```
Format: oklch(L C H / alpha)
L (Lightness): 0 (black) to 1 (white)
C (Chroma):    0 (gray) to ~0.4 (most vivid)
H (Hue):       0-360 degrees

Key hue ranges:
  0-30:    Red
  30-90:   Orange to Yellow
  90-150:  Yellow-Green to Green
  150-210: Green to Cyan
  210-270: Cyan to Blue
  270-330: Blue to Purple
  330-360: Purple to Red

Contrast rules (APCA):
  Light bg (L > 0.85): fg L <= 0.45
  Dark bg  (L < 0.25): fg L >= 0.75
  Normal text: Lc 60 (pass), Lc 75 (preferred)

Gamut safety:
  sRGB:      reduce C while keeping L and H
  Display P3: ~35% more chroma for greens/cyans, ~10% for blues
  Fallback:  @media (color-gamut: p3) { ... }

Browser support: Baseline 2023, 96%+ global coverage
```

### Token Naming Convention

```
Primitive:  {category}.{hue}.{step}         → color.blue.500
Semantic:   {role}.{variant}                → text.primary, surface.inverse
Component:  {component}.{part}.{state}      → button.background.hover
```

### Forbidden Patterns

- Hardcoded color values in component files (use semantic tokens).
- Direct primitive token usage in components (use semantic layer).
- HSL or hex as primary color format (convert to OKLCH).
- Adjusting chroma for contrast fixes (adjust lightness only).
- Unnamed or abbreviated token names (be explicit and descriptive).
- Inconsistent prop naming across similar components.
