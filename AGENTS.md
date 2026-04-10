### Instructions

- Use the `docs/` directory as the source of truth for internal project contracts and implementation-planning documents.
- All repository-wide rules must be defined in this `AGENTS.md`.
- List files in `docs/` before starting each task, and keep `docs/` up-to-date.
- After completing each task, update the relevant `AGENTS.md` and `docs/` files in the same change when policies, structure, or contracts changed.
- Write all content in English, including code, comments, commit messages, PR titles, PR descriptions, issue titles, and issue bodies.
- Run `bash scripts/validate-skill-md.sh` before finishing any task that modifies skill bundle files.
- Run `bash skills/design-farmer/tests/run-all.sh` before finishing any task that modifies phase files, tests, or cross-phase contracts.
- Commit when each logical unit of work is complete; do NOT use the `--no-verify` flag.
- Run `git commit` only after `git add`; keep each commit atomic and independently revertible.
- After addressing pull request review comments and pushing updates, mark the corresponding review threads as resolved.
- When no explicit scope is specified and you are currently working within a pull request scope, interpret instructions within the current pull request scope.
- Do not guess; search the web instead.
- When accessing `github.com`, use the GitHub CLI (`gh`) instead of browser-based workflows when possible.
- Rules using MUST/NEVER are mandatory. Rules using prefer/whenever possible are guidance.

### Repository Structure Map

- `docs/`: Source of truth for internal project contracts and implementation-planning documents.
  - `docs/project-template.md`: Required structure for every new project document.
  - `docs/project-<id>.md`: Per-project contract document (created before implementation begins).
  - `docs/README.md`: Explains the role of internal project-contract docs and how they differ from user-facing docs.
- `skills/`: Skill bundles distributed to end-user AI tools.
  - `skills/design-farmer/SKILL.md`: Router — frontmatter, voice, phase index, cross-phase contracts.
  - `skills/design-farmer/phases/`: Phase instruction files (`phase-*.md`, `operational-notes.md`).
  - `skills/design-farmer/docs/`: Companion docs (`PHASE-INDEX.md`, `QUALITY-GATES.md`, `MAINTENANCE.md`, `EXAMPLES-GALLERY.md`).
  - `skills/design-farmer/examples/`: Reference examples (`DESIGN.md` — Nova UI greenfield reference).
  - `skills/design-farmer/bin/`: Executable utilities (`version-check`).
  - `skills/design-farmer/tests/`: Test suites (`run-all.sh`, `test-semantic-consistency.sh`, `test-version-check.sh`).
- `scripts/`: Repository-level validation and CI scripts.
  - `scripts/validate-skill-md.sh`: Structural validation (phase files, router references, contracts).
  - `scripts/release.sh`: Atomic release automation (version bump, file sync, tag creation).
  - `scripts/release-sync-manifests.mjs`: Schema-aware synchronization of `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` from `package.json`; importable as a library and invokable as a CLI from `release.sh`.
  - `scripts/__tests__/release-sync-manifests.test.mjs`: `node --test` unit tests for the manifest sync module (baseline, unknown-field preservation, schema-forbidden stripping).
  - `scripts/test-install-smoke.sh`: Install/uninstall smoke tests across tools and shells.
- `.github/`: GitHub configuration.
  - `.github/workflows/skill-quality.yml`: CI pipeline (structural validation, plugin manifest validation, install/uninstall smoke tests).
  - `.github/pull_request_template.md`: PR template with validation evidence checklist.
  - `.github/dependabot.yml`: Dependabot configuration that tracks GitHub Actions pins on a weekly schedule.
- `.claude-plugin/`: Claude Code Marketplace plugin metadata.
  - `.claude-plugin/plugin.json`: Marketplace plugin manifest (name, version, skills path).
  - `.claude-plugin/marketplace.json`: Marketplace listing metadata (owner, plugins array, tags, category).
- `package.json`: Single source of truth for version and release metadata (`private: true`, no npm publish).
- `INSTALLATION.md`: Canonical install lifecycle guide, including marketplace, curl installer, manual setup, troubleshooting, and optional removal.
- `install.sh`: Automated installer (detects tools, supports selective target flags, downloads skill bundle atomically).
- `uninstall.sh`: Automated uninstaller (detects/selects tools and removes only `skills/design-farmer` targets safely).
- `docs/marketplace-release-procedure.md`: Step-by-step marketplace release workflow.
- `AGENTS.md`: This file — repository-wide rules.
- `CONTRIBUTING.md`: Contributor workflow (branch naming, commit convention, PR requirements).
- `README.md`: Project overview, installation, and documentation links.
- `README.*.md`: Localized overview and installation entrypoint documents.

### Documentation Policy

- New feature or subsystem creation requires a `docs/project-<id>.md` before implementation begins.
- Every structural change to file paths or phase boundaries must update the corresponding `docs/` file in the same change.
- Repository-wide policy updates must be written in this `AGENTS.md` in the same change.

### Naming Rules

- Use lowercase kebab-case for directory names.
- Phase files follow the pattern `phase-{N}-{short-name}.md` where `{N}` is the phase number (including sub-phases like `3.5`, `4b`, `4.5`, `8.5`).
- Internal sections within a phase file use `{phase_number}.{section}` numbering scoped to that file. When a section number coincides with a sub-phase file number (e.g., section 8.5 within Phase 8 vs Phase 8.5 file), they are distinguished by file context. Prefer structural merging to eliminate overlaps when content allows it (e.g., Phase 3 absorbed section 3.5 into 3.2). When merging is not feasible, accept the shared number — each phase file is loaded independently so no execution ambiguity arises.
- Companion docs use UPPER-KEBAB-CASE filenames (`PHASE-INDEX.md`, `QUALITY-GATES.md`).

### GitHub Issue Style Contract

- Use issue titles in the format `<domain>: <description>`.
- `<domain>` must use a stable lowercase identifier (e.g. `skill`, `phase`, `installer`, `ci`, `docs`, `tests`).
- `<description>` should be concise and specific, starting with a lowercase verb phrase when possible.
- Do not use bracket-style prefixes like `[phase]`.
- Use the following Markdown section order for issue bodies:
  - `## Summary`
  - `## Evidence`
  - `## Current Gap`
  - `## Proposed Scope`
  - `## Acceptance Criteria`
  - `## Out of Scope`
- Optional `## Additional Notes` may be appended only when needed.

### PR Review Response Policy

When asked to review comments on a GitHub PR:

1. Evaluate each comment and decide whether to apply the feedback.
2. Apply the change if it is clearly necessary (correctness, security, documented contract).
3. Reply to each comment thread with the decision and reasoning:
   - **Applied**: explain what was changed and why.
   - **Rejected**: explain why the feedback does not apply or conflicts with intentional design.
4. Resolve the comment thread after replying.

**GitHub API notes:**
- Reply: `gh api --method POST repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies -f body="..."`
- Get thread node IDs (`PRRT_...`): GraphQL `repository.pullRequest.reviewThreads` -> `nodes { id isResolved comments(first:1) { nodes { databaseId } } }`
- Resolve: GraphQL `mutation { resolveReviewThread(input: {threadId: "PRRT_..."}) { thread { isResolved } } }`
- Always reply first, then resolve every thread.

### Skill Bundle Rules

- `SKILL.md` is the canonical runtime entrypoint. Phase instructions live in `phases/phase-{N}-*.md`.
- If phase boundaries, file names, or quality criteria change, update the corresponding phase file, `docs/PHASE-INDEX.md`, `docs/QUALITY-GATES.md`, `docs/MAINTENANCE.md`, and `scripts/validate-skill-md.sh` in the same PR.
- Phase files MUST NOT reference nonexistent companion documents or removed phases.
- The installer (`install.sh`) MUST ship every file referenced by `SKILL.md`. Adding or removing a bundle file requires updating `BUNDLE_FILES` in `install.sh` in the same PR.
- Cross-phase contracts in `SKILL.md` MUST accurately reflect phase file contents.

### Testing Rules

- All test suites MUST pass before a PR is merged.
- Three test suites exist:
  1. **Structural validation** (`scripts/validate-skill-md.sh`): phase file existence, router references, orphan detection, completion status protocol, cross-phase contracts, discovery interview gating, tool-contract keywords.
  2. **Semantic consistency** (`skills/design-farmer/tests/test-semantic-consistency.sh`): cross-reference section numbers, config field coverage, phase flow sequence, status message completeness, handoff chain, docs alignment, Fix Loop Protocol coverage, Phase 0 re-entry paths, conditional question gates, Phase 4b light-only guard, Phase 6 non-React guardrail, cross-phase data dependencies, pipeline state tracking.
  3. **version-check behavior** (`skills/design-farmer/tests/test-version-check.sh`): Releases API primary path, SKILL.md-on-main fallback path, and silent exit when both upstream sources are unreachable — uses `file://` URL overrides so the suite runs offline.
- All three suites are run together by `skills/design-farmer/tests/run-all.sh`.
- When adding a new phase, branching condition, or config field, add corresponding test coverage in the appropriate suite.

### Commit Convention

Use concise, purpose-first messages:

- `feat: ...`
- `fix: ...`
- `test: ...`
- `docs: ...`
- `chore: ...`

Recommended format:

```text
<type>: <what changed and why>
```

### Shell Command Safety Rules

- Use `$(...)` for command substitution; do not use legacy backticks in new scripts.
- Wrap all file paths in quotes by default in shell commands and scripts to prevent whitespace and glob-expansion bugs.
- Apply strict quoting and escaping for all dynamic shell values to prevent command injection and parsing bugs.
- Use `mktemp` for temporary files; never write to predictable paths in `/tmp`.

### GitHub Actions Major Upgrade Policy

- Treat GitHub Action major-version bumps as compatibility changes, not routine dependency updates.
- Review upstream release notes for each intermediate major version before merging a bump.
- Classify documented breaking changes against this repository's actual workflow inputs and job behavior.
- Require green PR checks on the bumped branch before merge.
- If a major cannot be merged safely, document the reason and use the narrowest possible `.github/dependabot.yml` ignore rule.

### CI Baseline

Repository-wide quality CI runs on every pull request and push to `main`.

Jobs:
- `validate-skill`: runs `bash scripts/validate-skill-md.sh` and `bash skills/design-farmer/tests/run-all.sh` — fails if any structural, semantic consistency, or version-check behavior suite fails.
- `validate-plugin`: pins `actions/setup-node@v6` to Node `20.18`, explicitly disables package-manager auto-cache to keep CI behavior stable, runs `node --test scripts/__tests__/release-sync-manifests.test.mjs` to exercise the schema-aware manifest sync module, then installs `@anthropic-ai/claude-code@~2.1.0` and runs `claude plugin validate .` — fails if the sync module regresses or if `.claude-plugin/plugin.json` or `.claude-plugin/marketplace.json` drifts from the Claude Code plugin/marketplace schema. Both the Node and CLI versions are pinned so upstream releases cannot break unrelated PRs without a commit in this repository; Dependabot (`.github/dependabot.yml`) bumps the GitHub Actions pins on a weekly schedule.
- `install-smoke`: runs `bash scripts/test-install-smoke.sh` across 5 tools x 2 shells (bash, zsh) — fails if any install/uninstall smoke test fails.

All CI jobs must pass before a PR is merged.
