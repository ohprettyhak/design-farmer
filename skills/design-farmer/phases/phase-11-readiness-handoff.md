# Phase 11: Release Readiness & Handoff

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

## 11.2 Readiness Checklist

Before handing work off, confirm all of the following are true:

- The generated system under `{systemPath}` is complete and internally consistent.
- DESIGN.md, docs, and implementation guidance reflect the final approved design direction.
- All required quality gates from Phase 11.1 are green.
- Any degradations or manual fallbacks are captured in the final report.
- The recommended next step for publication is clear, but no publish action is taken by default.

## 11.3 Handoff Summary Template

When handing off a ready-to-ship result, include a summary in this structure:

```markdown
## Summary
Design Farmer generated a production-ready design system.

### Components: {count} implemented
### Tokens: {count} (primitive + semantic + component)
### Themes: light + dark with system preference detection
### Tests: {count} (unit + a11y + snapshot)
### Storybook: {count} stories across {count} components

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
- [ ] Storybook renders correctly
- [ ] Theme toggle works
- [ ] Keyboard navigation on all interactive components

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

If any quality gate failed after 3 attempts: Status BLOCKED with failure details.

## 11.5 Temporary File Cleanup

After the handoff report is complete, remove intermediate working files generated during the run:

```bash
# design-preview.html — generated in Phase 3.5 for visual approval only.
# Not needed once the design system is implemented.
rm -f "{systemPath}/design-preview.html"

# visual-qa-checklist.md — generated in Phase 8.5 as a manual QA fallback.
# Not needed once review is complete.
rm -f "{systemPath}/docs/visual-qa-checklist.md"
```

**Do NOT delete:**
- `DESIGN.md` — permanent design source of truth; serves as living documentation for the team
- All token, component, test, and story files — these are the deliverable

Inform the user:
> Cleaned up temporary working files (`design-preview.html`, `visual-qa-checklist.md` if present).
> `DESIGN.md` and all implementation files are preserved.

**Status: DONE** — Release readiness verified and handoff complete. Pipeline finished.
