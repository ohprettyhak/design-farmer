# Phase 2: Repository Analysis

Perform deep analysis of the codebase. Token budget is not a concern — thoroughness matters.

## 2.1 Project Structure Detection

```bash
# Monorepo detection
ls pnpm-workspace.yaml turbo.json nx.json lerna.json 2>/dev/null

# Package manager detection
if [ -f "bun.lock" ] || [ -f "bun.lockb" ]; then echo "bun"
elif [ -f "pnpm-lock.yaml" ]; then echo "pnpm"
elif [ -f "yarn.lock" ]; then echo "yarn"
elif [ -f "package-lock.json" ]; then echo "npm"
fi

# Framework detection
grep -rl "react\|next\|vue\|nuxt\|svelte\|astro\|solid\|angular" --include="package.json" . 2>/dev/null

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
grep -rl '"vitest"\|"jest"\|"@testing-library"\|"playwright"\|"cypress"' --include="package.json" . 2>/dev/null
ls vitest.config.* jest.config.* playwright.config.* cypress.config.* 2>/dev/null

# Lint/format tooling
ls .eslintrc* eslint.config.* .prettierrc* biome.json oxlint* 2>/dev/null
```

## 2.1.1 Design Maturity Assessment

After scanning, classify the project into one of three maturity levels:

```
GREENFIELD (score 0-2):
  - No design tokens or CSS custom properties
  - Colors/spacing are hardcoded throughout
  - No consistent component patterns
  - Action: Establish initial sizing/styling defaults during the preview and architecture phases, then capture them in DESIGN.md

EMERGING (score 3-5):
  - Some CSS variables or theme config exists
  - Partial component library (approximately 5–15 components — use judgment for borderline cases)
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
  [ ] Component props follow consistent patterns (same naming, same styling approach across ≥80% of components)
  [ ] Accessibility attributes present on interactive components (aria-label, role, tabIndex on interactive elements)
  [ ] Tests exist for UI components
  [ ] Dark mode or theming mechanism exists
  [ ] Typography uses a defined scale
  [ ] Spacing values follow a consistent base unit
  [ ] Documentation exists for component usage
```

Report the maturity level and score in the analysis report. This determines which
implementation path to follow in subsequent phases:

- **greenfield path** (score 0–2): Build from best practices — no existing patterns to preserve
- **emerging path** (score 3–5): Extract and extend — standardize existing patterns, fill gaps
- **mature path** (score 6+): Audit and migrate — preserve existing APIs, migrate to OKLCH, add missing layers

**Borderline scores (exactly 2, 3, or 5):** ask the user via AskUserQuestion which level better reflects their project's maturity:
> Your project scored {score}/10, which is on the boundary between {lower} and {upper} maturity levels.
>
> Options:
> - A) {lower level} — my project needs more structure
> - B) {upper level} — my project has enough patterns to build on

Where {lower}/{upper} are the two adjacent maturity levels. Use the user's choice to set designMaturity.

**Maturity impact on downstream phases:**
- Phase 3: GREENFIELD skips extraction (generates defaults); EMERGING extracts with gap-filling; MATURE runs full authoritative extraction
- Phase 3.5: GREENFIELD mandatory preview; EMERGING recommended opt-in; MATURE default skip
- Phase 5: MATURE preserves existing token names for backward compatibility; GREENFIELD/EMERGING generate new tokens
- Phase 6: GREENFIELD builds from headless primitives; EMERGING standardizes existing components; MATURE wraps existing component APIs

## 2.2 Existing Pattern Extraction

Use the following analysis brief by default when your environment supports specialized delegation; otherwise perform the same scan directly using the bash commands from sections 2.3 and the patterns below:

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

## 2.3 Component Inventory

```bash
# Find all component-like files
find . -path "*/components/*" \( -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" \) | head -50

# Extract component names and prop interfaces
grep -r "export.*function\|export.*const\|export default" --include="*.tsx" --include="*.vue" -l | head -30

# Find styled-components, CSS modules, Tailwind usage
grep -rl "styled\.\|css`\|module\.css\|className=" --include="*.tsx" --include="*.ts" | head -20
grep -rl "tailwind\|@apply\|tw`" --include="*.css" --include="*.tsx" --include="*.ts" --include="*.config.*" | head -10

# Find zero-runtime CSS-in-JS (vanilla-extract, Panda CSS, Linaria)
find . -name "*.css.ts" 2>/dev/null | head -10                          # vanilla-extract
grep -rl "@vanilla-extract/css" --include="package.json" . 2>/dev/null | head -10  # vanilla-extract dep
ls panda.config.ts panda.config.js 2>/dev/null                          # Panda CSS
find . -type d -name "styled-system" 2>/dev/null | head -5              # Panda CSS output dir
grep -rl "from 'linaria'\|from '@linaria'" --include="*.ts" --include="*.tsx" | head -5  # Linaria
```

## 2.4 Analysis Report

Produce a structured report:

```markdown
## Repository Analysis Report

### Tech Stack
- Runtime: {Node.js version}
- Framework: {React 19 / Next.js 15 / etc.}
- Language: {TypeScript 5.x / JavaScript}
- Package Manager: {bun / pnpm / npm / yarn}
- Build Tool: {Vite / webpack / Turbopack / esbuild / Rollup}
- Styling: {CSS Modules / Tailwind v{version} / styled-components / vanilla-extract / Panda CSS / Linaria / vanilla CSS}
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

After completing the analysis report, update `DesignFarmerConfig` with the maturity assessment result:

```bash
# Update {systemPath}/.design-farmer/config.json with:
# "designMaturity": "greenfield" | "emerging" | "mature"
# "maturityScore": <N>   (0–10 from the scoring criteria above)
# Also update config.backup.json with the same values.
```

All downstream phases branch on `DesignFarmerConfig.designMaturity` — this update is required before proceeding.

Before emitting status, ensure `completedPhases` exists in config.json (initialize as `[]` if undefined). If `'phase-2'` is already present in the array, skip the append (idempotent). Otherwise, append `'phase-2'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Also update `config.backup.json`.

**Status: DONE** — Repository analysis complete. Design maturity assessed and written to config. Proceed to Phase 3: Design Pattern Extraction.
