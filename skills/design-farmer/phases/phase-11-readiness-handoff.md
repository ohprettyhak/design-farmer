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

If any check fails, fix the issue and re-run. Loop until all checks pass.
Status: BLOCKED if same issue persists after 3 attempts.

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
