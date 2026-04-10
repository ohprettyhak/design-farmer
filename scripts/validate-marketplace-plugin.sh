#!/usr/bin/env bash
set -euo pipefail

PLUGIN_JSON=".claude-plugin/plugin.json"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"
ERRORS=0

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not installed" >&2
  exit 1
fi

# --- Validate plugin.json ---

if [ ! -f "$PLUGIN_JSON" ]; then
  echo "ERROR: $PLUGIN_JSON not found" >&2
  exit 1
fi

if ! jq empty "$PLUGIN_JSON" 2>/dev/null; then
  echo "ERROR: $PLUGIN_JSON is not valid JSON" >&2
  exit 1
fi

for field in name version description skills; do
  if ! jq -e ".$field" "$PLUGIN_JSON" >/dev/null 2>&1; then
    echo "ERROR: Missing required field '$field' in $PLUGIN_JSON" >&2
    ERRORS=$((ERRORS + 1))
  fi
done

SKILLS_PATH=$(jq -r '.skills' "$PLUGIN_JSON")
if [[ -n "$SKILLS_PATH" && "$SKILLS_PATH" != */ ]]; then
  echo "WARNING: 'skills' path '$SKILLS_PATH' should end with '/' to indicate a directory" >&2
fi

PLUGIN_VERSION=$(jq -r '.version' "$PLUGIN_JSON")
if [[ ! "$PLUGIN_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: Version '$PLUGIN_VERSION' in $PLUGIN_JSON is not valid semver" >&2
  ERRORS=$((ERRORS + 1))
fi

PLUGIN_NAME=$(jq -r '.name' "$PLUGIN_JSON")
if [ -z "$PLUGIN_NAME" ]; then
  echo "ERROR: 'name' field is empty in $PLUGIN_JSON" >&2
  ERRORS=$((ERRORS + 1))
fi

if [ -n "$SKILLS_PATH" ] && [ ! -d "$SKILLS_PATH" ]; then
  echo "ERROR: Skills directory '$SKILLS_PATH' does not exist" >&2
  ERRORS=$((ERRORS + 1))
fi

if [ "$ERRORS" -eq 0 ]; then
  echo "OK: $PLUGIN_JSON is valid (name=$PLUGIN_NAME, version=$PLUGIN_VERSION, skills=$SKILLS_PATH)"
else
  echo "ERRORS in $PLUGIN_JSON" >&2
fi

# --- Validate marketplace.json ---

MP_ERRORS=0

if [ ! -f "$MARKETPLACE_JSON" ]; then
  echo "ERROR: $MARKETPLACE_JSON not found" >&2
  exit 1
fi

if ! jq empty "$MARKETPLACE_JSON" 2>/dev/null; then
  echo "ERROR: $MARKETPLACE_JSON is not valid JSON" >&2
  exit 1
fi

for field in name owner plugins; do
  if ! jq -e ".$field" "$MARKETPLACE_JSON" >/dev/null 2>&1; then
    echo "ERROR: Missing required field '$field' in $MARKETPLACE_JSON" >&2
    MP_ERRORS=$((MP_ERRORS + 1))
  fi
done

# Marketplace metadata.version is required for cross-file sync checks
if ! jq -e '.metadata.version' "$MARKETPLACE_JSON" >/dev/null 2>&1; then
  echo "ERROR: Missing 'metadata.version' in $MARKETPLACE_JSON" >&2
  MP_ERRORS=$((MP_ERRORS + 1))
fi

# Ensure disallowed top-level keys are not present (rejected by Claude Code schema)
for bad in '$schema' description version; do
  if jq -e ". | has(\"$bad\")" "$MARKETPLACE_JSON" 2>/dev/null | grep -q true; then
    echo "ERROR: Disallowed top-level key '$bad' in $MARKETPLACE_JSON (must live under 'metadata')" >&2
    MP_ERRORS=$((MP_ERRORS + 1))
  fi
done

# Check owner has name
if ! jq -e '.owner.name' "$MARKETPLACE_JSON" >/dev/null 2>&1; then
  echo "ERROR: Missing 'owner.name' in $MARKETPLACE_JSON" >&2
  MP_ERRORS=$((MP_ERRORS + 1))
fi

# Check plugins array has at least one entry
PLUGIN_COUNT=$(jq '.plugins | length' "$MARKETPLACE_JSON")
if [ "$PLUGIN_COUNT" -lt 1 ]; then
  echo "ERROR: 'plugins' array must contain at least one entry in $MARKETPLACE_JSON" >&2
  MP_ERRORS=$((MP_ERRORS + 1))
fi

# Check first plugin has required fields
for field in name description version author source category; do
  if ! jq -e ".plugins[0].$field" "$MARKETPLACE_JSON" >/dev/null 2>&1; then
    echo "ERROR: Missing '$field' in plugins[0] of $MARKETPLACE_JSON" >&2
    MP_ERRORS=$((MP_ERRORS + 1))
  fi
done

MP_VERSION=$(jq -r '.metadata.version' "$MARKETPLACE_JSON")
MP_NAME=$(jq -r '.name' "$MARKETPLACE_JSON")

if [ "$MP_ERRORS" -eq 0 ]; then
  echo "OK: $MARKETPLACE_JSON is valid (name=$MP_NAME, version=$MP_VERSION, plugins=$PLUGIN_COUNT)"
else
  echo "ERRORS in $MARKETPLACE_JSON" >&2
fi

# --- Cross-file version check ---

PKG_VERSION=$(node -p "require('./package.json').version" 2>/dev/null || echo "")
if [ -n "$PKG_VERSION" ]; then
  MISMATCH=0
  if [ "$PKG_VERSION" != "$PLUGIN_VERSION" ]; then
    echo "ERROR: Version mismatch: package.json ($PKG_VERSION) != plugin.json ($PLUGIN_VERSION)" >&2
    MISMATCH=1
  fi
  if [ "$PKG_VERSION" != "$MP_VERSION" ]; then
    echo "ERROR: Version mismatch: package.json ($PKG_VERSION) != marketplace.json ($MP_VERSION)" >&2
    MISMATCH=1
  fi
  if [ "$MISMATCH" -eq 0 ]; then
    echo "OK: All versions synced at $PKG_VERSION"
  else
    ERRORS=$((ERRORS + MISMATCH))
  fi
fi

if [ "$((ERRORS + MP_ERRORS))" -gt 0 ]; then
  echo "Validation failed with $((ERRORS + MP_ERRORS)) error(s)" >&2
  exit 1
fi
