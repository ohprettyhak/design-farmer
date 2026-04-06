### Instructions

- Use the `docs/` directory as the source of truth for project contracts and implementation documents.
- All repository-wide rules must be defined in this `AGENTS.md`.
- List files in `docs/` before starting each task, and keep `docs/` up-to-date.
- After completing each task, update the relevant `AGENTS.md` and `docs/` files in the same change when policies, structure, or contracts changed.
- Write all code and comments in English.
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

- `docs/`: Source of truth for project contracts and repository documentation.
  - `docs/project-template.md`: Required structure for every new project document.
  - `docs/project-<id>.md`: Per-project contract document (created before implementation begins).
- `skills/`: Skill bundles distributed to end-user AI tools.
  - `skills/design-farmer/SKILL.md`: Router — frontmatter, voice, phase index, cross-phase contracts.
  - `skills/design-farmer/phases/`: Phase instruction files (`phase-*.md`, `operational-notes.md`).
  - `skills/design-farmer/docs/`: Companion docs (`PHASE-INDEX.md`, `QUALITY-GATES.md`, `MAINTENANCE.md`, `EXAMPLES-GALLERY.md`).
  - `skills/design-farmer/examples/`: Reference examples (`DESIGN.md` — Nova UI greenfield reference).
  - `skills/design-farmer/bin/`: Executable utilities (`version-check`).
  - `skills/design-farmer/tests/`: Test suites (`run-all.sh`, `test-semantic-consistency.sh`, `test-exhaustive-simulation.sh`).
- `scripts/`: Repository-level validation and CI scripts.
  - `scripts/validate-skill-md.sh`: Structural validation (phase files, router references, contracts).
  - `scripts/test-install-smoke.sh`: Installer smoke tests across tools and shells.
- `.github/`: GitHub configuration.
  - `.github/workflows/skill-quality.yml`: CI pipeline (structural validation + install smoke tests).
  - `.github/pull_request_template.md`: PR template with validation evidence checklist.
- `install.sh`: Automated installer (detects tools, downloads skill bundle atomically).
- `AGENTS.md`: This file — repository-wide rules.
- `CONTRIBUTING.md`: Contributor workflow (branch naming, commit convention, PR requirements).
- `README.md`: Project overview, installation, and documentation links.

### Documentation Policy

- New feature or subsystem creation requires a `docs/project-<id>.md` before implementation begins.
- Every structural change to file paths or phase boundaries must update the corresponding `docs/` file in the same change.
- Repository-wide policy updates must be written in this `AGENTS.md` in the same change.

### Naming Rules

- Use lowercase kebab-case for directory names.
- Phase files follow the pattern `phase-{N}-{short-name}.md` where `{N}` is the phase number (including sub-phases like `3.5`, `4b`, `4.5`, `8.5`).
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
  2. **Semantic consistency** (`tests/test-semantic-consistency.sh`): cross-reference section numbers, config field coverage, phase flow sequence, status message completeness, handoff chain, docs alignment, Fix Loop Protocol coverage.
  3. **Exhaustive simulation** (`tests/test-exhaustive-simulation.sh`): all execution path combinations (1152 paths), conditional question flows, maturity branches, framework guardrails, skip/jump path validity, cross-phase data dependency chain integrity, fallback registry, Fix Loop activation, risk regulation.
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

### CI Baseline

Repository-wide quality CI runs on every pull request and push to `main`.

Jobs:
- `validate-skill`: runs `bash scripts/validate-skill-md.sh` — fails if any structural check fails.
- `install-smoke`: runs `bash scripts/test-install-smoke.sh` across 5 tools x 2 shells (bash, zsh) — fails if any installer smoke test fails.

All CI jobs must pass before a PR is merged.
