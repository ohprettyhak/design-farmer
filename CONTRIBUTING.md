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

### Major GitHub Action Version Bumps

When a PR upgrades a GitHub Action across a major version (for example `actions/checkout@v4` -> `@v6`), review it as a compatibility change rather than a routine dependency bump.

1. Read the upstream release notes for every intermediate major version.
2. Classify each documented breaking change as applicable or not applicable to this repository's current workflow usage.
3. Confirm the workflow inputs used here still match upstream expectations.
4. Capture GitHub Actions evidence from the PR branch before merge.
5. Record the decision in the PR description or thread: merge, defer with a reason, or add a narrow `.github/dependabot.yml` ignore rule.

## 7) Documentation Discipline

When behavior or contributor workflow changes, update the matching docs in the same PR (README, installation guide, templates, policies, or process docs).

Documentation layers in this repository:

- Root docs (`README*.md`, `INSTALLATION.md`, `CONTRIBUTING.md`, `AGENTS.md`) are the canonical user, contributor, and repository-operation guides.
- `docs/project-*.md` files are internal implementation contracts and change records.
- `skills/design-farmer/docs/` contains maintainer references for the skill bundle itself.
