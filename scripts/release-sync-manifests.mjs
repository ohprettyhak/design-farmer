#!/usr/bin/env node
// Schema-aware synchronization of `.claude-plugin/plugin.json` and
// `.claude-plugin/marketplace.json` from `package.json`.
//
// Each sync function takes an existing manifest object and returns a NEW
// object with:
//
//   - canonical fields overwritten from the package.json source of truth
//     (name, version, description, author, license, homepage, repository,
//     and plugin-entry equivalents)
//   - schema-forbidden keys removed (plugin.bugs, marketplace.$schema,
//     marketplace root-level version/description)
//   - every OTHER key preserved verbatim
//
// The preserve-unknown-keys behavior is the point: when the upstream
// Claude Code plugin/marketplace schema grows a new optional field and a
// maintainer adds it by hand, the next release must not silently strip it.
// The inline `node -e` blocks in release.sh that this module replaces did
// strip unknown keys on every run, and the project's #95 issue tracks the
// forward-compat risk that left behind.
//
// Usage as a library:
//
//   import { syncPluginManifest, syncMarketplaceManifest } from './release-sync-manifests.mjs';
//   const next = syncPluginManifest(pkg, current);
//
// Usage as a CLI (invoked by scripts/release.sh):
//
//   node scripts/release-sync-manifests.mjs plugin      package.json .claude-plugin/plugin.json
//   node scripts/release-sync-manifests.mjs marketplace package.json .claude-plugin/marketplace.json

import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

/**
 * Parse a package.json `author` field into an `{ name, email? }` object.
 * The Claude Code plugin manifest schema requires the object form.
 */
export function normalizeAuthor(author) {
  if (author && typeof author === 'object') {
    return author;
  }
  if (typeof author !== 'string') {
    return undefined;
  }
  const match = author.match(/^([^<(]+?)\s*(?:<([^>]+)>)?\s*(?:\(([^)]+)\))?\s*$/);
  if (!match) {
    return undefined;
  }
  const [, name, email] = match;
  const normalized = { name: name.trim() };
  if (email) {
    normalized.email = email.trim();
  }
  return normalized;
}

/**
 * Parse a package.json `repository` field into a plain string URL.
 * The Claude Code plugin manifest schema requires the string form.
 */
export function normalizeRepository(repository) {
  if (typeof repository === 'string') {
    return repository;
  }
  if (repository && typeof repository === 'object' && typeof repository.url === 'string') {
    return repository.url;
  }
  return undefined;
}

function assertPkgDescription(pkg) {
  if (!pkg.description) {
    throw new Error('package.json is missing required "description" field');
  }
}

/**
 * Assign a canonical field from `pkg` onto `next`: when the value is
 * present, write it; when the value is missing, delete the field from
 * `next` so removing it from `package.json` clears the stale manifest
 * value on the next release. Unknown (non-canonical) keys are left
 * untouched by the caller because this helper only acts on the fields
 * the sync explicitly owns.
 */
function assignOrClear(next, key, value) {
  if (value === undefined || value === null || value === '') {
    delete next[key];
  } else {
    next[key] = value;
  }
}

/**
 * Produce a new plugin.json object by merging canonical fields from `pkg`
 * into `current`, stripping schema-forbidden keys, and preserving every
 * non-canonical key verbatim. Canonical optional fields (author, license,
 * homepage, repository) are cleared from the manifest when absent in
 * `pkg` so `package.json` remains the single source of truth for them —
 * the previous inline sync relied on `JSON.stringify` dropping `undefined`
 * values to get the same effect, which is easy to miss on refactor.
 */
export function syncPluginManifest(pkg, current) {
  assertPkgDescription(pkg);

  const next = { ...current };
  next.name = pkg.name;
  next.version = pkg.version;
  next.description = pkg.description;

  assignOrClear(next, 'author', normalizeAuthor(pkg.author));
  assignOrClear(next, 'license', pkg.license);
  assignOrClear(next, 'homepage', pkg.homepage);
  assignOrClear(next, 'repository', normalizeRepository(pkg.repository));

  // Claude Code plugin manifest schema forbids `bugs` at the top level.
  delete next.bugs;

  return next;
}

/**
 * Produce a new marketplace.json object by merging canonical fields from
 * `pkg` into `current`, enforcing the `metadata`-nested shape, stripping
 * schema-forbidden keys, and preserving every other key verbatim.
 */
export function syncMarketplaceManifest(pkg, current) {
  assertPkgDescription(pkg);

  if (!Array.isArray(current.plugins) || current.plugins.length === 0) {
    throw new Error('marketplace.json must contain at least one plugin entry');
  }

  const next = { ...current };

  // Marketplace schema: version and description live under `metadata`.
  next.metadata = {
    ...(current.metadata ?? {}),
    version: pkg.version,
    description: pkg.description,
  };
  delete next.version;
  delete next.description;
  delete next['$schema'];

  // Update the first plugin entry (the one this repository owns) while
  // preserving any fields the sync does not manage. Canonical optional
  // fields are cleared when absent in package.json for the same reason
  // as the plugin.json sync above: keep package.json as the single
  // source of truth instead of letting stale values persist across
  // releases.
  const [firstPlugin, ...restPlugins] = current.plugins;
  const nextFirstPlugin = { ...firstPlugin };
  nextFirstPlugin.name = pkg.name;
  nextFirstPlugin.version = pkg.version;
  nextFirstPlugin.description = pkg.description;
  assignOrClear(nextFirstPlugin, 'homepage', pkg.homepage);
  next.plugins = [nextFirstPlugin, ...restPlugins];

  return next;
}

const SYNCERS = {
  plugin: syncPluginManifest,
  marketplace: syncMarketplaceManifest,
};

function runCli(argv) {
  const [kind, pkgPath, manifestPath] = argv.slice(2);
  if (!kind || !pkgPath || !manifestPath) {
    process.stderr.write(
      'Usage: release-sync-manifests.mjs <plugin|marketplace> <package.json> <manifest.json>\n'
    );
    process.exit(1);
  }
  const sync = SYNCERS[kind];
  if (!sync) {
    process.stderr.write(`Unknown kind: ${kind}\n`);
    process.stderr.write('Expected one of: plugin, marketplace\n');
    process.exit(1);
  }
  const pkg = JSON.parse(readFileSync(pkgPath, 'utf8'));
  const current = JSON.parse(readFileSync(manifestPath, 'utf8'));
  const next = sync(pkg, current);
  writeFileSync(manifestPath, JSON.stringify(next, null, 2) + '\n');
}

if (import.meta.url === `file://${process.argv[1]}` ||
    (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1])) {
  runCli(process.argv);
}
