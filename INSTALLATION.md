# Installation

## Recommended (automatic)

Run the installer script:

```bash
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash
```

The installer will:

1. Detect supported local tools.
2. Create each tool-specific skill directory if needed.
3. Download `skills/design-farmer/SKILL.md` and the full phase bundle into each detected tool.

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
- If a download fails, verify network access and check `curl --version`.
