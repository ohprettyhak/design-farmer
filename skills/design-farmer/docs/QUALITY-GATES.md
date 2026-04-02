# Design Farmer Quality Gates

This document defines release-quality checks for maintainers updating `SKILL.md`.

## 1) Structure Gates

- `SKILL.md` includes all phases from `Phase 0` through `Phase 9` (including `Phase 8.5`).
- Completion status protocol includes all required states:
  - `DONE`
  - `DONE_WITH_CONCERNS`
  - `BLOCKED`
  - `NEEDS_CONTEXT`
- Tooling references include both:
  - `AskUserQuestion`
  - `Agent(`

## 2) Behavioral Gates

- Discovery interview must preserve one-question-at-a-time gating semantics.
- Phase transitions must keep explicit “STOP / proceed” control points where required.
- Final verification commands remain explicit and testable.

## 3) Safety Gates

- Forbidden-pattern guidance remains present and synchronized with operational notes.
- Risk regulation thresholds and escalation behavior remain unambiguous.

## 4) Release Gate

Before merge, run:

```bash
bash scripts/validate-skill-md.sh
```

If the script fails, do not merge until failures are resolved.
