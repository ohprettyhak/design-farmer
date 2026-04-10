# project-revision-history-cleanup

## Summary

Remove manual `Revision History` sections from internal project-contract Markdown files and related
Design Farmer guidance where they duplicate git history, add document length without improving the
 active contract, and teach an unnecessary maintenance pattern.

## Evidence

- A repository-wide audit of all 39 Markdown files found `Revision History` sections in 7 files.
- Five of those sections appear in `docs/project-*.md` internal contract documents or the
  `docs/project-template.md` source that propagates the pattern to future docs.
- `skills/design-farmer/phases/phase-4.5-design-source-of-truth.md` explicitly instructs generated
  `DESIGN.md` files to add a `## Revision History` section.
- `skills/design-farmer/examples/DESIGN.md` reinforces that pattern in the example output.
- Git history already provides a more accurate and lower-maintenance change log than per-document
  tables inside repository Markdown files.

## Current Gap

Internal contracts and example docs are carrying manual history tables that grow over time but do
not materially help readers understand current scope, architecture, or acceptance criteria. This
adds maintenance overhead and makes document templates longer than necessary.

## Proposed Scope

Remove revision-history sections from internal project-contract docs and stop requiring them in the
Phase 4.5 DESIGN.md contract and example.

### In Scope

- Remove `## Revision History` from `docs/project-template.md`.
- Remove `## Revision History` from existing `docs/project-*.md` contract docs that still use it.
- Update `docs/README.md` wording so it no longer describes `docs/` as storing project history.
- Remove the revision-history requirement from Phase 4.5 DESIGN.md instructions.
- Remove the revision-history block from the bundled example `skills/design-farmer/examples/DESIGN.md`.

### Out of Scope

- Replacing git history with a different changelog mechanism.
- Changing installer or uninstaller behavior.
- Reworking unrelated DESIGN.md sections or phase sequencing.

## Architecture

- `docs/project-template.md` defines the future shape of internal contracts and should stop seeding
  manual revision tables.
- Existing `docs/project-*.md` files should retain only active contract content.
- `skills/design-farmer/phases/phase-4.5-design-source-of-truth.md` should preserve prior design
  decisions via the Decisions Log rather than a separate revision-history section.
- `skills/design-farmer/examples/DESIGN.md` must match the active Phase 4.5 contract.

## Acceptance Criteria

- [ ] Repository Markdown files no longer include unnecessary `Revision History` sections.
- [ ] `docs/project-template.md` no longer instructs future internal contracts to add a manual
  revision-history block.
- [ ] `docs/README.md` accurately describes `docs/` as internal contract/planning space.
- [ ] Phase 4.5 no longer requires generated `DESIGN.md` files to add a `Revision History` section.
- [ ] The bundled example `DESIGN.md` matches the updated Phase 4.5 contract.

## Dependencies

- `docs/project-template.md`
- Existing `docs/project-*.md` contract files
- `skills/design-farmer/phases/phase-4.5-design-source-of-truth.md`
- `skills/design-farmer/examples/DESIGN.md`

## Risks

- Readers accustomed to inline change logs may briefly look for removed history tables.
- If the phase contract and example drift apart, generated DESIGN.md guidance could become inconsistent.
