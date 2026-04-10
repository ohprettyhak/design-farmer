// Unit tests for scripts/release-sync-manifests.mjs.
//
// Run with:
//   node --test scripts/__tests__/release-sync-manifests.test.mjs
//
// The tests cover the three scenarios required by issue #95:
//   (a) the current repository manifest shape round-trips cleanly
//   (b) an unknown optional field is preserved across a sync
//   (c) a manifest missing a known-overwritten field gains that field
// plus extra guards around schema-forbidden keys, the description check,
// and the author/repository normalizers.

import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  normalizeAuthor,
  normalizeRepository,
  syncPluginManifest,
  syncMarketplaceManifest,
} from '../release-sync-manifests.mjs';

const basePkg = {
  name: 'design-farmer',
  version: '0.0.6',
  description: 'Automated design system construction from repository analysis to production-ready implementation.',
  author: { name: 'Hak Lee', email: 'hi@haklee.me' },
  license: 'MIT',
  homepage: 'https://github.com/ohprettyhak/design-farmer#readme',
  repository: { type: 'git', url: 'https://github.com/ohprettyhak/design-farmer.git' },
};

const basePluginManifest = {
  name: 'design-farmer',
  version: '0.0.6',
  description: basePkg.description,
  skills: './skills/',
  author: { name: 'Hak Lee', email: 'hi@haklee.me' },
  license: 'MIT',
  homepage: basePkg.homepage,
  repository: 'https://github.com/ohprettyhak/design-farmer.git',
};

const baseMarketplaceManifest = {
  name: 'design-farmer',
  owner: { name: 'Hak Lee', email: 'hi@haklee.me' },
  metadata: {
    description: basePkg.description,
    version: basePkg.version,
  },
  plugins: [
    {
      name: 'design-farmer',
      description: basePkg.description,
      version: basePkg.version,
      author: { name: 'Hak Lee', email: 'hi@haklee.me' },
      source: './',
      category: 'productivity',
      homepage: basePkg.homepage,
      tags: ['design-system', 'oklch', 'components'],
    },
  ],
};

// --- normalizers --------------------------------------------------------

test('normalizeAuthor: accepts an object passthrough', () => {
  const author = { name: 'Jane', email: 'jane@example.com' };
  assert.equal(normalizeAuthor(author), author);
});

test('normalizeAuthor: parses a string "name <email>"', () => {
  assert.deepEqual(
    normalizeAuthor('Jane Doe <jane@example.com>'),
    { name: 'Jane Doe', email: 'jane@example.com' }
  );
});

test('normalizeAuthor: parses a string without email', () => {
  assert.deepEqual(normalizeAuthor('Jane Doe'), { name: 'Jane Doe' });
});

test('normalizeAuthor: returns undefined for unsupported types', () => {
  assert.equal(normalizeAuthor(null), undefined);
  assert.equal(normalizeAuthor(undefined), undefined);
  assert.equal(normalizeAuthor(42), undefined);
});

test('normalizeRepository: returns string unchanged', () => {
  assert.equal(normalizeRepository('https://github.com/x/y.git'), 'https://github.com/x/y.git');
});

test('normalizeRepository: unwraps { type, url } object', () => {
  assert.equal(
    normalizeRepository({ type: 'git', url: 'https://github.com/x/y.git' }),
    'https://github.com/x/y.git'
  );
});

test('normalizeRepository: returns undefined for missing or malformed input', () => {
  assert.equal(normalizeRepository(undefined), undefined);
  assert.equal(normalizeRepository({}), undefined);
  assert.equal(normalizeRepository({ type: 'git' }), undefined);
});

// --- syncPluginManifest -------------------------------------------------

test('syncPluginManifest: baseline — current repository manifest shape round-trips', () => {
  const next = syncPluginManifest(basePkg, basePluginManifest);
  assert.equal(next.name, basePkg.name);
  assert.equal(next.version, basePkg.version);
  assert.equal(next.description, basePkg.description);
  assert.deepEqual(next.author, basePkg.author);
  assert.equal(next.license, basePkg.license);
  assert.equal(next.homepage, basePkg.homepage);
  assert.equal(next.repository, 'https://github.com/ohprettyhak/design-farmer.git');
  assert.equal(next.skills, './skills/', 'known non-canonical field must survive');
  assert.ok(!('bugs' in next), 'schema-forbidden `bugs` must be absent');
});

test('syncPluginManifest: preserves unknown top-level fields across sync', () => {
  const current = {
    ...basePluginManifest,
    futureOptionalField: 'should survive',
    nestedFutureField: { preserveMe: true, countsOfThings: [1, 2, 3] },
  };
  const next = syncPluginManifest(basePkg, current);
  assert.equal(next.futureOptionalField, 'should survive');
  assert.deepEqual(next.nestedFutureField, { preserveMe: true, countsOfThings: [1, 2, 3] });
});

test('syncPluginManifest: adds missing canonical fields', () => {
  const current = { skills: './skills/' }; // no name, version, description, author, etc.
  const next = syncPluginManifest(basePkg, current);
  assert.equal(next.name, basePkg.name);
  assert.equal(next.version, basePkg.version);
  assert.equal(next.description, basePkg.description);
  assert.deepEqual(next.author, basePkg.author);
  assert.equal(next.license, basePkg.license);
  assert.equal(next.homepage, basePkg.homepage);
  assert.equal(next.skills, './skills/');
});

test('syncPluginManifest: strips schema-forbidden `bugs`', () => {
  const current = { ...basePluginManifest, bugs: { url: 'https://github.com/x/y/issues' } };
  const next = syncPluginManifest(basePkg, current);
  assert.ok(!('bugs' in next));
});

test('syncPluginManifest: does not mutate the input manifest', () => {
  const current = { ...basePluginManifest, bugs: { url: 'x' } };
  const snapshot = JSON.parse(JSON.stringify(current));
  syncPluginManifest(basePkg, current);
  assert.deepEqual(current, snapshot);
});

test('syncPluginManifest: throws when pkg.description is missing', () => {
  const pkg = { ...basePkg };
  delete pkg.description;
  assert.throws(() => syncPluginManifest(pkg, basePluginManifest), /description/);
});

test('syncPluginManifest: normalizes string author to object', () => {
  const pkg = { ...basePkg, author: 'Jane Doe <jane@example.com>' };
  const next = syncPluginManifest(pkg, basePluginManifest);
  assert.deepEqual(next.author, { name: 'Jane Doe', email: 'jane@example.com' });
});

test('syncPluginManifest: normalizes repository object to URL string', () => {
  const pkg = { ...basePkg, repository: { type: 'git', url: 'https://github.com/a/b.git' } };
  const next = syncPluginManifest(pkg, basePluginManifest);
  assert.equal(next.repository, 'https://github.com/a/b.git');
});

// --- syncMarketplaceManifest -------------------------------------------

test('syncMarketplaceManifest: baseline — current repository manifest shape round-trips', () => {
  const next = syncMarketplaceManifest(basePkg, baseMarketplaceManifest);
  assert.equal(next.name, 'design-farmer');
  assert.equal(next.metadata.version, basePkg.version);
  assert.equal(next.metadata.description, basePkg.description);
  assert.equal(next.plugins[0].version, basePkg.version);
  assert.equal(next.plugins[0].description, basePkg.description);
  assert.equal(next.plugins[0].homepage, basePkg.homepage);
  assert.equal(next.plugins[0].source, './', 'non-canonical plugin field must survive');
  assert.equal(next.plugins[0].category, 'productivity');
  assert.deepEqual(next.plugins[0].tags, ['design-system', 'oklch', 'components']);
});

test('syncMarketplaceManifest: preserves unknown top-level fields', () => {
  const current = {
    ...baseMarketplaceManifest,
    futureTopLevelField: 'survive me',
    nestedConfig: { preserveMe: 1 },
  };
  const next = syncMarketplaceManifest(basePkg, current);
  assert.equal(next.futureTopLevelField, 'survive me');
  assert.deepEqual(next.nestedConfig, { preserveMe: 1 });
});

test('syncMarketplaceManifest: preserves unknown fields inside first plugin entry', () => {
  const current = {
    ...baseMarketplaceManifest,
    plugins: [
      {
        ...baseMarketplaceManifest.plugins[0],
        futurePluginField: 'keep me',
        capabilities: ['a', 'b'],
      },
    ],
  };
  const next = syncMarketplaceManifest(basePkg, current);
  assert.equal(next.plugins[0].futurePluginField, 'keep me');
  assert.deepEqual(next.plugins[0].capabilities, ['a', 'b']);
});

test('syncMarketplaceManifest: promotes root-level version/description into metadata', () => {
  const current = {
    ...baseMarketplaceManifest,
    version: '0.0.5',
    description: 'root-level stale',
  };
  const next = syncMarketplaceManifest(basePkg, current);
  assert.ok(!('version' in next), 'root-level version must be stripped');
  assert.ok(!('description' in next), 'root-level description must be stripped');
  assert.equal(next.metadata.version, basePkg.version);
  assert.equal(next.metadata.description, basePkg.description);
});

test('syncMarketplaceManifest: creates metadata object when missing', () => {
  const current = { ...baseMarketplaceManifest };
  delete current.metadata;
  const next = syncMarketplaceManifest(basePkg, current);
  assert.equal(next.metadata.version, basePkg.version);
  assert.equal(next.metadata.description, basePkg.description);
});

test('syncMarketplaceManifest: strips $schema', () => {
  const current = { ...baseMarketplaceManifest, $schema: 'https://example.com/schema.json' };
  const next = syncMarketplaceManifest(basePkg, current);
  assert.ok(!('$schema' in next));
});

test('syncMarketplaceManifest: does not mutate the input manifest', () => {
  const current = JSON.parse(JSON.stringify({ ...baseMarketplaceManifest, version: '0.0.5' }));
  const snapshot = JSON.parse(JSON.stringify(current));
  syncMarketplaceManifest(basePkg, current);
  assert.deepEqual(current, snapshot);
});

test('syncMarketplaceManifest: throws when pkg.description is missing', () => {
  const pkg = { ...basePkg };
  delete pkg.description;
  assert.throws(() => syncMarketplaceManifest(pkg, baseMarketplaceManifest), /description/);
});

test('syncMarketplaceManifest: throws when plugins array is missing or empty', () => {
  assert.throws(
    () => syncMarketplaceManifest(basePkg, { ...baseMarketplaceManifest, plugins: [] }),
    /at least one plugin/
  );
  const without = { ...baseMarketplaceManifest };
  delete without.plugins;
  assert.throws(() => syncMarketplaceManifest(basePkg, without), /at least one plugin/);
});
