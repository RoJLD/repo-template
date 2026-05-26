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

## Hooks / MCP tools

(None configured by default. Add here if you wire up MCP servers like
GitNexus, GitHub, etc. The `code-intel` addon auto-appends a GitNexus
section here when applied.)

## Per-skill notes

(Add specific notes for skills you use frequently on this project.)
