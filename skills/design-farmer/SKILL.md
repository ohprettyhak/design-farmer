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

Delegate to an `explore` agent at haiku tier:

```
Agent(prompt="
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
")
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

```typescript
// theme-provider.tsx — thin wrapper around the chosen library
// Example for Next.js with next-themes:

// import { ThemeProvider as NextThemesProvider } from 'next-themes'
//
// export function ThemeProvider({ children }: { children: React.ReactNode }) {
//   return (
//     <NextThemesProvider
//       attribute="data-theme"          // matches our CSS selectors
//       defaultTheme="system"           // respect OS preference
//       enableSystem                    // listen for OS changes
//       disableTransitionOnChange       // prevent FOUC during switch
//     >
//       {children}
//     </NextThemesProvider>
//   )
// }
//
// Re-export useTheme from the library for consumer convenience:
// export { useTheme } from 'next-themes'
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

### 4.8 Styling Approach Decision

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

Delegate to executor agent. Implement tokens in this order:

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

Delegate implementation:
```
Agent(prompt="
Implement the token system at {systemPath}/src/tokens/ following the architecture
defined in Phase 4. Use OKLCH values throughout. Generate light.css and dark.css
theme files. Include TypeScript type exports for all tokens.
Config: {serialized DesignFarmerConfig}
Extracted patterns: {serialized extraction results}
")
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
   Agent(prompt="
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
   ")
   ```

3. **Test creation** — Write tests alongside the component:
   ```
   Agent(prompt="
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
   ")
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
> regressions that unit tests miss. The latest version (8.x) has significantly improved
> performance and supports CSS custom properties natively.
>
> Options:
> - A) Yes, full setup — Install Storybook 8.x with stories for all components, accessibility addon, dark mode support, and auto-generated docs
> - B) Yes, minimal — Install Storybook with basic stories only
> - C) No, skip Storybook — Rely on tests and code documentation only

**STOP. Do NOT proceed until user responds.**

If user chose A or B, delegate:

```
Agent(prompt="
Install and configure Storybook 8.x for the design system at {systemPath}:

1. Install: npx storybook@latest init (or bun equivalent)
2. Configure addons:
   - @storybook/addon-a11y (accessibility checking)
   - @storybook/addon-themes (dark mode toggle)
   - @storybook/addon-docs (auto documentation)
3. Create stories for every implemented component:
   - Default story showing all variants
   - Interactive story with controls for all props
   - Accessibility story with aria attribute demonstrations
   - Theme story showing light/dark appearance
4. Configure .storybook/preview.ts:
   - Load theme CSS files
   - Set up theme decorator for dark mode toggle
   - Configure viewport presets
")
```

---

## Phase 8: Multi-Reviewer Verification

Five specialized reviewers evaluate the design system. Each role is defined inline — no external
plugins or agent frameworks required. Run independent reviewers in parallel via the Agent tool.

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
Agent(prompt="
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
")
```

**STOP. Read the critic's output. If CRITICAL findings exist, fix them before running other reviewers.**

---

### 8.2 Code Quality Reviewer

**Role:** You are a staff frontend engineer obsessed with code correctness and
maintainability. You've seen design systems rot from sloppy imports, leaky abstractions,
and `any` types. You review like it's a PR that will be consumed by every engineer in
the company.

```
Agent(prompt="
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
")
```

---

### 8.3 Token & Color Scientist

**Role:** You are a color science and design token specialist. You validate with
data, not opinions. You run computations on every color value, measure every spacing
ratio, and count every token reference. If a claim can be quantified, you quantify it.

```
Agent(prompt="
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
")
```

---

### 8.4 Visual Design Reviewer

**Role:** You are a senior product designer who thinks like a designer, not a QA
engineer. You evaluate whether things feel right and look intentional. You care about
visual hierarchy, rhythm, proportion, and the emotional tone of the system. You flag
generic, AI-sloppy, or inconsistent design choices.

```
Agent(prompt="
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

### 4. Spacing & Rhythm (weight: 15%)
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

### 7. Dark Mode Quality (weight: 5%)
- Dark theme has its own personality (not just inverted lightness)
- Contrast is maintained without eye strain
- Colored elements adapt naturally (not washed out or neon)

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
")
```

---

### 8.5 Design Systems Engineer

**Role:** You are a principal engineer who specializes in design system infrastructure.
You evaluate the system's ability to scale, perform, and provide a great developer
experience. You think in terms of build pipelines, bundle sizes, API surfaces, and
the daily life of the consuming developer.

```
Agent(prompt="
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
")
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

### 8.5.1 Setup

```bash
# Start the dev server or Storybook in background
{packageManager} run dev &          # or: {packageManager} run storybook
# Wait for server to be ready
sleep 5
```

If no dev server is available (e.g., library-only package without a preview app),
use Storybook stories as the evaluation target. If neither exists, skip this phase
and note it in the completion report.

### 8.5.2 Visual Design Audit (10 Categories)

Evaluate each rendered component against these 10 categories. For each finding,
capture a screenshot as evidence.

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

4. Spacing & Rhythm              15%     Component internal spacing is balanced
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

7. Dark Mode Quality              5%     Dark theme has appropriate contrast
                                         Colors don't look washed out or neon
                                         Shadows/elevation adapt (lighter in dark mode)
                                         No pure white text on dark backgrounds

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

### 8.5.3 Scoring Rubric

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

### 8.5.4 Finding Format

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

### 8.5.5 Fix Loop

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

### 8.5.6 Risk Regulation

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

### 8.5.7 Design Review Triage

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
1. Import the design system in your application
2. Run the token build to generate CSS custom properties
3. Apply the ThemeProvider at your app root
4. Start consuming components from the public API
```

---

## Operational Notes

### Agent Delegation Strategy

| Task | Agent | Tier |
|------|-------|------|
| Codebase scanning | `explore` | haiku |
| Pattern analysis | `scientist` | sonnet |
| Token implementation | `executor` | sonnet |
| Component implementation | `executor` | sonnet |
| Test writing | `test-engineer` | sonnet |
| Storybook setup | `executor` | sonnet |
| Architecture review | `architect` | opus |
| Critical review | `critic` | opus |
| Code review | `code-reviewer` | sonnet |
| Design review | `designer` | sonnet |
| Documentation | `writer` | haiku |

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
