# Contributing to design-farmer

Thanks for contributing.

This guide covers the standard flow from issue selection to merge.

## 1) Start From an Issue

1. Pick an existing issue or create one with enough context.
2. Confirm acceptance criteria are explicit and testable.
3. Reference the issue in your PR (`Closes #<number>`).

## 2) Branch Naming Convention

Use descriptive branch names with issue context:

- `feat/issue-<id>-<short-topic>`
- `fix/issue-<id>-<short-topic>`
- `docs/issue-<id>-<short-topic>`

Examples:

- `feat/issue-12-install-smoke-tests`
- `docs/issue-9-changelog-process`

## 3) Commit Convention

Use concise, purpose-first messages:

- `feat: ...`
- `fix: ...`
- `docs: ...`
- `chore: ...`

Recommended format:

```text
<type>: <what changed and why> (#<issue-id>)
```

Example:

```text
docs: add issue templates for structured triage (#5)
```

## 4) Local Validation Before PR

Run the required validation command:

```bash
bash scripts/validate-skill-md.sh
```

Expected success output includes:

- `All skill structure and contract checks passed.`

If your change touches scripts/workflows, include any additional command output in the PR description.

## 5) Pull Request Requirements

Use the repository PR template and complete all checklist items.

Your PR should include:

- Clear summary of intent and scope
- Linked issue(s)
- Validation evidence (commands + outcomes)
- Impact notes and rollback plan when relevant

## 6) Review and Merge Expectations

- Address reviewer feedback with focused follow-up commits.
- Keep PR scope aligned to the linked issue acceptance criteria.
- Merge once checks pass and reviewer approval is complete.

## 7) Documentation Discipline

When behavior or contributor workflow changes, update the matching docs in the same PR (README, templates, policies, or process docs).
