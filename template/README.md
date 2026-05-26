# {{PROJECT_TITLE}}

> {{PROJECT_DESCRIPTION}}

[![License: {{LICENSE}}](https://img.shields.io/badge/License-{{LICENSE}}-blue.svg)](LICENSE)

## What this is

One-paragraph elevator pitch. Who it's for, what it does, why it exists.

## Install

```bash
pip install {{PROJECT_NAME}}
```

(or `git clone` + `pip install -e .` for development)

## Quick start

```python
# Minimal working example — copy this and it should run
import {{PROJECT_NAME}}
# ...
```

## Documentation

- **[Roadmap](docs/roadmap.md)** — strategic overview, phases, what's next
- **[Architecture decisions](docs/decisions/)** — numbered ADRs documenting choices
- **[Specs](docs/specs/)** — per-phase implementation specs
- **[CHANGELOG](CHANGELOG.md)** — version history

## Project layout

```
.
├── src/{{PROJECT_NAME}}/     # main package
├── tests/                    # code correctness tests
├── validation/               # scientific correctness tests (optional)
├── docs/
│   ├── roadmap.md            # strategic overview
│   ├── decisions/            # ADRs
│   ├── specs/                # phase specs
│   └── guides/               # user guides
└── notes/                    # private cahier de laboratoire (gitignored)
```

## Development

```bash
# Set up
pip install -e ".[dev]"

# Run tests
pytest

# Run validation (scientific correctness, slower)
pytest validation/
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow including
commit conventions and ADR discipline.

## License

{{LICENSE}} — see [LICENSE](LICENSE).
