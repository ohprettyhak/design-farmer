# project-uninstall-script

## Summary

Add a first-party `uninstall.sh` script that removes the `design-farmer` skill bundle from supported AI tool directories with the same target-selection ergonomics as `install.sh`, while enforcing strict path safety and no-op behavior for absent targets.

## Evidence

- The repository already ships `install.sh` with multi-tool detection, selective target flags, and `--dry-run`, but did not provide an official uninstall workflow.
- Installation paths are deterministic and tool-specific, making a safe and explicit uninstall flow feasible.
- Existing smoke coverage (`scripts/test-install-smoke.sh`) validated install behavior only, leaving uninstall behavior unverified.

## Current Gap

Users could install the bundle in one command but had no standardized uninstall path. Manual cleanup risks accidental deletion outside the intended `skills/design-farmer` directories and creates inconsistent support guidance.

## Proposed Scope

### In Scope

- Add top-level `uninstall.sh` with option parity: `--tool`, `--all`, `--interactive`, `--dry-run`, `--list-tools`.
- Reuse the same tool matrix and target directory mapping used by `install.sh`.
- Delete only `*/skills/design-farmer` directories and preserve parent directories.
- Add explicit safety checks for empty and unsafe paths.
- Extend smoke tests to validate uninstall behavior and guardrails.
- Keep `README.md` and localized README files install-first, with uninstall shown as a single-line optional command.
- Keep full uninstall option details in `INSTALLATION.md` and repository policy/contracts that mention install lifecycle behavior.

### Out of Scope

- Deleting tool marker directories (e.g., `~/.claude`, `~/.agents`).
- Removing any skill other than `design-farmer`.
- Package-manager uninstall commands.

## Architecture

- `uninstall.sh` mirrors installer CLI parsing and selection flow:
  - detect markers per supported tool
  - resolve selected targets (`--tool`, `--all`, `--interactive`)
  - print resolved targets with detection/install status
  - honor `--dry-run` with no filesystem writes
- Safety contract:
  - target path must be non-empty
  - target path must match `*/skills/design-farmer`
  - no wildcard deletion
  - absent targets are treated as no-op success
- Validation contract:
  - `scripts/test-install-smoke.sh` covers install and uninstall scenarios in isolated temp HOME fixtures.
- Documentation contract:
  - README files expose uninstall as one-line optional guidance.
  - `INSTALLATION.md` is the canonical uninstall option reference.

## Acceptance Criteria

- [x] `uninstall.sh --tool <name>` removes only the selected tool target.
- [x] `uninstall.sh --dry-run` reports selected targets and performs no deletion.
- [x] `uninstall.sh` with absent bundle targets exits successfully and reports no-op behavior.
- [x] `uninstall.sh` never deletes directories outside `*/skills/design-farmer`.
- [x] Smoke tests include uninstall success/no-op/error paths.
- [x] User-facing install docs include uninstall usage.

## Dependencies

- Existing tool marker and target path conventions defined in `install.sh`.
- Smoke test harness under `scripts/test-install-smoke.sh`.
- CI workflow that runs smoke tests across supported tools and shells.

## Risks

- **Risk:** Unsafe deletion if target path resolution drifts.
  - **Mitigation:** Path guard enforces strict suffix validation before `rm -rf`.
- **Risk:** Behavior divergence between installer and uninstaller options.
  - **Mitigation:** Keep option surface and selection logic aligned; verify via smoke tests.
- **Risk:** Confusion when tool markers are absent.
  - **Mitigation:** Explicit no-op status messaging for "nothing to uninstall" cases.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-04-09 | Codex | Initial draft |
| 2026-04-09 | Codex | Clarified install-first README guidance and canonical uninstall detail location |
