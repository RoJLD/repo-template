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
- **Specs** : `docs/specs/YYYY-MM-DD-phase-X-name.md`
- **Tests vs validation** : tests = code correctness ; validation =
  scientific / numerical correctness (different tolerances, slower)
- **Notes** : `notes/` is gitignored — private working notes. Promote to
  `docs/` when stable.

## Do's

- Read `docs/roadmap.md` § Positioning before suggesting features
- Check `docs/decisions/` for the "why" behind existing choices
- When adding a new feature, follow the ADR + spec pattern if it's > 1 day work
- Update CHANGELOG.md under `[Unreleased]` for any user-facing change
- Use the `slow` pytest marker for tests > 10s

## Don'ts

- Don't add features without checking the out-of-scope appendix in roadmap.md
- Don't rewrite tests/validation/ — they exist as guard rails
- Don't commit `notes/` content (it's in .gitignore for a reason)
- Don't suppress warnings, errors, or test failures — investigate and fix

## Memory (if using Claude)

This project has a persistent memory at :
`~/.claude/projects/c--Users-rdenis-VScode-{{GITHUB_REPO}}/memory/`

Strategic decisions, scope discipline, and anti-patterns live there. Read
them at session start ; update them when a major decision is made.
