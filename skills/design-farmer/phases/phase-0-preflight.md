# Phase 0: Pre-flight

Run these checks before any other work:

```bash
# 1. Detect project root markers
ls package.json pnpm-workspace.yaml lerna.json turbo.json nx.json bun.lock bun.lockb yarn.lock 2>/dev/null

# 2. Check for existing design system artifacts
find . -type f \( -name "tokens.*" -o -name "theme.*" -o -name "design-tokens.*" \) 2>/dev/null | head -20
find . -type d \( -name "design-system" -o -name "design-tokens" -o -name "primitives" -o -name "ui" \) 2>/dev/null | head -20

# 3. Check for existing component libraries
find . -path "*/components/*" \( -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" \) 2>/dev/null | head -30

# 4. Check for Storybook
ls .storybook/main.* 2>/dev/null

# 5. Detect existing color definitions
grep -r "oklch\|hsl\|rgb\|#[0-9a-fA-F]\{3,8\}" --include="*.css" --include="*.scss" --include="*.ts" --include="*.tsx" -l 2>/dev/null | head -20

# 6. Check for existing DESIGN.md (Design Farmer re-entry signal)
find . -maxdepth 4 -name "DESIGN.md" 2>/dev/null | grep -v node_modules | head -5
```

If a `DESIGN.md` file is found, check for existing pipeline state:

```bash
# Check for existing config.json with pipeline state
config_path="{directory_containing_DESIGN.md}/.design-farmer/config.json"
# Read completedPhases, createdAt from config.json if it exists
```

**Draft guard**: Read the first 5 lines of DESIGN.md. If the file contains `**DRAFT**` in its header, it is an incomplete Phase 3 draft — do NOT offer Option A. Only offer B (continue from where you left off) and C (start from scratch).

Then ask via AskUserQuestion **before anything else**:

> A `DESIGN.md` was found at `{path}`.
> {If DRAFT marker found: "This is a **partial draft** from Phase 3 (extraction only — architecture and theming are not yet complete)."}
> {Otherwise: "This file describes your design system's visual direction, tokens, and component decisions."}
>
> {If config.json exists with completedPhases and createdAt, show:}
> **Pipeline state:** Created `{createdAt}`. Completed phases: `{completedPhases}` (last completed: Phase {last}).
> {If lastReviewScore exists:} Last review score: `{lastReviewScore}/10` on `{lastReviewDate}`.
>
> **How should I proceed?**
>
> {If DRAFT: show only B and C. If finalized: show A, B, and C.}
> Options:
> - A) **Use it as-is** — load DESIGN.md as the design source of truth and jump directly to Phase 5 (Token Implementation) {omit if DRAFT}
> - B) **Update it** — {If DRAFT: "resume from Phase 3.5 (extraction is done, continue with preview and architecture)"} {If finalized: "run fresh analysis (Phases 1–4), then update DESIGN.md with any changes"}
> - C) **Ignore it** — start from scratch (DESIGN.md will be overwritten in Phase 4.5)

**→ STOP — wait for user response before continuing.**

If user chose **A**:

1. **Read the `## Config` YAML block** from DESIGN.md (if present). Parse it to reconstruct `DesignFarmerConfig`:
   - `packageManager`, `framework`, `isMonorepo`, `systemPath`, `designSystemPackage`
   - `componentScope`, `headlessLibrary`, `themeStrategy`, `themeLibrary`, `accessibilityLevel`
   - `targetPlatforms`, `designMaturity`, `maturityScore`

2. **Fill gaps from preflight scan** (steps 1–5 above already ran):
   - `packageManager`: infer from lock file (bun.lock → bun, pnpm-lock.yaml → pnpm, etc.)
   - `framework`: infer from `package.json` dependencies
   - `isMonorepo`: infer from workspace files
   - `systemPath`: use the directory containing DESIGN.md

3. **If critical fields are still missing** (packageManager, framework, systemPath), ask ONE AskUserQuestion with all missing fields at once — do not ask one-at-a-time for this recovery step.

4. **Derive computed identifiers** from the parsed fields:
   - `designSystemDir`: `basename(systemPath)` (e.g., `design-system`)
   - `designSystemPackage`: read from `{systemPath}/package.json` `"name"` field (e.g., `@acme/design-system`)
   - `productName`: strip `@scope/` prefix from `designSystemPackage`, then title-case (e.g., `Design System`)

5. **Persist** the reconstructed `DesignFarmerConfig` (including derived fields) to `{systemPath}/.design-farmer/config.json`.

6. **Run a quick architecture scan** — read the existing `{systemPath}/` directory structure to determine the styling strategy (Tailwind/CSS Modules/vanilla CSS) and token directory layout. This substitutes for Phase 4 when jumping directly to Phase 5.

7. **Jump directly to Phase 5.** Do not run Phases 1–4.

If user chose **B** or **C**: continue to Phase 1 (Discovery Interview) as normal.

---

If an existing design system is detected (but no DESIGN.md), report findings and ask:
> "An existing design system was found at `{path}`. Should I extend it, migrate it to the Design Farmer standard, or start fresh alongside it?"

Report the pre-flight summary (monorepo/single-repo, framework detected, existing components/tokens found, package manager).

**Status: DONE** — Pre-flight complete. Proceed to Phase 1: Discovery Interview.
