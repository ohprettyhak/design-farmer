# Design Farmer Maintenance Guide

## Goal

Keep `SKILL.md` authoritative while reducing drift, ambiguity, and regressions.

## Change Workflow

1. Update `SKILL.md` (canonical instruction source).
2. Update companion docs in `docs/` when behavior or phase boundaries change.
3. Run structural validation:

   ```bash
   bash scripts/validate-skill-md.sh
   ```

4. Include verification output in PR description.

## High-Risk Change Areas

- Completion statuses and escalation rules
- Discovery interview control flow
- Phase numbering and ordering
- Risk score thresholds
- Final verification command set

## Anti-Drift Checklist

- [ ] Phase names in `SKILL.md` and `docs/PHASE-INDEX.md` are aligned.
- [ ] Quality requirements in `docs/QUALITY-GATES.md` still match current behavior.
- [ ] Any new mandatory status/token/keyword is reflected in `scripts/validate-skill-md.sh`.
- [ ] Examples and recommendations remain internally consistent.

## Contribution Rule

For any PR touching `SKILL.md`, at least one companion file in `docs/` should be reviewed for impact.
