#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <patch|minor|major>"
  exit 1
fi

RELEASE_TYPE=$1

if [[ ! "$RELEASE_TYPE" =~ ^(patch|minor|major)$ ]]; then
  echo "Error: Release type must be patch, minor, or major"
  exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  echo "Error: Must release from main branch (current: $CURRENT_BRANCH)"
  exit 1
fi

if [[ -n $(git status --porcelain) ]]; then
  echo "Error: Working tree must be clean"
  git status --short
  exit 1
fi

# package.json is private: true and the repository intentionally ignores
# package-lock.json (.gitignore). If a tracked lockfile ever appears, npm
# version will silently rewrite it outside the set of files the release
# commit stages. Fail fast so the drift is caught before release.
if git ls-files --error-unmatch package-lock.json >/dev/null 2>&1; then
  echo "Error: package-lock.json is tracked, but this repository expects it to stay untracked (private: true)."
  exit 1
fi

echo "Running pre-release validation..."
bash scripts/validate-skill-md.sh
bash skills/design-farmer/tests/run-all.sh
claude plugin validate .

# Compute the next version without mutating files so we can check for
# tag collisions before any side effects.
echo "Computing next version..."
NEW_VERSION=$(RT="$RELEASE_TYPE" node -e "
  const pkg = require('./package.json');
  // Strict semver X.Y.Z, no leading zeros, no pre-release or build suffix.
  if (!/^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$/.test(pkg.version)) {
    console.error('Unsupported package.json version: ' + pkg.version + ' (expected X.Y.Z without leading zeros or pre-release suffix)');
    process.exit(1);
  }
  const [major, minor, patch] = pkg.version.split('.').map(Number);
  switch (process.env.RT) {
    case 'major': console.log((major + 1) + '.0.0'); break;
    case 'minor': console.log(major + '.' + (minor + 1) + '.0'); break;
    default:      console.log(major + '.' + minor + '.' + (patch + 1));
  }
")
NEW_TAG="v${NEW_VERSION}"

if git rev-parse -q --verify "refs/tags/${NEW_TAG}" >/dev/null; then
  echo "Error: Tag ${NEW_TAG} already exists locally. Aborting."
  exit 1
fi

# git ls-remote --exit-code returns 0 when the ref is found, 2 when the ref
# is missing, and other non-zero codes (typically 128) on transport errors.
# Treat only exit 2 as "tag not found"; any other non-zero exit means the
# remote check itself failed and the release must abort rather than proceed
# on a false-negative.
echo "Checking origin for existing tag ${NEW_TAG}..."
REMOTE_LS_RC=0
git ls-remote --exit-code --tags origin "refs/tags/${NEW_TAG}" >/dev/null 2>&1 || REMOTE_LS_RC=$?
case "${REMOTE_LS_RC}" in
  0)
    echo "Error: Tag ${NEW_TAG} already exists on origin. Aborting."
    exit 1
    ;;
  2)
    ;; # tag not found on origin — safe to proceed
  *)
    echo "Error: Failed to query origin for tag ${NEW_TAG} (git ls-remote exit ${REMOTE_LS_RC}). Aborting." >&2
    exit 1
    ;;
esac

# Trap: if any step between the version bump and the release commit fails,
# restore only the files this script owns so the user can re-run the script.
# A file-scoped restore (instead of `git reset --hard HEAD`) avoids wiping
# untracked work, concurrent editor saves, or unrelated local modifications.
RELEASE_FILES=(
  "package.json"
  "skills/design-farmer/SKILL.md"
  ".claude-plugin/plugin.json"
  ".claude-plugin/marketplace.json"
)

cleanup_on_error() {
  local exit_code=$?
  echo ""
  echo "Error: Release script failed (exit ${exit_code}). Restoring release files..."
  git reset -q HEAD -- "${RELEASE_FILES[@]}" >/dev/null 2>&1 || true
  git checkout -q HEAD -- "${RELEASE_FILES[@]}" >/dev/null 2>&1 || true
  echo "Release files restored. You can safely re-run release.sh."
  exit "${exit_code}"
}
trap cleanup_on_error ERR

echo "Bumping version to ${NEW_VERSION}..."
npm version --no-git-tag-version "$RELEASE_TYPE" >/dev/null

echo "Syncing SKILL.md..."
sed -i.bak "s|^version:.*|version: ${NEW_VERSION}|" "skills/design-farmer/SKILL.md"
rm -f "skills/design-farmer/SKILL.md.bak"

echo "Syncing plugin.json..."
node -e "
  const pkg = require('./package.json');
  const fs = require('fs');
  const pluginPath = './.claude-plugin/plugin.json';
  const plugin = JSON.parse(fs.readFileSync(pluginPath, 'utf8'));
  if (!pkg.description) {
    throw new Error('package.json is missing required \"description\" field');
  }
  // Claude Code plugin manifest schema: author must be object, repository must be string, bugs is not supported.
  const authorMatch = typeof pkg.author === 'string'
    ? pkg.author.match(/^([^<(]+?)\s*(?:<([^>]+)>)?\s*(?:\(([^)]+)\))?\s*$/)
    : null;
  const authorObj = typeof pkg.author === 'object' && pkg.author !== null
    ? pkg.author
    : authorMatch
      ? { name: authorMatch[1].trim(), ...(authorMatch[2] ? { email: authorMatch[2].trim() } : {}) }
      : undefined;
  const repoString = typeof pkg.repository === 'string'
    ? pkg.repository
    : (pkg.repository && pkg.repository.url) || undefined;
  plugin.version = pkg.version;
  plugin.name = pkg.name;
  plugin.description = pkg.description;
  if (authorObj) plugin.author = authorObj;
  plugin.license = pkg.license;
  plugin.homepage = pkg.homepage;
  if (repoString) plugin.repository = repoString;
  delete plugin.bugs;
  fs.writeFileSync(pluginPath, JSON.stringify(plugin, null, 2) + '\n');
"

echo "Syncing marketplace.json..."
node -e "
  const pkg = require('./package.json');
  const fs = require('fs');
  const mpPath = './.claude-plugin/marketplace.json';
  const mp = JSON.parse(fs.readFileSync(mpPath, 'utf8'));
  if (!pkg.description) {
    throw new Error('package.json is missing required \"description\" field');
  }
  // Marketplace schema: version/description live under 'metadata', not at root.
  mp.metadata = mp.metadata || {};
  mp.metadata.version = pkg.version;
  mp.metadata.description = pkg.description;
  delete mp.version;
  delete mp.description;
  delete mp['\$schema'];
  if (!Array.isArray(mp.plugins) || mp.plugins.length === 0) {
    throw new Error('marketplace.json must contain at least one plugin entry');
  }
  mp.plugins[0].version = pkg.version;
  mp.plugins[0].name = pkg.name;
  mp.plugins[0].description = pkg.description;
  fs.writeFileSync(mpPath, JSON.stringify(mp, null, 2) + '\n');
"

echo "Re-validating manifests after metadata sync..."
claude plugin validate .

echo "Creating release commit..."
git add "${RELEASE_FILES[@]}"
git commit -m "chore(release): v${NEW_VERSION}"

# Re-arm the trap with a post-commit recovery: if tag creation fails after
# the release commit exists, roll the commit back with --soft so the release
# files return to staging and the user can investigate without a dangling
# unreleased commit on the branch.
tag_failure_cleanup() {
  local exit_code=$?
  echo ""
  echo "Error: Tag creation failed after commit (exit ${exit_code}). Rolling back release commit..."
  if git reset --soft HEAD~1 >/dev/null 2>&1; then
    echo "Release commit rolled back; staged release files preserved for inspection."
  else
    echo "WARNING: Rollback (git reset --soft HEAD~1) also failed." >&2
    echo "The release commit is still present on HEAD. Manual intervention required." >&2
  fi
  exit "${exit_code}"
}
trap tag_failure_cleanup ERR

git tag -a "$NEW_TAG" -m "Release ${NEW_TAG}"

trap - ERR

echo ""
echo "Release ${NEW_VERSION} ready!"
echo "  Commit: $(git rev-parse HEAD)"
echo "  Tag: ${NEW_TAG}"
echo ""
echo "Next steps:"
echo "  1. Review: git show"
echo "  2. Push: git push origin main"
echo "  3. Push tag: git push origin ${NEW_TAG}"
