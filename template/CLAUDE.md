# Claude-specific overrides for {{PROJECT_NAME}}

Most context lives in [AGENTS.md](AGENTS.md). This file holds
Claude-specific instructions and overrides only.

## Canonical agent contract

[AGENTS.md](AGENTS.md) is the canonical agent context for this project
(open standard, also read by Cursor, Codex, Sourcegraph, Factory). The
sibling [GEMINI.md](GEMINI.md) and [CODEX.md](CODEX.md) are stubs that
point back to AGENTS.md so each agent finds its expected filename.

If a fact applies to ALL agents, put it in `AGENTS.md`.
If it only applies to Claude, put it here.

## @imports (Claude Code feature)

Claude Code supports `@path/to/file` syntax in this file to import
other context. Use it instead of duplicating content :

```markdown
@AGENTS.md
@docs/roadmap.md
```

Use sparingly : >2-3 imports can dilute the active context and make
reasoning worse. Prefer ONE canonical file (AGENTS.md) and let the
agent fetch more on demand.

## Specs discipline (mandatory)

This project follows a **spec-before-plan** discipline. Before invoking
the `superpowers:writing-plans` skill (or any equivalent multi-step
planning workflow) for a non-trivial change, write or update a spec
under [`docs/specs/`](docs/specs/) first.

Full contract in [docs/specs/README.md](docs/specs/README.md). Hard
points :

- Spec required for any change touching > 1 file, introducing a new
  concept, or described by the user in 2+ sentences. NOT required for
  bug fixes / one-liners / dep bumps.
- Naming : `docs/specs/YYYY-MM-DD-<slug>.md` (creation date, immutable).
- Specs are append-only history — never delete. Amend via
  `## Update YYYY-MM-DD — <reason>` sections, or write a successor with
  `Supersedes: <old-file>`.
- Update the relevant spec in the **same commit** as the code change.

See [AGENTS.md § Specs](AGENTS.md) for the canonical rule.

## Hooks / MCP tools

(None configured by default. Add here if you wire up MCP servers like
GitNexus, GitHub, etc. The `code-intel` addon auto-appends a GitNexus
section here when applied.)

## Per-skill notes

(Add specific notes for skills you use frequently on this project.)
