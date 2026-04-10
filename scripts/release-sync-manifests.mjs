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
 * Produce a new plugin.json object by merging canonical fields from `pkg`
 * into `current`, stripping schema-forbidden keys, and preserving every
 * other key verbatim.
 */
export function syncPluginManifest(pkg, current) {
  assertPkgDescription(pkg);

  const next = { ...current };
  next.name = pkg.name;
  next.version = pkg.version;
  next.description = pkg.description;

  const author = normalizeAuthor(pkg.author);
  if (author) {
    next.author = author;
  }

  if (pkg.license) {
    next.license = pkg.license;
  }
  if (pkg.homepage) {
    next.homepage = pkg.homepage;
  }

  const repository = normalizeRepository(pkg.repository);
  if (repository) {
    next.repository = repository;
  }

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
  // preserving any fields the sync does not manage.
  const [firstPlugin, ...restPlugins] = current.plugins;
  const nextFirstPlugin = { ...firstPlugin };
  nextFirstPlugin.name = pkg.name;
  nextFirstPlugin.version = pkg.version;
  nextFirstPlugin.description = pkg.description;
  if (pkg.homepage) {
    nextFirstPlugin.homepage = pkg.homepage;
  }
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
