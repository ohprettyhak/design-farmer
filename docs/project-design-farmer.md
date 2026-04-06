# design-farmer

## Summary

Design Farmer is an AI coding agent skill that automates the construction of production-grade design systems. It guides agents through a 16-phase pipeline — from codebase analysis and design pattern extraction to OKLCH-native token implementation, accessible component building, multi-reviewer verification, and release handoff.

## Evidence

- AI-driven "vibe coding" produces inconsistent UI when agents lack a structured design system reference.
- Existing design system tooling assumes human-driven workflows; no equivalent exists for agent-first construction.
- The skill is distributed as a portable bundle across 5 AI tools (Claude Code, Codex CLI, Amp, Gemini CLI, OpenCode).

## Current Gap

Before this project, agents had no repeatable workflow for:
- Detecting existing design patterns and maturity level in a codebase.
- Building OKLCH-native token hierarchies with APCA contrast validation.
- Generating accessible components with headless library integration.
- Producing a persistent design source of truth (`DESIGN.md`) for re-entry.

## Proposed Scope

### In Scope

- 16-phase pipeline (Phase 0 through Phase 11, including sub-phases 3.5, 4b, 4.5, 8.5).
- Router (`SKILL.md`) with frontmatter, phase index, cross-phase contracts, fallback registry.
- Phase instruction files under `phases/`.
- Companion documentation (`PHASE-INDEX.md`, `QUALITY-GATES.md`, `MAINTENANCE.md`, `EXAMPLES-GALLERY.md`).
- Greenfield reference example (`examples/DESIGN.md` — Nova UI).
- Automated installer (`install.sh`) with atomic bundle deployment.
- Structural validation script (`scripts/validate-skill-md.sh`).
- Semantic consistency test suite (`tests/test-semantic-consistency.sh`).
- Exhaustive simulation test suite (`tests/test-exhaustive-simulation.sh`).
- CI pipeline (GitHub Actions: structural validation + install smoke tests).
- Version check utility (`bin/version-check`).

### Out of Scope

- Runtime execution engine (the skill is consumed by external AI tools, not executed standalone).
- Figma integration or visual design tool plugins.
- npm package publishing (the skill is distributed via installer script, not npm).
- Language support beyond the frameworks listed in the phase files (React, Vue, Svelte, Astro, Next.js, Nuxt, SvelteKit, Remix).

## Architecture

### Bundle Structure

```
skills/design-farmer/
  SKILL.md                          # Router: frontmatter, phase index, contracts
  bin/version-check                 # Version management utility
  phases/
    phase-0-preflight.md            # Topology detection, DESIGN.md re-entry
    phase-1-discovery.md            # One-at-a-time interview, DesignFarmerConfig
    phase-2-repo-analysis.md        # Design maturity assessment (greenfield/emerging/mature)
    phase-3-pattern-extraction.md   # OKLCH conversion, palette generation
    phase-3.5-visual-preview.md     # HTML preview, user approval gate
    phase-4-architecture.md         # Token hierarchy, directory structure, build pipeline
    phase-4b-theming.md             # Theme system, dark mode, styling approach
    phase-4.5-design-source-of-truth.md  # DESIGN.md generation
    phase-5-tokens.md               # Token implementation, platform branching
    phase-6-components.md           # Component library, framework guardrails
    phase-7-storybook.md            # Storybook integration (optional)
    phase-8-review.md               # 5-reviewer verification panel
    phase-8.5-design-review.md      # Live visual QA
    phase-9-documentation.md        # Docs generation, final verification
    phase-10-integration.md         # App integration, framework decision matrix
    phase-11-readiness-handoff.md   # Release readiness, cleanup
    operational-notes.md            # Delegation, OKLCH reference, Fix Loop Protocol
  docs/
    PHASE-INDEX.md                  # Compact phase map for maintainers
    QUALITY-GATES.md                # Verification and release criteria
    MAINTENANCE.md                  # Anti-drift and update workflow
    EXAMPLES-GALLERY.md             # Scenario-based outcomes
  examples/
    DESIGN.md                       # Nova UI greenfield reference
  tests/
    run-all.sh                      # Master test runner (3 suites)
    test-semantic-consistency.sh    # 72 semantic checks
    test-exhaustive-simulation.sh   # 169 checks, 26 dimensions, 1152 paths
```

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| OKLCH as primary color space | Perceptual uniformity, gamut-aware palette generation, natural dark mode derivation via lightness inversion |
| APCA over WCAG 2.x ratios (with dual-check) | Better perceptual accuracy; legal compliance maintained via parallel WCAG 2.x check |
| Three-tier token hierarchy (primitive/semantic/component) | Enables theming without component API changes; semantic-token-only rule prevents coupling |
| Phase-file decomposition (not monolithic SKILL.md) | Reduces token consumption per phase; agents load only the current phase |
| DESIGN.md as persistent source of truth | Enables re-entry (Phase 0 → Phase 5 shortcut) and cross-session design continuity |
| Fix Loop Protocol (5 max attempts) | Self-healing without external plugins; escalates to BLOCKED on exhaustion |
| Fallback/degradation registry per phase | Pipeline never silently fails; every phase has a documented fallback path |

### Data Flow

```
Phase 0 (Preflight) ──→ detect topology, check DESIGN.md
    │
    ├─ DESIGN.md found (path A) ──→ parse Config YAML ──→ Phase 5 (skip 1-4)
    │
    └─ No DESIGN.md ──→ Phase 1 (Discovery Interview)
                             │
                             ▼
                      DesignFarmerConfig ──→ persisted to config.json
                             │
                             ▼
                      Phase 2 ──→ designMaturity (greenfield/emerging/mature)
                             │
                             ▼
                      Phase 3 ──→ OKLCH palettes, typography, spacing
                             │
                             ▼
                      Phase 3.5 ──→ visual preview (user approval gate)
                             │
                             ▼
                      Phase 4 + 4b ──→ architecture + theming
                             │
                             ▼
                      Phase 4.5 ──→ DESIGN.md generated
                             │
                             ▼
                      Phase 5 ──→ tokens (platform branching)
                             │
                             ▼
                      Phase 6 ──→ components (framework guardrail)
                             │
                             ▼
                      Phase 7 ──→ Storybook (optional)
                             │
                             ▼
                      Phase 8 + 8.5 ──→ review + visual QA
                             │
                             ▼
                      Phase 9 ──→ documentation
                             │
                             ▼
                      Phase 10 ──→ app integration (optional)
                             │
                             ▼
                      Phase 11 ──→ readiness handoff + cleanup
```

## Acceptance Criteria

- [x] All 16 phase files exist and are referenced by the router.
- [x] Cross-phase contracts are documented and enforced by validation scripts.
- [x] Structural validation (`scripts/validate-skill-md.sh`) passes with zero errors.
- [x] Semantic consistency tests (72 checks) pass with zero failures.
- [x] Exhaustive simulation (169 checks, 1152 paths) passes with zero failures.
- [x] Installer deploys bundle atomically across 5 AI tools.
- [x] CI pipeline runs on every PR and push to `main`.
- [x] DESIGN.md Config fields survive Phase 4.5 → Phase 0 round-trip (13 fields).
- [x] All conditional skip/jump paths (6 paths) are valid and tested.
- [x] Fallback/degradation registry covers all implementation phases (14 entries).

## Dependencies

- External AI tools (Claude Code, Codex CLI, Amp, Gemini CLI, OpenCode) for skill consumption.
- GitHub Actions for CI.
- `curl` for installer distribution.
- `bash 3.2+` compatibility (macOS default).

## Risks

| Risk | Mitigation |
|------|------------|
| Phase instruction drift across files | Anti-drift checklist in `MAINTENANCE.md`; structural validation script enforces alignment |
| Agent runtime differences across tools | Fallback/degradation registry ensures graceful handling; `Agent(prompt="...")` compatibility note |
| OKLCH browser support gaps | Baseline 2023 (96%+ global); P3 gamut enhancement behind `@media (color-gamut: p3)` |
| APCA not yet W3C standard | Dual-check: APCA + WCAG 2.x 4.5:1 for legal compliance |

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-04-06 | Hak Lee | Initial draft |
