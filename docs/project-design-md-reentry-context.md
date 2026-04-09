# project-design-md-reentry-context

## Summary

Improve Phase 0 re-entry behavior when an existing `DESIGN.md` is present so Design Farmer treats it as context input, not an automatic phase bypass. This prevents critical discovery decisions (such as component scope and headless library selection) from being silently skipped when users import external DESIGN.md files.

## Evidence

- User feedback: importing DESIGN.md from external repositories (for example, awesome-design-md) is common and currently causes important option gates to be skipped.
- At proposal start, the contract and tests still allowed a direct Option A jump to Phase 5.
- Phase 1 contains crucial choices (Q3/Q3-1/Q5/Q5-1) that influence downstream Phase 6 implementation quality.

## Current Gap

At proposal start, Phase 0 Option A reconstructed config and bypassed Phases 1–4.5. That was fast but could produce low-context or mismatched systems because foundational architecture and library decisions were not re-validated against the active repository.

## Proposed Scope

Revise re-entry semantics so existing `DESIGN.md` pre-fills defaults and informs decisions, while mandatory discovery gates still run before implementation phases.

### In Scope

- Update Phase 0 wording and control flow to context-first re-entry.
- Keep config reconstruction from DESIGN.md, but continue to Phase 1 instead of jumping to Phase 5.
- Add explicit guardrail text to preserve required decision gates.
- Update router/docs/test contracts and validators to match the new behavior.

### Out of Scope

- Adding new phase files or changing phase numbering.
- Redesigning all discovery questions.
- Introducing external classifiers for DESIGN.md origin quality scoring.

## Architecture

- `phase-0-preflight.md`: change Option A semantics to context import + Phase 1 continuation; set `reentryMode: "design-context"`.
- `phase-1-discovery.md`: consume `reentryMode` and enforce explicit confirmation of critical gates.
- `SKILL.md`, `docs/PHASE-INDEX.md`: update cross-phase contracts.
- `scripts/validate-skill-md.sh` and `tests/test-semantic-consistency.sh`: enforce new contract.

## Acceptance Criteria

- [x] Phase 0 Option A no longer instructs skip-to-Phase-5 behavior.
- [x] Phase 0 Option A explicitly states critical discovery gates must still run.
- [x] Cross-phase contract docs describe DESIGN.md as context input for re-entry.
- [x] Validation and semantic tests pass with the updated contract.
- [x] Template/example/operational references no longer describe legacy direct-to-Phase-5 shortcut wording.

## Dependencies

- Existing phase architecture in `skills/design-farmer/phases/`.
- Contract validation scripts in `scripts/` and `skills/design-farmer/tests/`.

## Risks

- Slightly slower re-entry flow due to discovery confirmation gates.
- Potential contract drift if router/docs/tests are not updated together.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-04-09 | Codex | Initial draft |
| 2026-04-09 | Codex | Marked acceptance criteria complete and added anti-drift completion evidence |
