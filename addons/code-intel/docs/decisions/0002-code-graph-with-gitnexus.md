# ADR-0002 — Use GitNexus as the code-intelligence layer

**Date** : {{YEAR}}-01-01
**Status** : ACCEPTED
**Author** : {{AUTHOR_NAME}}

## Context

This project is developed primarily with AI agents (Claude / Cursor /
Codex) as pair-programmers. Without a structural understanding of the
code, agents fall back to `grep` / `Read` over the file tree, which :

- Misses cross-file call graphs (who calls X, what does Y depend on)
- Cannot estimate **blast radius** before a refactor
- Repeats the same exploration on every session (no persistent
  graph memory)
- Scales poorly as the codebase grows past ~100 files

We need a code-intelligence layer that gives agents a *graph* view of
the codebase, exposes it via MCP, and survives across sessions.

## Decision

We adopt **GitNexus** ([github.com/abhigyanpatwari/gitnexus](https://github.com/abhigyanpatwari/gitnexus))
as the code-intelligence layer for this project.

- The daemon runs locally (`http://localhost:4747`), indexes this
  repo into a `.gitnexus/` folder next to `.git/`.
- Agents reach it via MCP at `http://localhost:4747/api/mcp`.
- The index is local-only (gitignored) ; the daemon is reused across
  all projects under `PROJECTS_ROOT`.

## Alternatives considered

1. **Pure grep / ripgrep** — no graph, no blast radius, no MCP tools.
   Rejected : doesn't scale, agents waste tokens re-exploring.
2. **Sourcegraph (self-hosted)** — heavyweight, designed for org-scale
   code search. Overkill for a solo / small-team project ; requires a
   running Postgres + indexer service per project.
3. **ctags / language servers** (LSP) — limited to one language at a
   time, no cross-file graph view, no MCP integration.
4. **Cody / Cursor's built-in index** — vendor-locked, doesn't expose
   MCP tools to other agents, no time-travel analytics.
5. **GitNexus (chosen)** — multi-language via tree-sitter, MCP-first,
   one daemon serves all projects, ships skills auto-generation,
   open-source (PolyForm-Noncommercial).

## Consequences

### Positive

- Agents have `analyze_change`, `generate_map`, and graph search/
  context/references tools — no more blind grepping for structural
  questions.
- Skills auto-generated per Leiden community land in `.claude/skills/`,
  giving Claude domain-specific context on every session.
- One daemon serves all projects under `PROJECTS_ROOT` ; zero
  per-project install.
- Time-travel analytics (churn, coupling, ownership, dissonance,
  cross-repo similarity) become available for strategic questions.

### Negative

- Requires the gitnexus daemon to be running. If it's down, agents
  must fall back to grep (and they must *know* they're degraded).
- Index goes stale after big edits. Mitigated by `.\scripts\reindex.ps1`.
- PolyForm-Noncommercial license : commercial use of *gitnexus
  outputs* (wikis, graphs shipped as product features) may need
  upstream clarification.

### Neutral

- `.gitnexus/` lives next to `.git/` ; gitignored, so no commit
  pollution.
- Adds 3 files to the repo : reindex script, ADR (this), and two
  example JSON templates.

## Revisit if

- GitNexus upstream changes license to something incompatible with
  our usage.
- The daemon proves unreliable in practice (crashes, stale index,
  reindex takes > 5 min consistently).
- A built-in MCP code-graph emerges in Claude / Cursor that replaces
  the external daemon (e.g. Anthropic ships an official one).
- The project shrinks below ~50 files — at that scale, grep beats the
  graph.
- We start shipping gitnexus outputs commercially → re-evaluate license.

## References

- GitNexus upstream : https://github.com/abhigyanpatwari/gitnexus
- Local deployment setup : `../gitnexus/README.md`
- MCP protocol : https://modelcontextprotocol.io/
- AGENTS.md § "Code-graph context (GitNexus)" — operational protocol
- CLAUDE.md § "GitNexus MCP integration" — Claude-specific tool-use
