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

echo "Running pre-release validation..."
bash scripts/validate-skill-md.sh
bash skills/design-farmer/tests/run-all.sh
claude plugin validate .

echo "Bumping version (${RELEASE_TYPE})..."
npm version --no-git-tag-version "$RELEASE_TYPE" >/dev/null

NEW_VERSION=$(node -p "require('./package.json').version")

echo "Syncing SKILL.md..."
sed -i.bak "s/^version:.*/version: ${NEW_VERSION}/" skills/design-farmer/SKILL.md
rm -f skills/design-farmer/SKILL.md.bak

echo "Syncing plugin.json..."
node -e "
  const pkg = require('./package.json');
  const fs = require('fs');
  const pluginPath = './.claude-plugin/plugin.json';
  const plugin = JSON.parse(fs.readFileSync(pluginPath, 'utf8'));
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
  // Marketplace schema: version/description live under 'metadata', not at root.
  mp.metadata = mp.metadata || {};
  mp.metadata.version = pkg.version;
  if (pkg.description) mp.metadata.description = pkg.description;
  delete mp.version;
  delete mp.description;
  delete mp['\$schema'];
  mp.plugins[0].version = pkg.version;
  mp.plugins[0].name = pkg.name;
  mp.plugins[0].description = pkg.description;
  fs.writeFileSync(mpPath, JSON.stringify(mp, null, 2) + '\n');
"

echo "Re-validating manifests after metadata sync..."
claude plugin validate .

echo "Creating release commit..."
git add package.json skills/design-farmer/SKILL.md .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "${NEW_VERSION}"

NEW_TAG="v${NEW_VERSION}"
git tag -a "$NEW_TAG" -m "Release ${NEW_TAG}"

echo ""
echo "Release ${NEW_VERSION} ready!"
echo "  Commit: $(git rev-parse HEAD)"
echo "  Tag: ${NEW_TAG}"
echo ""
echo "Next steps:"
echo "  1. Review: git show"
echo "  2. Push: git push origin main"
echo "  3. Push tag: git push origin ${NEW_TAG}"
