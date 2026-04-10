# Marketplace Release Procedure

## Prerequisites

- Main branch is clean (no uncommitted changes)
- All CI checks passing
- Validation scripts pass locally

## Release Steps

1. **Run the release script:**
   ```bash
   ./scripts/release.sh <patch|minor|major>
   ```

2. **Review the commit:**
   ```bash
   git show
   ```

3. **Push to GitHub:**
   ```bash
   git push origin main
   git push origin v<version>
   ```

4. **Verify CI:**
   - Check GitHub Actions workflow passes
   - Confirm marketplace validation passes

5. **Verify marketplace update:**
   - Check that marketplace picks up the new version
   - Test marketplace install in a clean environment
   - Verify both Marketplace entrypoints still work for Claude Code users:
     ```bash
     /plugin marketplace add ohprettyhak/design-farmer
     /plugin install design-farmer@design-farmer
     ```

## What the Release Script Does

1. Runs pre-release validation:
   - `bash scripts/validate-skill-md.sh` (structural validation)
   - `bash skills/design-farmer/tests/run-all.sh` (semantic consistency suite)
   - `node --test scripts/__tests__/release-sync-manifests.test.mjs` (manifest sync module unit tests)
   - `claude plugin validate .` (plugin manifest validation)
2. Bumps version in `package.json` using `npm version --no-git-tag-version` (no commit, no tag)
3. Syncs version to `skills/design-farmer/SKILL.md` frontmatter
4. Syncs metadata to `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` via `scripts/release-sync-manifests.mjs` — a schema-aware merge that preserves unknown manifest fields across releases
5. Re-runs `claude plugin validate .` after metadata sync to catch post-sync drift
6. Creates a single atomic release commit with `package.json` and all synced files
7. Creates a git tag (`v<version>`)

The post-release verification should confirm that the CLI install example in `README.md`, localized `README.*.md` files, and `INSTALLATION.md` still matches the manifest identifiers shipped in `.claude-plugin/marketplace.json`.

The bump, sync, and validation steps all run before any commit or tag is
created. A failure at any stage is caught by the release script's `ERR`
trap, which restores the four managed release files to their pre-release
state via a file-scoped `git reset` + `git checkout`, leaving the git
history clean and the rest of the working tree untouched. After the
release commit succeeds, a second trap guards tag creation and rolls
the commit back with `git reset --soft HEAD~1` if tagging fails.
`docs/project-marketplace-distribution.md` has the full failure-mode
matrix.

## Version Source of Truth

`package.json` at the repository root is the single source of truth for version.
All other files (`skills/design-farmer/SKILL.md`, `.claude-plugin/plugin.json`,
`.claude-plugin/marketplace.json`) derive from it during the release process.

Do NOT manually edit version or metadata fields in `SKILL.md`, `plugin.json`,
or `marketplace.json` — they are overwritten by the release script.

## Rollback Procedure

If a release is broken:

1. Fix the issue in a new commit on main
2. Release a new version: `./scripts/release.sh patch`
3. Never modify released tags
