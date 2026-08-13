# AI agent context for {{PROJECT_NAME}}

This file is read by AI agents (Claude, Copilot, Cursor, etc.) at the
start of every session. It's the **canonical project context** so agents
don't have to grep around to understand the structure.

## What this project is

{{PROJECT_DESCRIPTION}}

Strategic positioning : see [docs/roadmap.md § Positioning](docs/roadmap.md).

## File layout

```
.
├── src/{{PROJECT_NAME}}/    # main package
├── tests/                   # code correctness (regression, contracts)
├── validation/              # scientific correctness (textbook, recovery)
├── docs/
│   ├── roadmap.md           # strategic overview, phase status
│   ├── decisions/           # numbered ADRs
│   ├── specs/               # phase specs (YYYY-MM-DD-phase-X-name.md)
│   └── guides/              # user-facing docs
├── notes/                   # PRIVATE working notes (gitignored)
├── CHANGELOG.md             # version history (Keep a Changelog format)
└── pyproject.toml           # Python project config
```

## Common commands

```bash
pip install -e ".[dev]"     # dev setup
pytest                      # run tests
pytest validation/          # run validation (slower)
pytest -m "not slow"        # skip slow tests
ruff check src/             # lint
black src/                  # format
```

## Conventions

- **Commit messages** : Conventional Commits (`feat(scope): description`)
- **ADRs** : numbered, with `## Revisit if` section. Template :
  `docs/decisions/_template.md`
- **Specs** : `docs/specs/YYYY-MM-DD-<slug>.md` — see the **Specs**
  section below (mandatory rules, not optional).
- **Tests vs validation** : tests = code correctness ; validation =
  scientific / numerical correctness (different tolerances, slower)
- **Notes** : `notes/` is gitignored — private working notes. Promote to
  `docs/` when stable.

## Specs (mandatory before any implementation plan)

This project follows a **spec-before-plan** discipline. Before drafting
an implementation plan (e.g. via Claude's `superpowers:writing-plans`
skill, or any equivalent multi-step planning workflow), you MUST first
write or update a spec under `docs/specs/`. The full contract is in
[`docs/specs/README.md`](docs/specs/README.md). Operational summary :

- **When required** : any change touching > 1 file or > 1 module's
  public surface ; new concept / endpoint / component / data flow ;
  anything the user described in 2+ sentences of intent.
- **When not required** : bug fixes, one-line tweaks, doc fixes,
  dependency bumps.
- **Naming** : `docs/specs/YYYY-MM-DD-<slug>.md` (creation date,
  immutable).
- **Template** : copy [`docs/specs/_template.md`](docs/specs/_template.md).
- **Historicization** : specs are **append-only history**. Never delete.
  For substantive changes, either add a `## Update YYYY-MM-DD —
  <reason>` section at the bottom, OR write a successor spec with
  `Supersedes:` linking back to the original.
- **Maintenance** : when a feature changes, the relevant spec is
  updated **in the same commit / PR as the code change**. A code
  change without the spec update is an incomplete change.
- **Status field** : every spec has `Status: draft | current |
  superseded by <file> | withdrawn | stale`. Flip to `current` when the
  feature ships.

## Do's

- Read `docs/roadmap.md` § Positioning before suggesting features
- Check `docs/decisions/` for the "why" behind existing choices
- Write or update a spec **before** any non-trivial plan (see Specs
  section above — this is a hard rule, not a suggestion)
- Update the relevant spec in the same commit as the code change it
  documents
- Update CHANGELOG.md under `[Unreleased]` for any user-facing change
- Use the `slow` pytest marker for tests > 10s

## Don'ts

- Don't draft a multi-file implementation plan without writing the spec
  first (see Specs section above)
- Don't delete or silently rewrite an existing spec — amend with
  `## Update YYYY-MM-DD` or write a successor spec
- Don't add features without checking the out-of-scope appendix in roadmap.md
- Don't rewrite tests/validation/ — they exist as guard rails
- Don't commit `notes/` content (it's in .gitignore for a reason)
- Don't suppress warnings, errors, or test failures — investigate and fix

## Memory (if using Claude)

This project has a persistent memory at :
`~/.claude/projects/c--Users-rdenis-VScode-{{GITHUB_REPO}}/memory/`

Strategic decisions, scope discipline, and anti-patterns live there. Read
them at session start ; update them when a major decision is made.
