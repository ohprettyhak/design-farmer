---
name: design-farmer
version: 2.1.0
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

## Bundle Integrity Gate

This skill is distributed as a **bundle**: the router `SKILL.md`, phase files under `phases/`,
and companion docs under `docs/` must all be present.

Before starting work:

1. Read `phases/operational-notes.md`.
2. Verify the phase file for the current step exists before proceeding.
3. If any required phase file or companion file is missing, STOP immediately and report:

```
Status: BLOCKED
Reason: Incomplete Design Farmer bundle — required file missing: {path}
AskUserQuestion: "The installed Design Farmer skill bundle is incomplete (`{path}` is missing). Please reinstall or provide the missing file before I continue."
```

Do NOT guess missing phase behavior from memory.

---

## Phase Architecture

This skill is decomposed into specialized phase files under `phases/`. Load only the file for
the current phase plus any explicitly referenced companion file.

| Phase | File | Purpose |
|-------|------|---------|
| 0 | `phases/phase-0-preflight.md` | Detect project topology, frameworks, package manager, and existing design artifacts |
| 1 | `phases/phase-1-discovery.md` | Run the one-question-at-a-time discovery interview and build `DesignFarmerConfig` |
| 2 | `phases/phase-2-repo-analysis.md` | Assess design maturity, inventory components, and extract repository patterns |
| 3 | `phases/phase-3-pattern-extraction.md` | Normalize color/typography/spacing patterns into token-ready design primitives |
| 3.5 | `phases/phase-3.5-visual-preview.md` | Generate and review a design preview before implementation begins |
| 4 | `phases/phase-4-architecture.md` | Define token hierarchy, directory structure, theme strategy, and CSS layering |
| 4.5 | `phases/phase-4.5-design-source-of-truth.md` | Generate and maintain `DESIGN.md` as the persistent design reference |
| 5 | `phases/phase-5-tokens.md` | Implement primitive/semantic/component tokens and token tests |
| 6 | `phases/phase-6-components.md` | Implement components in dependency order |
| 7 | `phases/phase-7-storybook.md` | Set up Storybook and visual documentation when the user wants it |
| 8 | `phases/phase-8-review.md` | Run multi-reviewer verification and aggregate risk |
| 8.5 | `phases/phase-8.5-design-review.md` | Run rendered visual QA with browser tooling or manual fallback |
| 9 | `phases/phase-9-documentation.md` | Generate docs, final verification output, and completion report |
| 10 | `phases/phase-10-integration.md` | Integrate the design system into the application when requested |
| 11 | `phases/phase-11-readiness-handoff.md` | Produce release-readiness verification and handoff output |

### Reference Files

| File | Purpose |
|------|---------|
| `phases/operational-notes.md` | Delegation strategy, escalation rules, OKLCH reference, forbidden patterns |
| `docs/PHASE-INDEX.md` | Concise phase responsibilities and handoff map |
| `docs/QUALITY-GATES.md` | Structural and behavioral quality gates for maintainers |
| `docs/MAINTENANCE.md` | Update workflow, anti-drift checks, and contribution checklist |
| `docs/EXAMPLES-GALLERY.md` | Example outcomes and reference scenarios |

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

## Fallback & Degradation Protocol

Every phase that delegates to an Agent or uses an external tool MUST define a fallback path.
The pipeline NEVER silently fails.

Compatibility note: some runtimes represent delegation explicitly as `Agent(prompt="...")`.

### Degradation Pattern

```
Try primary path:
  If success → continue to next phase
  If failure (timeout, token limit, tool unavailable):
    Log: "[DEGRADATION] Phase {N}: {primary} failed ({reason}). Using {fallback}."
    Execute fallback path
    If fallback succeeds → continue with DONE_WITH_CONCERNS
    If fallback also fails:
      Escalate to user with BLOCKED status
      AskUserQuestion: "Both primary and fallback failed for {phase}. Error: {error}. How to proceed?"
```

### Fallback Registry

| Phase | Primary Path | Fallback Path |
|-------|-------------|---------------|
| Phase 2 (Analysis) | Structured repository analysis pass (specialized delegation preferred) | Direct Grep/Glob scanning with reduced depth |
| Phase 3 (Extraction) | Specialized analysis pass | Manual OKLCH extraction via inline math |
| Phase 3.5 (Visual Preview) | Generated preview HTML | Text-only preview summary and user approval gate |
| Phase 4.5 (DESIGN.md) | Structured design-document drafting | Write `DESIGN.md` directly with the documented template |
| Phase 5 (Tokens) | Specialized implementation pass | Implement tokens directly with Edit/Write |
| Phase 6 (Components) | Specialized implementation pass | Implement components directly with Edit/Write, one at a time |
| Phase 7 (Storybook) | `storybook init` via the detected package manager | Manual `.storybook` config + story file generation |
| Phase 8 (Review) | 5 specialized reviewer passes (parallel when supported) | Sequential review with combined criteria |
| Phase 8.5 (Visual QA) | Headless browser screenshots | Manual verification prompt with user-provided screenshots |
| Phase 9 (Docs) | Structured documentation drafting | Write docs directly with Write tool |
| Phase 10 (Integration) | Structured application changes | Guided step-by-step instructions for manual execution |
| Phase 11 (Readiness) | Automated verification + readiness handoff | Manual readiness report with explicit failed-gate summary |

---

## Execution Flow

Execute phases sequentially. Before starting each phase:

1. Read `phases/operational-notes.md` once per run if you have not already loaded it.
2. Read the corresponding phase file.
3. Follow the instructions in that file exactly.
4. Conclude the phase with a completion status.
5. Proceed only when that phase’s gates allow it.

### Phase Sequence

```
Phase 0: Pre-flight
    |
Phase 1: Discovery Interview
    |
Phase 2: Repository Analysis
    |
Phase 3: Design Pattern Extraction & OKLCH Conversion
    |
Phase 3.5: Visual Preview
    |
Phase 4: Architecture Design
    |
Phase 4.5: Design Source of Truth (DESIGN.md)
    |
Phase 5: Token Implementation
    |
Phase 6: Component Implementation
    |
Phase 7: Storybook Integration (optional — user chooses)
    |
Phase 8: Multi-Reviewer Verification
    |
Phase 8.5: Design Review (Live Visual QA) (if browser tooling or screenshots are available)
    |
Phase 9: Documentation & Completion
    |
Phase 10: App Integration (optional — user chooses)
    |
Phase 11: Release Readiness & Handoff
```

### Cross-Phase Contracts

- **DesignFarmerConfig** (from Phase 1) is passed to all subsequent phases.
- **Design Maturity** (from Phase 2) determines the implementation path in Phase 6.
- **Phase 3.5 is a hard gate** before Phase 4 unless preview generation falls back to a text-only approval path.
- **DESIGN.md** (from Phase 4.5) is the persistent design source of truth for Phases 5–11.
- **Semantic-token-only rule**: Components must NEVER consume primitive tokens directly.
- **Completion statuses are mandatory**: Every phase must end with DONE, DONE_WITH_CONCERNS, BLOCKED, or NEEDS_CONTEXT.
- **User-question gating**: Discovery interview questions are one-at-a-time. Other AskUserQuestion calls require user response before proceeding.
- **Final completion requires explicit verification evidence** from Phase 9.2 and, if Phase 11 runs, a readiness handoff report.

### Maintenance Note

This router is the canonical runtime entrypoint. If phase boundaries, file names, or quality
criteria change, update the corresponding phase file, `docs/PHASE-INDEX.md`,
`docs/QUALITY-GATES.md`, `docs/MAINTENANCE.md`, and `scripts/validate-skill-md.sh`
in the same PR.
