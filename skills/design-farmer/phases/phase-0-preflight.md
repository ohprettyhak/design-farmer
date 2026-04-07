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

5. **Persist** the reconstructed `DesignFarmerConfig` (including derived fields) to `{systemPath}/.design-farmer/config.json`. Also copy to `config.backup.json` in the same directory.

6. **Validate critical fields** — after persisting config, verify that `designMaturity` is present. If missing, ask via AskUserQuestion:

   > Your DESIGN.md doesn't specify design maturity. This determines the implementation approach.
   >
   > Options:
   > - A) Greenfield — no existing design system, build from scratch
   > - B) Emerging — some patterns exist, extract and normalize them
   > - C) Mature — comprehensive design system exists, extract and document

   Set `designMaturity` and `maturityScore` (0 for greenfield, 5 for emerging, 8 for mature) from user's choice, then persist to both `config.json` and `config.backup.json`.

7. **Run a quick architecture scan** — read the existing `{systemPath}/` directory structure to determine the styling strategy (Tailwind/CSS Modules/vanilla CSS) and token directory layout. This substitutes for Phase 4 when jumping directly to Phase 5.

8. **Jump directly to Phase 5.** Do not run Phases 1–4.

If user chose **B**:
- **If DRAFT**: Load the draft's `## Config` YAML to reconstruct `DesignFarmerConfig`, persist to config.json (and config.backup.json), then **resume from Phase 3.5** (extraction is already done in the draft).
- **If finalized**: continue to Phase 1 (Discovery Interview) as normal — run fresh Phases 1–4.

If user chose **C**: continue to Phase 1 (Discovery Interview) as normal.

---

If an existing design system is detected (but no DESIGN.md), report the pre-flight summary (monorepo/single-repo, framework detected, existing components/tokens found, package manager), then ask via AskUserQuestion:

> An existing design system was found at `{path}`.
>
> How should I proceed?
>
> - A) **Extend** — build the Design Farmer standard design system on top of your existing components (preserve existing code)
> - B) **Migrate** — convert existing components to Design Farmer standards (OKLCH tokens, semantic layer)
> - C) **Start fresh** — build a new design system alongside existing components

**→ STOP — wait for user response before continuing.**

If user chose **A**: continue to Phase 1 (Discovery Interview). Record `strategy: "extend"` in config.json.
If user chose **B**: continue to Phase 1 (Discovery Interview). Record `strategy: "migrate"` in config.json.
If user chose **C**: continue to Phase 1 (Discovery Interview). Record `strategy: "greenfield"` in config.json.

**Status: DONE** — Pre-flight complete. Proceed to Phase 1: Discovery Interview.
