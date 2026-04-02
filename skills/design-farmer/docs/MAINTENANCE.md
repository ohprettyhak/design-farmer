# Design Farmer Maintenance Guide

## Goal

Keep the Design Farmer bundle (`SKILL.md`, `phases/*.md`, `docs/*.md`, installer, and
validator) authoritative while reducing drift, ambiguity, and regressions.

## File Structure

```
skills/design-farmer/
  SKILL.md                        # Router: frontmatter, voice, phase index, cross-phase contracts
  phases/
    phase-0-preflight.md          # Phase 0 instructions
    phase-1-discovery.md          # Phase 1 instructions
    phase-2-repo-analysis.md      # Phase 2 instructions
    phase-3-pattern-extraction.md # Phase 3 instructions
    phase-3.5-visual-preview.md   # Phase 3.5 instructions
    phase-4-architecture.md       # Phase 4 instructions
    phase-4.5-design-source-of-truth.md # Phase 4.5 instructions
    phase-5-tokens.md             # Phase 5 instructions
    phase-6-components.md         # Phase 6 instructions
    phase-7-storybook.md          # Phase 7 instructions
    phase-8-review.md             # Phase 8 instructions
    phase-8.5-design-review.md    # Phase 8.5 instructions
    phase-9-documentation.md      # Phase 9 instructions
    phase-10-integration.md       # Phase 10 instructions
    phase-11-readiness-handoff.md # Phase 11 instructions
    operational-notes.md          # Agent delegation, OKLCH reference, forbidden patterns
  docs/
    PHASE-INDEX.md                # Concise phase responsibilities and handoff map
    QUALITY-GATES.md              # Verification standards and release readiness criteria
    MAINTENANCE.md                # This file
    EXAMPLES-GALLERY.md           # End-to-end outcomes from common repository states
```

## Change Workflow

1. `SKILL.md` is the **router** — it contains frontmatter, voice/tone, completion protocol,
   fallback/degradation policy, phase index, and cross-phase contracts. It does NOT contain
   full phase instructions.
2. Phase instructions live in `phases/phase-{N}-*.md`. Update the specific phase file
   when a phase's behavior changes.
3. If adding or removing a phase, update both `SKILL.md` (phase index table) and the
   corresponding `phases/` file.
4. If adding or removing a referenced companion file, update the installer and installer smoke tests in the same PR.
5. Update companion docs in `docs/` when behavior or phase boundaries change.
6. Run structural validation:

   ```bash
   bash scripts/validate-skill-md.sh
   ```

7. Include verification output in PR description.

## High-Risk Change Areas

- Completion statuses and fallback/degradation rules (in `SKILL.md` router)
- Discovery interview control flow (in `phases/phase-1-discovery.md`)
- Phase numbering and ordering (in `SKILL.md` phase index)
- Phase 3.5 / 4.5 / 11 parity with current lifecycle (preview, DESIGN.md, readiness handoff)
- Risk score thresholds (in `phases/phase-8-review.md` and `phases/phase-8.5-design-review.md`)
- Final verification command set (in `phases/phase-9-documentation.md` and `phases/phase-11-readiness-handoff.md`)

## Anti-Drift Checklist

- [ ] Phase names in `SKILL.md` phase index match files in `phases/` directory.
- [ ] Phase names in `SKILL.md` and `docs/PHASE-INDEX.md` are aligned.
- [ ] Quality requirements in `docs/QUALITY-GATES.md` still match current behavior.
- [ ] Any new mandatory status/token/keyword is reflected in `scripts/validate-skill-md.sh`.
- [ ] Installer ships every file referenced by `SKILL.md`.
- [ ] Installer smoke tests cover the split bundle, not just top-level `SKILL.md`.
- [ ] No phase file references a nonexistent companion document.
- [ ] Examples and recommendations remain internally consistent across all phase files.
- [ ] Cross-phase contracts in `SKILL.md` router accurately reflect phase file contents.

## Contribution Rule

For any PR touching phase instructions, update the corresponding `phases/` file and verify
the `SKILL.md` phase index table remains accurate. Companion files in `docs/` should be
reviewed for impact when behavior or phase boundaries change.
