# Design Farmer Phase Index

This index provides a compact map of `SKILL.md` execution flow for maintainers.

## Canonical Source

- Canonical runtime instructions: `../SKILL.md`
- This file is a maintenance companion, not an execution source.

## Phase Map

1. **Phase 0: Pre-flight**
   - Detect project topology, frameworks, package manager, existing design system artifacts.
2. **Phase 1: Discovery Interview**
   - Ask one question at a time, block on user response, build `DesignFarmerConfig`.
3. **Phase 2: Repository Analysis**
   - Assess design maturity, inventory components, identify style/token patterns.
4. **Phase 3: Design Pattern Extraction & OKLCH Conversion**
   - Convert and normalize color systems, generate scales, validate contrast.
5. **Phase 4: Architecture Design**
   - Define token hierarchy, theme architecture, directory and build strategy.
6. **Phase 5: Token Implementation**
   - Implement primitive + semantic tokens and utilities with tests.
7. **Phase 6: Component Implementation**
   - Build component library using selected path (headless/custom) with accessibility requirements.
8. **Phase 7: Storybook Integration**
   - Document components and states visually (optional for light mode-only scenarios as configured).
9. **Phase 8: Multi-Reviewer Verification**
   - Execute multi-angle quality review and aggregate risk.
10. **Phase 8.5: Design Review (Live Visual QA)**
    - Perform visual QA loop with strict triage and risk thresholds.
11. **Phase 9: Documentation & Completion**
    - Generate docs, run final verification commands, emit completion report.

## Cross-Phase Contracts

- Completion statuses are mandatory: `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, `NEEDS_CONTEXT`.
- User-question gating in Discovery must remain one-at-a-time.
- Final completion requires explicit verification evidence.

## Maintenance Rule

If phase boundaries or criteria in `SKILL.md` change, update this file in the same PR.
