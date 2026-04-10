# design-farmer

[![Skill Quality](https://github.com/ohprettyhak/design-farmer/actions/workflows/skill-quality.yml/badge.svg)](https://github.com/ohprettyhak/design-farmer/actions/workflows/skill-quality.yml)
[![Last Commit](https://img.shields.io/github/last-commit/ohprettyhak/design-farmer/main)](https://github.com/ohprettyhak/design-farmer/commits/main/)
[![Latest Release](https://img.shields.io/github/v/release/ohprettyhak/design-farmer?sort=semver)](https://github.com/ohprettyhak/design-farmer/releases)

**English** | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md)

> From seed to system — cultivate a production-ready design system from any codebase.

`design-farmer` is a skill for coding agents that analyzes your repository, extracts existing design patterns, and grows them into a structured, accessible, OKLCH-native design system with tokens, components, tests, and documentation.

## Why this exists

When vibe-coding with AI agents, design consistency is the first thing that breaks. Colors drift, spacing becomes arbitrary, and dark mode is an afterthought. Giving agents explicit design constraints produces dramatically more consistent UI — but building those constraints by hand defeats the purpose.

Design Farmer automates that entire process. It reads your codebase, understands what you already have, and builds (or upgrades) a production-grade design system around it. No manual token files, no copy-pasted color palettes, no guessing.

## What it does

Design Farmer works in phases, adapting to your project's current state:

| Starting point | What happens | Result |
|---|---|---|
| **No design system** | Discovers colors/spacing in code, converts to OKLCH, creates token hierarchy | Primitive + semantic tokens, contrast-validated color scales |
| **Partial system** | Audits existing tokens, identifies gaps (states, roles, themes) | Complete semantic coverage without breaking existing references |
| **Missing interactive components** | Builds accessible Button, Input, Select, Dialog with keyboard/focus behavior | Consistent a11y components with interaction tests |
| **Light-only theme** | Generates dark theme via OKLCH lightness/chroma adjustments | Dual-theme system from a single semantic contract |
| **"Production-ready" claim** | Runs multi-reviewer verification, finds drift and token misuse | Evidence-backed completion status with remediation notes |

The full pipeline covers: preflight detection, discovery interview, repository analysis, pattern extraction with OKLCH conversion, visual preview, architecture design, theme system, DESIGN.md generation, token implementation, component library, Storybook integration, multi-reviewer verification, live visual QA, documentation, app integration, and release readiness.

## What you get

- **OKLCH color system** — perceptually uniform scales with automatic contrast validation
- **Token hierarchy** — primitives, semantics, and component-level tokens in a consistent structure
- **Accessible components** — keyboard navigation, focus management, ARIA states built in
- **Dual-theme support** — light and dark from the same token contract
- **DESIGN.md** — machine-readable design decisions as a persistent source of truth
- **Verification evidence** — multi-angle review with explicit pass/fail criteria, not "looks good" approvals

<img src="assets/storybook-components.png" alt="Component gallery built by Design Farmer" width="100%" />

The screenshot above was built from a **greenfield project** — no existing tokens, components, or design decisions. When your repository already has partial implementations (some components, color variables, a style guide, etc.), Design Farmer picks up where you left off and produces significantly more refined results.

> [!TIP]
> **Want even better results?** Drop a [`DESIGN.md`](https://github.com/VoltAgent/awesome-design-md) into your project root before running Design Farmer.
> - Generate one with [Stitch](https://stitch.withgoogle.com), or
> - Grab a pre-built one from [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) — 58+ design systems extracted from real sites (Vercel, Linear, Stripe, etc.)

## Installation

### Claude Code — Marketplace (recommended)

Install directly from the Claude Code Marketplace for automatic updates:

1. Open Claude Code settings and go to **Plugins → Marketplace**.
2. Search for **design-farmer** and click **Install**.

### All tools — curl installer

```bash
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash
```

Detects and installs into **Claude Code**, **Codex CLI**, **Amp**, **Gemini CLI**, and **OpenCode**.

See [INSTALLATION.md](INSTALLATION.md) for selective install flags (`--tool`, `--interactive`, `--dry-run`), manual setup, troubleshooting, and optional removal.

## Documentation

- [Installation guide](INSTALLATION.md) — canonical install lifecycle reference, including manual setup, troubleshooting, and optional removal.
- [Canonical skill spec](skills/design-farmer/SKILL.md) — runtime instruction file.

For maintainers and contributors:

- [Internal project contracts](docs/README.md) — repository implementation contracts and planning records.
- [Phase index](skills/design-farmer/docs/PHASE-INDEX.md) — compact execution map for maintainers.
- [Quality gates](skills/design-farmer/docs/QUALITY-GATES.md) — verification and release-readiness criteria.
- [Maintenance guide](skills/design-farmer/docs/MAINTENANCE.md) — anti-drift and update workflow.
- [Examples gallery](skills/design-farmer/docs/EXAMPLES-GALLERY.md) — scenario-based before/after outcomes and phase mapping.

## Contributing

- [Contributing Guide](CONTRIBUTING.md)
