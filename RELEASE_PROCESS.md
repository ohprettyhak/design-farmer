# Release Notes Process

This process keeps changelog updates consistent and reviewable.

## During Every Pull Request

1. Determine if the change is user-visible or operationally significant.
2. If yes, add an item under the relevant subsection in `CHANGELOG.md` -> `## [Unreleased]`.
3. Keep entries short and outcome-focused (why it matters).
4. Include issue/PR references when useful.

## During Release Preparation

1. Create a new version section in `CHANGELOG.md` using the documented format.
2. Move finalized entries from `Unreleased` into the new version section.
3. Keep `Unreleased` present for subsequent work.
4. Use the new section as the source for GitHub release notes.

## Review Expectations

- PRs with user-facing changes should not merge without a matching changelog entry.
- Reviewers verify changelog quality (clear, concise, and accurate scope).
