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

**Empty file guard**: If DESIGN.md exists but is empty (0 bytes), treat it as not existing.

```bash
# Check for existing config.json with pipeline state
config_path="{directory_containing_DESIGN.md}/.design-farmer/config.json"
# Read completedPhases, createdAt from config.json if it exists
```

**Draft guard**: Read the first 5 lines of DESIGN.md (or all lines if the file has fewer than 5). If any of those lines contain `**DRAFT**`, it is an incomplete Phase 3 draft — do NOT offer Option A. Only offer B (continue from where you left off) and C (start from scratch).

If DESIGN.md exists but `config.json` does NOT exist at `{directory_containing_DESIGN.md}/.design-farmer/config.json`, treat as a partial re-entry — the design document exists but pipeline state was lost. Offer:
- A) Reconstruct config from DESIGN.md and jump to Phase 5
- B) Start fresh from Phase 1 (Discovery Interview)

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

1. **Read the `## Config` YAML block** from DESIGN.md (if present). If the `## Config` section is missing or malformed, fall back to preflight scan (steps 1–5) plus user prompts for critical fields — do not block. Parse it to reconstruct `DesignFarmerConfig`:
   - `packageManager`, `framework`, `isMonorepo`, `systemPath`, `designSystemPackage`
   - `componentScope`, `headlessLibrary`, `themeStrategy`, `themeLibrary`, `accessibilityLevel`
   - `targetPlatforms`, `designMaturity`, `maturityScore`

   **Conditional fields** (may be absent depending on user choices):
   - `brandColor`: read from Config if present; if missing and `colorDirection` is `'keep'`, leave unset (Phase 3 will extract it from the codebase); if missing and `colorDirection` is `'neutral'`, set to `null`
   - `themeLibrary`: read from Config if present; if missing and `themeStrategy` is `'light-only'`, set to `'none'`

2. **Fill gaps from preflight scan** (steps 1–5 above already ran):
   - `packageManager`: infer from lock file (bun.lock → bun, pnpm-lock.yaml → pnpm, etc.)
   - `framework`: infer from `package.json` dependencies
   - `isMonorepo`: infer from workspace files
   - `systemPath`: use the directory containing DESIGN.md
   - `designSystemPackage`: read from `{systemPath}/package.json` `"name"` field (e.g., `@acme/design-system`)

3. **If critical fields are still missing** (packageManager, framework, systemPath, isMonorepo, designSystemPackage, componentScope, themeStrategy), ask ONE AskUserQuestion with all missing fields at once — do not ask one-at-a-time for this recovery step.

   **Critical field validation guard**: If the user's response still doesn't provide one or more critical fields, emit **Status: BLOCKED** with message: 'Cannot reconstruct config without required fields: {missing list}. Recovery: restart Phase 0 with complete information.'

4. **Derive computed identifiers** from the parsed fields:
   - `createdAt`: ISO 8601 timestamp of when this config was reconstructed (e.g., `2026-04-08T12:34:56Z`)
   - `designSystemDir`: `basename(systemPath)` (e.g., `design-system`)
   - `productName`: strip `@scope/` prefix from `designSystemPackage`, then title-case (e.g., `Design System`)

5. **Persist** the reconstructed `DesignFarmerConfig` (including derived fields, `strategy` from the Config block if present, and `completedPhases: []`) to `{systemPath}/.design-farmer/config.json`. Also copy to `config.backup.json` in the same directory.

   **Read-after-write validation**: Read back config.json to verify the write succeeded. If the file is missing or invalid JSON, emit BLOCKED with recovery instructions.

6. **Validate critical fields** — after persisting config, verify that `designMaturity` is present. If missing, ask via AskUserQuestion:

   > Your DESIGN.md doesn't specify design maturity. This determines the implementation approach.
   >
   > Options:
   > - A) Greenfield — no existing design system, build from scratch
   > - B) Emerging — some patterns exist, extract and normalize them
   > - C) Mature — comprehensive design system exists, extract and document

   Set `designMaturity` and `maturityScore` (0 for greenfield, 5 for emerging, 8 for mature) from user's choice, then persist to both `config.json` and `config.backup.json`.

   Note: This is a preliminary user-estimated maturity. Phase 2 provides a formal maturity assessment that will override this value.

7. **Mark skipped phases** — set `skippedPhases: ["phase-1", "phase-2", "phase-3", "phase-4", "phase-4b", "phase-4.5"]` in config.json so Phase 1 re-entry detection knows these phases were intentionally bypassed. Update `config.backup.json`.

   Note: skippedPhases is marked only after all validations pass.

8. **Run a quick architecture scan** — read the existing `{systemPath}/` directory structure to detect:
   - **Styling approach**: Check for `tailwind.config.*` (Tailwind), `*.module.css` / `*.module.scss` (CSS Modules), or plain CSS/SCSS files (vanilla CSS)
   - **Token directory layout**: Look for `tokens/`, `themes/`, `styles/`, or `src/tokens/` directories
   - **Component directory structure**: Check `src/primitives/`, `src/components/`, or similar
   - **Build tooling**: Detect Style Dictionary config (`config.json` with `$value` tokens), PostCSS, or other build tools

   Populate the following config fields from scan results: `stylingApproach` (if not already set), and verify `systemPath` directory exists.

   This scan substitutes for Phase 4 output — downstream phases (5–11) use these fields the same way they would if Phase 4 had run normally.

9. **Mark phase complete** — ensure `completedPhases` exists in config.json (initialize as `[]` if undefined). If `'phase-0'` is already present in the array, skip the append (idempotent). Otherwise, append `'phase-0'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Also update `config.backup.json`.

10. **Jump directly to Phase 5.** Do not run Phases 1–4. Phase 5 will run its own Config Validation Protocol at entry to verify all required fields are present.

If user chose **B**:
- **If DRAFT**: Load the draft's `## Config` YAML to reconstruct `DesignFarmerConfig`. If `designMaturity` is missing from the parsed config, ask via AskUserQuestion:

  > Your draft DESIGN.md doesn't specify design maturity. This determines the visual preview behavior.
  >
  > Options:
  > - A) Greenfield — no existing design system, build from scratch
  > - B) Emerging — some patterns exist, extract and normalize them
  > - C) Mature — comprehensive design system exists, extract and document

  Set `designMaturity` and `maturityScore` (0 for greenfield, 5 for emerging, 8 for mature) from user's choice.

  Note: This is a preliminary user-estimated maturity. Phase 2 provides a formal maturity assessment that will override this value.

  Derive `systemPath` from the draft's location (the directory containing the draft DESIGN.md). If the draft references a specific project directory, use that; otherwise, use the current working directory.

  Derive additional fields from the preflight scan results (Steps 1–4 above) that the draft may not specify:
  - `packageManager`: from Step 1 (lockfile detection)
  - `framework`: from Step 3 (framework detection)
  - `isMonorepo`: from Step 2 (monorepo detection)

  Compute derived identifiers:
  - `designSystemDir` = `path.basename(systemPath)` — the directory name
  - `designSystemPackage` = the `name` field from `{systemPath}/package.json`, if it exists; otherwise fall back to `designSystemDir`
  - `productName` = human-readable name derived from `designSystemPackage` (e.g., `@acme/design-system` → "Acme Design System")

  Run **Config Validation Protocol** (see `operational-notes.md`) on the reconstructed config before jumping to Phase 3.5. Verify required fields (`designMaturity`, `componentScope`, `themeStrategy`, `systemPath`) are present and valid. If validation fails, emit **Status: BLOCKED** with recovery options: re-run Phase 1 or manually correct the config.

  Persist the reconstructed config (including `designMaturity`, `maturityScore`, all parsed fields, and `completedPhases` — preserve existing array if present, otherwise initialize as `[]`) to `{systemPath}/.design-farmer/config.json`. Also copy to `config.backup.json`.

  Ensure `completedPhases` exists in config.json (initialize as `[]` if undefined). If `'phase-0'` is already present in the array, skip the append (idempotent). Otherwise, append `'phase-0'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Also update `config.backup.json`. Then **resume from Phase 3.5** (extraction is already done in the draft).
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

Create `{systemPath}/.design-farmer/config.json` (directory and file) if it doesn't exist. Set `systemPath` to the directory where the existing design system was detected (from preflight scan steps 2–3). Initialize with `{"completedPhases": []}`. Also copy to `config.backup.json`.

If user chose **A**: continue to Phase 1 (Discovery Interview). Record `strategy: "extend"` in config.json.
If user chose **B**: continue to Phase 1 (Discovery Interview). Record `strategy: "migrate"` in config.json.
If user chose **C**: continue to Phase 1 (Discovery Interview). Record `strategy: "greenfield"` in config.json.

Ensure `completedPhases` exists in config.json (initialize as `[]` if undefined). If `'phase-0'` is already present in the array, skip the append (idempotent). Otherwise, append `'phase-0'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Also update `config.backup.json`.

**Status: DONE** — Pre-flight complete. Proceed to Phase 1: Discovery Interview.

