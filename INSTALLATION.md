# Installation

## Marketplace (Claude Code — recommended)

Install directly from the Claude Code Marketplace for automatic installation and updates:

1. Open Claude Code settings
2. Navigate to Plugins > Marketplace
3. Search for **design-farmer**
4. Click **Install**

Marketplace installations receive automatic updates and are the recommended installation method for Claude Code users.

### Migrating from the curl installer

If you previously installed via `curl | bash`, your installation will continue to work. To migrate to the marketplace:

1. Uninstall the curl-installed version:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/uninstall.sh | bash
   ```
2. Install via the marketplace (see steps above)

Your existing `DESIGN.md` files and project configurations are preserved.

## Universal installer (all tools)

Run the installer script:

```bash
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash
```
This is the canonical lifecycle guide for installing Design Farmer, handling manual setup, troubleshooting, and optionally removing the bundle later.

The installer will:

1. Detect supported local tools.
2. Create each tool-specific skill directory if needed.
3. Download `skills/design-farmer/SKILL.md` and the full phase bundle into selected targets.

### Marketplace vs. installer

| Method | Tools | Use when |
|--------|-------|----------|
| **Marketplace** | Claude Code only | You use Claude Code and want automatic updates |
| **Installer script** | Claude Code, Codex, Amp, Gemini, OpenCode | You use multiple AI tools or prefer shell-based install |

Both methods install the same skill bundle.

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

## Manual (fallback)

Because Design Farmer ships as a multi-file bundle, manual setup must copy the entire
`skills/design-farmer/` directory rather than only `SKILL.md`.

From a local checkout of this repository:

```bash
mkdir -p "<tool-skill-root>"
cp -R "skills/design-farmer" "<tool-skill-root>/design-farmer"
```

If you are not working from a local checkout, prefer the installer script instead of trying to
download individual bundle files manually.

Example tool roots:

- `~/.claude/skills`
- `~/.agents/skills`
- `~/.config/agents/skills`
- `~/.gemini/skills`
- `~/.config/opencode/skills`

## Troubleshooting

- If installer output says `No supported tools detected`, install one supported tool first, then re-run.
- If a download fails, verify network access and check `curl --version`.
- If you run `--interactive` in a non-TTY environment (for example CI), use `--tool` instead.

## Optional removal

If you no longer need the bundle, use `uninstall.sh` for optional cleanup. It mirrors the installer surface and only removes `*/skills/design-farmer` targets.

### Uninstall options

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

Additional optional-removal troubleshooting:

- If uninstaller output says `No supported tools detected. Nothing to uninstall.`, no supported local tool markers were found.
