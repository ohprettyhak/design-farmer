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

## What the Release Script Does

1. Runs pre-release validation:
   - `bash scripts/validate-skill-md.sh` (structural validation)
   - `bash skills/design-farmer/tests/run-all.sh` (semantic consistency suite)
   - `claude plugin validate .` (plugin manifest validation)
2. Bumps version in `package.json` using `npm version`
3. Syncs version to `skills/design-farmer/SKILL.md` frontmatter
4. Syncs metadata to `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
5. Re-runs `claude plugin validate .` after metadata sync to catch post-sync drift
6. Amends the `npm version` commit to include all synced files
7. Creates a git tag (`v<version>`)

## Version Source of Truth

`package.json` at the repository root is the single source of truth for version.
All other files (`SKILL.md`, `plugin.json`) derive from it during the release process.

Do NOT manually edit version fields in `SKILL.md` or `plugin.json` — they are
overwritten by the release script.

## Rollback Procedure

If a release is broken:

1. Fix the issue in a new commit on main
2. Release a new version: `./scripts/release.sh patch`
3. Never modify released tags
