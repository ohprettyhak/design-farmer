# project-structural-reentry-guards

## Summary

Reduce brittleness in shell-based re-entry contract checks by replacing exact sentence matching with structural/semantic assertions. This keeps regression protection for legacy Phase 0→5 shortcut behavior while lowering false failures from harmless wording edits.

## Evidence

- Existing checks in `scripts/validate-skill-md.sh` and `skills/design-farmer/tests/test-semantic-consistency.sh` rely on exact phrases.
- Prior review activity showed wording drift can survive or fail inconsistently depending on where phrase checks are anchored.
- Current policy depends on script-enforced contracts for merge safety.

## Current Gap

Validation safety is strong but brittle: small documentation rewrites can fail checks even when behavior is still correct, while equivalent stale semantics can sometimes evade narrow phrase checks.

## Proposed Scope

Introduce semantic markers and structural checks for re-entry flow and legacy shortcut prohibition.

### In Scope

- Update `scripts/validate-skill-md.sh` to use grouped semantic checks (required markers + forbidden legacy markers) across contract-critical files.
- Update `skills/design-farmer/tests/test-semantic-consistency.sh` to verify re-entry behavior via intent-level markers, not only exact phrases.
- Keep checks bash-3.2-compatible and deterministic.

### Out of Scope

- Rewriting phase behavior itself.
- Replacing shell checks with non-shell tooling.
- Broad test-framework refactor.

## Architecture

- Add reusable guard blocks in shell scripts for:
  - required context-first semantics,
  - required Phase 1 gate-preservation semantics,
  - forbidden direct-to-Phase-5 legacy semantics.
- Ensure validators and semantic tests remain aligned to avoid split-brain pass/fail behavior.

## Acceptance Criteria

- [x] Re-entry checks no longer depend on one exact sentence for core assertions.
- [x] Legacy Phase 0→5 shortcut semantics remain blocked in contract-critical files.
- [x] Structural and semantic suites pass after the refactor.
- [x] No installer or smoke-test regressions introduced.

## Dependencies

- `scripts/validate-skill-md.sh`
- `skills/design-farmer/tests/test-semantic-consistency.sh`
- Existing phase/docs contracts around re-entry semantics

## Risks

- Over-generalized patterns may allow subtle regressions if too loose.
- Over-constrained patterns may keep false positives if too strict.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-04-09 | Codex | Initial draft |
| 2026-04-09 | Codex | Completed structural re-entry guard refactor and verified validation/smoke suites |
