# Design Farmer Phase Index

This index provides a compact map of the Design Farmer router + phase bundle for maintainers.

## Canonical Source

- Canonical runtime entrypoint: `../SKILL.md` (router)
- Canonical phase instructions: `../phases/*.md`
- This file is a maintenance companion, not an execution source.

## Phase Map

1. **Phase 0: Pre-flight**
   - Detect project topology, frameworks, package manager, existing design system artifacts.
   - If `DESIGN.md` exists, import it as context and pre-fill discovery defaults (do not bypass critical Phase 1 decisions).
   - Distinguish `internal-canonical` vs `external-context` DESIGN.md sources; only unreadable files are treated as corrupted.
2. **Phase 1: Discovery Interview**
   - Ask one question at a time, block on user response, build `DesignFarmerConfig`.
3. **Phase 2: Repository Analysis**
   - Assess design maturity, inventory components, identify style/token patterns.
4. **Phase 3: Design Pattern Extraction & OKLCH Conversion**
   - Convert and normalize color systems, generate scales, validate contrast.
   - Generate early DESIGN.md draft with extraction results for context resilience.
5. **Phase 3.5: Visual Preview**
   - Maturity-conditional preview opt-in: mandatory for GREENFIELD, recommended for EMERGING, default skip for MATURE.
   - Generate self-contained HTML preview at `.design-farmer/design-preview.html`.
   - Color palette swatches, typography specimens, spacing scale, sample components.
   - Theme toggle for light/dark comparison.
   - If preview skipped, text-only approval gate via opt-in gate (3.5.0) — not the error-state fallback (3.5.3).
   - User approval gate before Phase 4 begins (always, regardless of preview mode).

6. **Phase 4: Architecture Design**
   - Define token hierarchy, directory structure, build pipeline, and CSS layering.
7. **Phase 4b: Theme & Styling**
   - Define theme system, provider implementation, dark mode checklist, and styling approach.
8. **Phase 4.5: Design Source of Truth (DESIGN.md)**
   - Generate DESIGN.md capturing all design decisions as a persistent, machine-readable reference.
9. **Phase 5: Token Implementation**
   - Implement primitive + semantic tokens and utilities with tests.
10. **Phase 6: Component Implementation**
    - Build component library using selected path (headless/custom) with accessibility requirements.
11. **Phase 7: Storybook Integration**
    - Document components and states visually (optional for light mode-only scenarios as configured).
12. **Phase 8: Multi-Reviewer Verification**
    - Execute multi-angle quality review and aggregate risk.
13. **Phase 8.5: Design Review (Live Visual QA)**
    - Detect project-declared browser tooling (for example, an existing Playwright setup) or fall back to manual verification.
    - Perform visual QA loop with strict triage and risk thresholds.
    - Responsive viewport testing at mobile, tablet, and desktop breakpoints.
14. **Phase 9: Documentation & Completion**
    - Generate docs, run final verification commands, emit completion report.
15. **Phase 10: App Integration**
    - Wire design system into application layout, imports, dependencies.
16. **Phase 11: Release Readiness & Handoff**
    - Final verification (tests, typecheck, lint, build).
    - Readiness checklist for artifacts, docs, and degradations.
    - Handoff summary for the next publication step.
    - Readiness completion report.

## Cross-Phase Contracts

- Completion statuses are mandatory: `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, `NEEDS_CONTEXT`.
- User-question gating in Discovery must remain one-at-a-time.
- Final completion requires explicit verification evidence.
- Pipeline state (`completedPhases`, `createdAt`, `lastReviewScore`, `lastReviewDate`, `generatePreview`) is tracked in `config.json` and displayed during Phase 0 re-entry.
- Existing `DESIGN.md` is context input, not an auto-skip trigger for Phases 1–4.5; discovery gates remain required.
- Readable third-party DESIGN.md files are `external-context` inputs, not corruption events.
- Early DESIGN.md draft (Phase 3) bridges the extraction→source-of-truth context gap.
- Preview file lives at `.design-farmer/design-preview.html` (not project root).

## Section vs Phase Numbering

Internal sections within a phase file use `{phase}.{N}` numbering scoped to that file.
A section number may coincide with a sub-phase file number — they are distinguished by
file context since each phase file is loaded independently.

| Sub-phase file | Overlap | Resolution |
|----------------|---------|------------|
| Phase 3.5 (`phase-3.5-visual-preview.md`) | Eliminated | Section 3.5 (Gamut Safety) absorbed into section 3.2 |
| Phase 8.5 (`phase-8.5-design-review.md`) | Accepted | Section 8.5 (Design Systems Engineer) is a distinct reviewer role that cannot be merged; file context distinguishes it from Phase 8.5 |

When adding new sections or sub-phases, prefer structural merging to eliminate overlaps.
Accept shared numbers only when the content cannot be merged without losing clarity.

## Maintenance Rule

If phase boundaries or criteria in `SKILL.md` change, update this file in the same PR.
