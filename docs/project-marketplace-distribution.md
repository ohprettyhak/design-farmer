# project-marketplace-distribution

## Summary

Add a second distribution channel for the Design Farmer skill — the Claude Code Marketplace — alongside the existing curl installer. Marketplace installs are the recommended path for Claude Code users because the platform handles atomic install and update, while the curl installer remains the universal path for all supported AI tools. This project covers the plugin manifests, the release automation script, and the documentation layers required to keep both channels in sync from a single `package.json` source of truth.

This file is an internal project contract for the marketplace distribution work. End-user install guidance lives in `README.md`, `README.*.md`, and `INSTALLATION.md`.

## Evidence

- Claude Code users asked for a first-class install path that does not require running `curl | bash` and manually re-running the installer to update.
- The Claude Code plugin/marketplace manifest schema stabilized enough to target with a reproducible release script.
- The repository already ships multi-tool install semantics (`install.sh` + 5 AI tools), so marketplace distribution must coexist with the existing curl channel rather than replace it.
- Release automation was needed to eliminate drift between `package.json`, `SKILL.md`, `plugin.json`, and `marketplace.json` — these four files encode the same version and metadata today.

## Current Gap

Before this project, Design Farmer could only be installed via the curl installer. Claude Code users had no discoverable, marketplace-native path, and updates required re-running the curl installer manually. Release metadata was also scattered: version and description lived in `package.json` and `SKILL.md` only, with no plugin manifests and no automation to keep them aligned.

## Proposed Scope

### In Scope

- Add `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` conforming to the Claude Code plugin schema.
- Add `scripts/release.sh` as the single atomic release entrypoint. The script:
  - Runs structural validation, semantic consistency tests, and `claude plugin validate .` before any mutation.
  - Rejects the release if the target tag already exists locally or on origin.
  - Bumps `package.json` with `npm version --no-git-tag-version` so no commit/tag is created mid-flight.
  - Syncs version and metadata into `SKILL.md`, `plugin.json`, and `marketplace.json`.
  - Re-runs `claude plugin validate .` after metadata sync to catch post-sync drift.
  - Restores the working tree on any pre-commit failure via an `ERR` trap.
  - Creates a single atomic release commit and annotated tag only after all sync and validation steps pass.
- Update `README.md`, localized README variants, and `INSTALLATION.md` to lead with the marketplace path for Claude Code users, while preserving the curl installer as the universal fallback.
- Document the release procedure in `docs/marketplace-release-procedure.md`.
- Update `AGENTS.md` repository structure map to list the new `.claude-plugin/` directory, `INSTALLATION.md`, and `scripts/release.sh`.

### Out of Scope

- Automatic reconciliation between the marketplace cache and the curl-installed copy at runtime. Users are expected to install from exactly one channel per tool; `INSTALLATION.md` documents precedence and migration paths in both directions.
- Schema-aware manifest merging. The release script currently overwrites known keys and strips schema-forbidden keys (`$schema`, `bugs`, top-level `version`/`description`). If the Claude Code plugin schema grows new required fields, the script will need to be updated in a follow-up.
- Signed releases or checksum verification for the curl installer. `curl | bash` remains the existing universal install flow and is not changed by this project.
- Publishing to external registries (npm, Homebrew, etc.). `package.json` keeps `"private": true`.

## Architecture

### Version Source of Truth

`package.json` is the single source of truth for version and metadata. All other manifest files derive from it during the release process:

```
package.json
   │
   ├── skills/design-farmer/SKILL.md      (version frontmatter)
   ├── .claude-plugin/plugin.json          (plugin manifest)
   └── .claude-plugin/marketplace.json     (marketplace listing + plugin entry)
```

### Release Flow

```
scripts/release.sh <patch|minor|major>
   │
   ├─ 1. Pre-release validation
   │     ├── bash scripts/validate-skill-md.sh
   │     ├── bash skills/design-farmer/tests/run-all.sh
   │     └── claude plugin validate .
   │
   ├─ 2. Compute next version (no file writes)
   │     └── Check tag collision (local + remote)
   │
   ├─ 3. Install ERR trap (restores working tree on failure)
   │
   ├─ 4. Version bump (no commit, no tag)
   │     └── npm version --no-git-tag-version
   │
   ├─ 5. Metadata sync
   │     ├── SKILL.md frontmatter (sed)
   │     ├── .claude-plugin/plugin.json (node)
   │     └── .claude-plugin/marketplace.json (node)
   │
   ├─ 6. Post-sync re-validation
   │     └── claude plugin validate .
   │
   ├─ 7. Atomic release commit
   │     └── git commit -m "chore(release): v<version>"
   │
   ├─ 8. Disable ERR trap
   │
   └─ 9. Annotated tag
         └── git tag -a v<version>
```

### Channel Coexistence

Both channels install into Claude Code's skill namespace, but at different physical locations:

- **Marketplace**: Claude Code's managed plugin cache (updated automatically).
- **curl installer**: `~/.claude/skills/design-farmer/` (updated manually by re-running the installer).

When both are present on the same machine the two copies are not reconciled automatically, and the resolution order between the managed cache and the user skill directory has not been empirically verified against Claude Code's loader. `INSTALLATION.md` therefore instructs users to install from exactly one channel per tool and to run a migration flow when switching, rather than documenting a precedence rule that may drift with future Claude Code versions.

### Failure Modes Covered by the Release Script

| Stage | Failure | Recovery |
|-------|---------|----------|
| Pre-validation | any validation step fails | Script exits before any mutation; no recovery needed. |
| Lockfile precheck | tracked `package-lock.json` detected | Script exits before any mutation; repository is expected to remain lockfile-free. |
| Tag precheck (local) | `v<version>` tag already exists locally | Script exits before any mutation; user must delete the stale tag or pick a different release type. |
| Tag precheck (remote) | `git ls-remote` returns exit code 0 for the target tag | Script exits before any mutation; same remediation as local precheck. |
| Tag precheck (remote) | `git ls-remote` exits non-zero, non-2 (transport error) | Script exits rather than treating the error as "tag safe", avoiding a false-negative release. |
| Version bump / sync / re-validate | any step fails | `ERR` trap restores only the four release files (`package.json`, `SKILL.md`, `plugin.json`, `marketplace.json`) via scoped `git reset` + `git checkout`, leaving untracked work and unrelated modifications untouched. Script is re-runnable. |
| Release commit | pre-commit hook rejects commit | Same file-scoped `ERR` trap restores the release files. Re-run after fixing the hook. |
| Tag creation | `git tag -a` fails after the release commit exists | A post-commit `ERR` trap runs `git reset --soft HEAD~1`, rolling the release commit back so the staged files are preserved for inspection. Script is re-runnable once the underlying cause (e.g. filesystem or repo corruption) is fixed. `git tag -a` is a local-only operation, so transport failures cannot trigger this path — realistic causes are limited to filesystem or repo state issues. |

## Acceptance Criteria

- [x] `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` exist and pass `claude plugin validate .`.
- [x] `scripts/release.sh` rejects releases when the target tag already exists locally or on origin.
- [x] `scripts/release.sh` leaves the working tree clean on any pre-commit failure, allowing safe re-run.
- [x] `scripts/release.sh` creates exactly one release commit and one annotated tag per successful invocation, and only after all sync/validation steps pass.
- [x] The release commit message follows the repository commit convention (`<type>: <what>`).
- [x] `scripts/release.sh` fails loudly if `package.json` is missing the `description` field, instead of silently writing partial metadata.
- [x] `README.md` and localized README variants present marketplace as the recommended path for Claude Code users, with the curl installer as the universal fallback.
- [x] `INSTALLATION.md` documents the marketplace install, forward and reverse migration between channels, and install path precedence when both channels are active.
- [x] `docs/marketplace-release-procedure.md` describes the release script flow accurately.
- [x] `AGENTS.md` repository structure map references `.claude-plugin/`, `INSTALLATION.md`, `scripts/release.sh`, and `docs/marketplace-release-procedure.md`.

## Dependencies

- `claude` CLI with `plugin validate` subcommand available on the release host.
- `node` (bundled with `npm`) for inline manifest sync scripts and version computation.
- Existing `install.sh` and `uninstall.sh` infrastructure (unchanged by this project).
- Existing `scripts/validate-skill-md.sh` and `skills/design-farmer/tests/run-all.sh` test suites.

## Risks

| Risk | Mitigation |
|------|------------|
| Claude Code plugin schema gains new optional fields that the sync script silently drops on the next release. | `scripts/release-sync-manifests.mjs` is a schema-aware merge that preserves any existing manifest key the sync does not explicitly own; only the canonical fields pulled from `package.json` (name, version, description, author, license, homepage, repository) and explicitly-forbidden keys (`plugin.bugs`, `marketplace.$schema`, root-level `version`/`description`) are touched. Unit tests in `scripts/__tests__/release-sync-manifests.test.mjs` gate this behavior on every CI run, and `claude plugin validate .` runs before and after sync to catch schema breakage loudly. |
| Duplicate installations (marketplace + curl) on the same machine. | Documented in `INSTALLATION.md` with install path precedence and safe migration procedures in both directions. Install into exactly one channel per tool. |
| Version drift between marketplace (tag-pinned) and curl users (tracks `main`). | Release script bumps `SKILL.md`, both manifests, and `package.json` in a single atomic commit, and only creates the tag after all mutations succeed. CI and the manual `git push origin main && git push origin v<version>` step must stay adjacent. |
| Pre-commit hook rejects the release commit, leaving modified files. | `ERR` trap runs a file-scoped `git reset -q HEAD --` + `git checkout -q HEAD --` over the four release files only, leaving untracked work and unrelated modifications intact. Script is idempotent on re-run. |
| Inline `node -e` blocks in `release.sh` drift from the schema and become hard to maintain. | Resolved in #95 — extracted to `scripts/release-sync-manifests.mjs`, a standalone ESM module with `node --test` unit tests under `scripts/__tests__/`. `release.sh` invokes it via the CLI entry point. |
