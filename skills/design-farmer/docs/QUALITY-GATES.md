# Design Farmer Quality Gates

This document defines release-quality checks for maintainers updating the Design Farmer bundle.

## 1) Structure Gates

- `SKILL.md` (router) references all phases from `Phase 0` through `Phase 11` (including `Phase 3.5`, `Phase 4b`, `Phase 4.5`, and `Phase 8.5`) in its phase index table.
- Each phase has a corresponding file in `phases/` directory.
- Every phase file listed in `SKILL.md` exists exactly once in `phases/`.
- No extra `phases/phase-*.md` file exists without a matching phase-table entry.
- Completion status protocol (in `SKILL.md` router) includes all required states:
  - `DONE`
  - `DONE_WITH_CONCERNS`
  - `BLOCKED`
  - `NEEDS_CONTEXT`
- Tooling references include both:
  - `AskUserQuestion`
  - `Agent(`
- Installer bundle includes every file referenced by `SKILL.md`.

## 2) Behavioral Gates

- Discovery interview (in `phases/phase-1-discovery.md`) must preserve one-question-at-a-time gating semantics.
- Phase transitions must keep explicit “STOP / proceed” control points where required.
- Final verification commands (in `phases/phase-9-documentation.md` and `phases/phase-11-readiness-handoff.md`) remain explicit and testable.
- Phase 3.5 preview approval, Phase 4.5 DESIGN.md generation, and Phase 11 readiness handoff remain aligned with the current lifecycle.

## 3) Safety Gates

- Forbidden-pattern guidance remains present and synchronized with operational notes.
- Risk regulation thresholds and escalation behavior remain unambiguous.
- No broken references to nonexistent companion docs remain in any phase file.

## 4) Release Gate

Before merge, run:

```bash
bash scripts/validate-skill-md.sh
```

If the script fails, do not merge until failures are resolved.
