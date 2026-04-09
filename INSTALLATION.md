# Installation

## Recommended (automatic)

Run the installer script:

```bash
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash
```
If you need to remove the bundle later, see [Uninstall options](#uninstall-options).

The installer will:

1. Detect supported local tools.
2. Create each tool-specific skill directory if needed.
3. Download `skills/design-farmer/SKILL.md` and the full phase bundle into selected targets.

### Installer options

```bash
bash install.sh [options]
```

- `--tool <name>`: install only for a specific tool (repeatable)
- `--all`: install for all detected tools (default behavior)
- `--interactive`: choose targets interactively (uses `fzf --multi` when available; otherwise numeric fallback)
- `--dry-run`: show resolved targets without writing files
- `--list-tools`: show supported tools with detection status and exit

Valid tool names: `claude`, `codex`, `amp`, `gemini`, `opencode`

Examples:

```bash
# Install only for Claude Code
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash -s -- --tool claude

# Install only for Codex and Gemini
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash -s -- --tool codex --tool gemini

# Interactively pick install targets
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash -s -- --interactive

# Preview targets only
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash -s -- --dry-run
```

### Uninstall options

`uninstall.sh` mirrors the installer surface (`--tool`, `--all`, `--interactive`, `--dry-run`, `--list-tools`) and only removes `*/skills/design-farmer` targets.

```bash
bash uninstall.sh [options]
```

- `--tool <name>`: uninstall only for a specific tool (repeatable)
- `--all`: uninstall for all detected tools (default behavior)
- `--interactive`: choose targets interactively (uses `fzf --multi` when available; otherwise numeric fallback)
- `--dry-run`: show resolved targets without deleting files
- `--list-tools`: show supported tools with detection status and exit

Valid tool names: `claude`, `codex`, `amp`, `gemini`, `opencode`

Examples:

```bash
# Uninstall only for Claude Code
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/uninstall.sh | bash -s -- --tool claude

# Uninstall only for Codex and Gemini
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/uninstall.sh | bash -s -- --tool codex --tool gemini

# Preview uninstall targets only
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/uninstall.sh | bash -s -- --dry-run
```

Supported tools:

- Claude Code
- Codex CLI
- Amp
- Gemini CLI
- OpenCode

## Manual (fallback)

```bash
mkdir -p "<tool-skill-root>/design-farmer"
curl -fsSL \
  https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/skills/design-farmer/SKILL.md \
  -o "<tool-skill-root>/design-farmer/SKILL.md"
```

Example tool roots:

- `~/.claude/skills`
- `~/.agents/skills`
- `~/.config/agents/skills`
- `~/.gemini/skills`
- `~/.config/opencode/skills`

## Troubleshooting

- If installer output says `No supported tools detected`, install one supported tool first, then re-run.
- If uninstaller output says `No supported tools detected. Nothing to uninstall.`, no supported local tool markers were found.
- If a download fails, verify network access and check `curl --version`.
- If you run `--interactive` in a non-TTY environment (for example CI), use `--tool` instead.
