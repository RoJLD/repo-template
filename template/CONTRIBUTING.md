# Contributing to {{PROJECT_NAME}}

## Setting up

```bash
git clone https://github.com/{{GITHUB_USER}}/{{GITHUB_REPO}}.git
cd {{GITHUB_REPO}}
pip install -e ".[dev]"
pytest
```

## Workflow

1. **Read the roadmap** first : [docs/roadmap.md](docs/roadmap.md) tells
   you what's in flight and what's deliberately out of scope.
2. **Read the relevant ADRs** : [docs/decisions/](docs/decisions/)
   documents the *why* behind architectural choices. If your contribution
   touches one of these areas, understand the rationale before proposing
   changes.
3. **Open an issue first** for non-trivial changes. Don't surprise the
   maintainer with a 500-line PR.
4. **Write tests** for new behavior, in `tests/`. Scientific / numerical
   correctness goes in `validation/` (separate suite).
5. **Commit messages** follow [Conventional Commits](https://www.conventionalcommits.org/) :
   `<type>(<scope>): <description>`. Types : `feat`, `fix`, `docs`,
   `style`, `refactor`, `test`, `chore`, `perf`, `build`, `ci`.
6. **Update CHANGELOG.md** under `[Unreleased]` with your change.

## Decision-level changes

If your contribution touches an architectural decision documented in
`docs/decisions/`, you must :
1. Read the ADR's "Revisit if" section to confirm your trigger applies.
2. Either supersede the ADR with a new one (preferred) or amend it.
3. Document the change in the new ADR's "Context" section.

## Code style

- Python : `ruff check` + `black` (configured in `pyproject.toml`)
- Type hints encouraged
- Docstrings on public functions
- No emoji in code or commits (use only if user explicitly asks)

## Tests

```bash
pytest                          # unit + integration tests
pytest validation/              # scientific correctness suite (slower)
pytest -m "not slow"            # skip @slow tests for quick feedback
```

## Releasing

(Maintainer only.) Tag with `v{semver}`, push, let CI build + publish.
