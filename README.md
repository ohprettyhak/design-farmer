# design-farmer

`design-farmer` is a skill that helps coding agents build and enforce a consistent, production-grade design system.

## Why this exists

When vibe-coding with agent-driven implementation, giving agents a clear system creates much more consistent UI outcomes.

Because of that, this skill is designed for the start of every project:

- If a design system does **not** exist, it guides creation from scratch.
- If a design system is only **partially** implemented, it identifies gaps and upgrades quality.
- Even if a design system appears production-ready, it audits consistency (especially accessibility and color usage) and pushes the result toward a higher-quality, unified standard.

In short, this skill turns design quality from "best effort" into a repeatable engineering workflow.

## Installation

### Recommended (automatic)

Run the installer script:

```bash
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash
```

The installer will:

1. Detect supported local tools.
2. Create each tool-specific skill directory if needed.
3. Download `skills/design-farmer/SKILL.md` into each detected tool.

Supported tools:

- Claude Code
- Codex CLI
- Amp
- Gemini CLI
- OpenCode

### Manual (fallback)

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

## Project Policies

- [Security Policy](SECURITY.md)
