# Addon : code-intel

Wires the project into **GitNexus** — a graph code-intelligence MCP
server you (probably) already run locally at
`C:\Users\rdenis\VScode\gitnexus\`. Lets Claude / Cursor / Codex query
a knowledge graph of this codebase instead of grepping blindly.

## When to add it

- You use Claude / Cursor / Codex on this project regularly.
- The project lives under a folder mounted by gitnexus's `PROJECTS_ROOT`
  (default for Robin : `C:/Users/rdenis/VScode/`).
- You want MCP-driven `analyze_change`, `generate_map`, and the auto-
  installed agent skills (Exploring, Debugging, Impact Analysis,
  Refactoring) on this codebase.

When **NOT** to add :
- Tiny one-file experiments. Not worth indexing.
- Projects not on a `PROJECTS_ROOT`-mounted path.
- Project graph would be < ~50 nodes (gitnexus shines on graphs of
  hundreds-to-thousands of nodes).

## What it adds (no daemon, no dependency)

| File | Purpose |
|---|---|
| `.gitignore.append` | Ignores `.gitnexus/` (the local index next to `.git/`) |
| `AGENTS.md.append` | Adds a "Code-graph context" section so agents know to use MCP |
| `CLAUDE.md.append` | Adds MCP endpoint + tool-use protocol for Claude |
| `Makefile.append` | Targets : `reindex`, `reindex-force`, `graph-status` |
| `scripts/reindex.ps1` | Forced re-analysis wrapper (delegates to gitnexus's reindex) |
| `docs/decisions/0002-code-graph-with-gitnexus.md` | Pre-filled ADR documenting the contract + revisit triggers |
| `.claude/skills/.gitkeep` | Placeholder for `gitnexus analyze --skills`-generated `SKILL.md` files |
| `.gitnexus-domains.json.example` | Template for the dissonance feature (declared domains vs detected communities) |
| `.gitnexus-policy.json.example` | Template for cross-repo similarity policy (isolation_required, allow_merge_with) |

**Zero runtime dependencies** added to the project itself. The
gitnexus daemon is global ; this addon just makes the project a
well-behaved client.

## What you need running on the host

```powershell
# One-time : ensure gitnexus daemon is up
cd C:\Users\rdenis\VScode\gitnexus
.\start.ps1
# Verifies : http://localhost:4747/api/health → 200
```

The daemon auto-mounts everything under `PROJECTS_ROOT`. Your new
project becomes reachable as `/data/projects/<your-folder-name>`
inside the container.

## First index (after bootstrap)

```powershell
# From your new project root
.\scripts\reindex.ps1
# Or via Make :
make reindex
```

Index lives at `.gitnexus/` (gitignored). After indexing, Claude can
hit `http://localhost:4747/api/mcp` and use :
- `analyze_change` — blast radius before refactor
- `generate_map` — mermaid architecture diagrams
- search / context / references tools

## Generate repo-specific skills

```powershell
# Inside the gitnexus container
docker exec gitnexus gitnexus analyze /data/projects/<your-folder> --skills
```

Drops one `SKILL.md` per detected Leiden community into
`.claude/skills/`. Claude then auto-loads them.

## Integration with other addons

- **`devcontainer`** : add `forwardPorts: [4747, 4173]` to
  `.devcontainer/devcontainer.json` so the container can reach the
  host daemon. (Manual edit ; not auto-applied.)
- **`web`** : no interaction.
- **`ml`** : gitnexus indexes notebooks too — notebook ↔ src/ call
  chains become visible.
- **`academic`** : pair well — `generate_map` mermaid diagrams can
  be embedded in mkdocs pages.

## License note

GitNexus upstream is **PolyForm-Noncommercial-1.0.0**. Using it as a
local dev tool on your own code is fine. If you ship gitnexus
outputs (graphs, wiki, skills) as part of a *commercial* product,
confirm with the upstream license terms.
