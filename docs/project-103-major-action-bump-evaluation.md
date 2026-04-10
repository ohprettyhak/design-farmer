# project-103-major-action-bump-evaluation

## Summary

Issue #103 tracks how this repository evaluates and resolves major Dependabot PRs for GitHub Actions pins used by the `Skill Quality` workflow. The goal is to make those upgrades reproducible and auditable, record the evaluation directly on the bumped Dependabot PRs, and keep the repository policy/docs aligned with the resulting workflow state.

## Evidence

- GitHub issue `#103` calls for a documented evaluation procedure plus a recorded decision for Dependabot PRs `#101` (`actions/checkout` v4 -> v6) and `#102` (`actions/setup-node` v4 -> v6).
- Before the resolution work started, `.github/workflows/skill-quality.yml` used `actions/checkout@v4` in all three jobs and `actions/setup-node@v4` in `validate-plugin`.
- Dependabot PRs `#101` and `#102` both passed the full `Skill Quality` matrix on their own bumped branches before merge.
- Upstream release notes document the relevant risks:
  - `actions/checkout` v5/v6: runner compatibility moved to the Node 24 runtime baseline; v6 also changes persisted credential storage.
  - `actions/setup-node` v5/v6: runner compatibility moved to the Node 24 runtime baseline; caching behavior changed, with `package-manager-cache: false` as the documented opt-out.
- `package.json` currently does not declare a top-level `packageManager` field, so auto-cache would not be expected to activate today, but an explicit workflow setting is safer than relying on future metadata staying absent.

## Current Gap

The repository has Dependabot coverage for GitHub Actions pins, but it did not document how maintainers should evaluate major-version jumps before merging them. The PR template also did not require release-note review evidence for these upgrades, which made the decision process hard to audit later.

## Proposed Scope

### In Scope

- Document a repository-wide major-action upgrade procedure in contributor and maintainer policy docs.
- Add PR-template prompts that require release-note, breaking-change, and CI evidence for major action bumps.
- Record the review outcome directly on Dependabot PRs `#101` and `#102`, then merge those PRs once their own CI passes.
- Set `package-manager-cache: false` explicitly for `actions/setup-node@v6` so workflow behavior stays stable even if package metadata changes later.

### Out of Scope

- Changing the Dependabot cadence or ecosystem coverage.
- Broad CI redesign unrelated to the action-version upgrades.
- Rewriting issue #103 to match the exact current GitHub check count.

## Architecture

- `docs/project-103-major-action-bump-evaluation.md` records the scoped contract and evidence for this issue.
- `CONTRIBUTING.md` becomes the canonical contributor-facing procedure for evaluating major GitHub Action bumps.
- `AGENTS.md` records the repository-wide maintainer policy and CI baseline wording that matches the current workflow pins.
- `.github/pull_request_template.md` requires reviewers/authors to include release-note and CI evidence when a PR changes major action versions.
- `.github/workflows/skill-quality.yml` keeps the merged `@v6` action upgrades and adds the explicit `package-manager-cache: false` setting.

## Acceptance Criteria

- [ ] A `docs/project-103-*.md` contract exists and records the issue scope, evidence, and risks before implementation proceeds.
- [ ] Contributor and maintainer docs explain how to evaluate major GitHub Action bumps, including intermediate-major release-note review and applicability checks.
- [ ] The PR template asks for release-note and CI evidence when a PR changes a major GitHub Action version.
- [ ] Dependabot PRs `#101` and `#102` have issue-`#103` evaluation comments recorded directly in their PR threads and are merged after their own bumped-branch CI passes.
- [ ] `Skill Quality` uses `actions/checkout@v6` and `actions/setup-node@v6` with an explicit `package-manager-cache: false` setting.
- [ ] Required local validation passes, and the branch PR can rely on GitHub Actions for full CI confirmation.

## Dependencies

- GitHub issue `#103`
- Dependabot PRs `#101` and `#102`
- PR comments on `#101` and `#102` that record the merge decision and upstream release-note applicability
- `.github/workflows/skill-quality.yml`
- `.github/dependabot.yml`

## Risks

- GitHub-hosted runner compatibility for Node 24-backed action runtimes is an upstream dependency; mitigation is to rely on GitHub-hosted runners and confirm green PR checks.
- `actions/checkout@v6` changes how persisted credentials are stored; mitigation is that this workflow does not run authenticated post-checkout git commands or Docker container actions.
- Future contributors could miss the evaluation process if it lives only in one file; mitigation is to document it in both `CONTRIBUTING.md` and `AGENTS.md`, then reinforce it in the PR template.
