# Validation suite

Scientific / model correctness tests, **separate from** `tests/`.

## Why a separate suite ?

`tests/` answers : "does the code work as written ?" (regressions,
contracts, edge cases). Strict tolerances (e.g. `atol=1e-12`), fast.

`validation/` answers : "does the math give the right answer ?"
(textbook references, statistical recovery on synthetic data, numerical
stability stress tests). Looser tolerances (statistical), slower.

Mixing them dilutes both : code tests get flaky from numerical
tolerances, validation tests get hidden in fast-suite output.

## Running

```bash
pytest validation/                          # all validation tests
pytest validation/test_recovery.py -v       # one layer
pytest validation/ -m "not slow"            # skip slow ones
```

The validation suite is **not** run by default `pytest` (which uses
`testpaths = ['tests']` in `pyproject.toml`). Run explicitly when :
- Releasing a new version
- Bumping a core dependency (numpy, scipy, etc.)
- Adding a new feature that touches the math

## Layers (typical)

| Layer | Description | Tests |
|---|---|---|
| V.1 | Cross-check against a trusted reference implementation | TODO |
| V.2 | Recovery on synthetic data (loi des grands nombres) | TODO |
| V.3 | Textbook canonical problems with known answers | TODO |
| V.4 | Numerical stability stress (long sequences, edge cases) | TODO |

Delete this README if your project doesn't need scientific validation.
