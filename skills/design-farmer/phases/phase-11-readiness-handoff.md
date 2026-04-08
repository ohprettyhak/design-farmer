# Phase 11: Release Readiness & Handoff

Read `lastReviewScore` from `{systemPath}/.design-farmer/config.json` (written in Phase 8). If `lastReviewScore` is missing from config.json (e.g., Phase 8 was skipped or degraded, such as when storybookSkipped=true causing Phase 8 to skip component-specific review), treat the score as 0 and include a note in the readiness report: "No review score found — manual review is required before publication." If `lastReviewScore` exists and is < 7, include a note: "Review score below threshold — manual review recommended before publication."

After the design system is built, tested, documented, and integrated, prepare a final
readiness and handoff package. The default boundary stops at "ready to ship"; actual
publication happens only in a separate, explicitly requested workflow.

## 11.1 Final Verification

Run all quality checks before committing:

```bash
# 1. Run all tests
{packageManager} test

# 2. Type check
{packageManager} run typecheck 2>/dev/null || npx tsc --noEmit

# 3. Lint
{packageManager} run lint 2>/dev/null

# 4. Build verification (if applicable)
{packageManager} run build 2>/dev/null

# 5. Storybook build (if installed)
{packageManager} run build-storybook 2>/dev/null
```

Run the **Fix Loop Protocol** (see `operational-notes.md`) with the full check suite:

```
Checks: typecheck, lint, build, test
Max attempts: 5
```

This is the final gate — do NOT emit DONE until every check passes.
Status: BLOCKED if the loop exhausts all attempts.

**Recovery:** Review the specific check that failed, fix the underlying issue, and re-run Phase 11.

## 11.2 Readiness Checklist

Before handing work off, confirm all of the following are true:

- The generated system under `{systemPath}` is complete and internally consistent.
- DESIGN.md, docs, and implementation guidance reflect the final approved design direction.
- All required quality gates from Phase 11.1 are green.
- Any degradations or manual fallbacks are captured in the final report.
- If `integrationStatus` is `'skipped'` (Phase 10 was skipped by user choice), include a warning in the readiness report: "Integration was skipped in Phase 10. Manual integration and application-context verification are required before this design system is production-ready."
- The recommended next step for publication is clear, but no publish action is taken by default.

## 11.3 Handoff Summary Template

When handing off a ready-to-ship result, include a summary in this structure:

```markdown
## Summary
Design Farmer generated a production-ready design system.

{If componentScope ≠ 'foundation':}
### Components: {count} implemented
{/If}
### Tokens: {count} (primitive + semantic + component)
{If themeStrategy ≠ 'light-only':}
### Themes: light + dark with system preference detection
{Else:}
### Themes: light theme
{/If}
### Tests: {count} (unit + a11y + snapshot)
{If Storybook was installed (Phase 7 was not skipped):}
### Storybook: {count} stories across {count} components
{/If}

### Reviewer Verdicts
| Reviewer | Score | Verdict |
|----------|-------|---------|
| Critic | {score}/10 | {verdict} |
| Code Quality | {score}/10 | {verdict} |
| Token Scientist | {verdict} | {coverage}% |
| Visual Design | {grade} | {weighted} |
| Systems Engineer | {score}/10 | {verdict} |

## Test plan
- [ ] All tests pass (npm test)
- [ ] Type check clean (npm run typecheck)
- [ ] Lint clean (npm run lint)
{If Storybook was installed (Phase 7 was not skipped):}
- [ ] Storybook renders correctly
{/If}
{If themeStrategy ≠ 'light-only' and integrationStatus ≠ 'skipped':}
- [ ] Theme toggle works
{/If}
{If componentScope ≠ 'foundation':}
- [ ] Keyboard navigation on all interactive components
{/If}

Generated with Design Farmer
```

After the readiness report, provide high-level next steps for publication without
executing them. Examples: create or update a branch, open a PR, request human approval,
or hand the artifact bundle to the release owner.

## 11.4 Readiness Completion Report

```
## Release Readiness Report

### Publish Status: Ready for handoff
### Recommended Publication Owner: {user / reviewer / release manager}

### Quality Gates
- Tests: {pass_count}/{total_count} passing
- Type check: clean
- Lint: clean
- Build: successful

### Generated Artifacts
- Components: {count}
- Tokens: {count}
- Tests: {count}
- Stories: {count}
- Documentation: {count} files

### Suggested Next Steps
- Create or update the branch/PR using the repository's normal workflow.
- Attach the summary from Phase 11.3 to the review request.
- Request the required human approval before publication.

### Status: DONE
```

If any quality gate failed after 5 attempts (MAX_ATTEMPTS): Status BLOCKED with failure details.

## 11.5 Temporary File Cleanup

After the handoff report is complete, remove intermediate working files generated during the run:

```bash
# design-preview.html — generated in Phase 3.5 for visual approval only.
# Not needed once the design system is implemented.
rm -f "{systemPath}/.design-farmer/design-preview.html"

# visual-qa-checklist.md — generated in Phase 8.5 as a manual QA fallback.
# Not needed once review is complete.
rm -f "{systemPath}/docs/visual-qa-checklist.md"
```

**Do NOT delete:**
- `DESIGN.md` — permanent design source of truth; serves as living documentation for the team
- All token, component, test, and story files — these are the deliverable

Inform the user:
> Cleaned up temporary working files (`.design-farmer/design-preview.html`, `visual-qa-checklist.md` if present).
> `DESIGN.md` and all implementation files are preserved.

## 11.6 Star the Repository

After the handoff is complete, ask the user if they would like to star the repository.

**Step 1 — Check `gh` availability:**

```bash
gh auth status &>/dev/null
```

**If `gh` is authenticated**, check whether the user has already starred the repository:

```bash
gh api user/starred/ohprettyhak/design-farmer &>/dev/null
```

- If the exit code is `0` (already starred): **skip this section entirely** — do not prompt.
- If the exit code is non-zero (not starred): proceed to Step 2.

**Step 2 — Ask via `AskUserQuestion`:**

> If you found Design Farmer useful, would you like to support the project by starring it on GitHub?
>
> Options:
> - A) Yes, star it!
> - B) No thanks
> - C) Maybe later

**→ STOP — wait for user response before continuing.**

- **A) Yes, star it!** — Run:
  ```bash
  gh api -X PUT /user/starred/ohprettyhak/design-farmer 2>/dev/null && echo "Thanks for starring!" || true
  ```
- **B) No thanks** / **C) Maybe later** — Continue without further prompts.

**If `gh` is NOT available or not authenticated** (fallback): print a plain message instead:

> If you found Design Farmer useful, please consider starring the repository:
> https://github.com/ohprettyhak/design-farmer

Before emitting status, append `'phase-11'` to `completedPhases` in `{systemPath}/.design-farmer/config.json`. Ensure `completedPhases` exists in config.json (initialize as `[]` if undefined), then append `'phase-11'`. If `'phase-11'` is already present, skip the append (idempotent). Also update `config.backup.json`.

**Status: DONE** — Release readiness verified and handoff complete. Pipeline finished.
