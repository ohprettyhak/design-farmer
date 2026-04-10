# Internal Project Contracts

This directory stores internal implementation contracts and planning records for repository work.
These files are written for maintainers and contributors planning or tracking changes inside this
repository. They are not the primary entrypoint for end users installing or using Design Farmer.

## Documentation Layers

- **User-facing repository docs** live at the repository root:
  - `README.md` and localized `README*.md` files for overview and quick-start guidance
  - `INSTALLATION.md` for the install lifecycle, manual setup, troubleshooting, and optional removal
- **Internal project contracts** live in this directory:
  - `docs/project-*.md` for scoped implementation contracts created before work begins
  - `docs/project-template.md` for creating new contract files
- **Skill-maintainer references** live under `skills/design-farmer/docs/`:
  - Companion documents for maintaining the skill bundle and phase system

## File Pattern

- `project-template.md` defines the required structure for new internal project contracts.
- `project-<id>.md` captures the scope, architecture, risks, and acceptance criteria for one
  repository change or subsystem.

When updating contributor-facing behavior or user workflows, update the canonical root-level docs
in the same change instead of duplicating that guidance in `docs/project-*.md` files.
