# addon : ml

Patterns for machine-learning / scientific-research projects.

## When to add

Your project :
- Trains models, fits parameters, or runs statistical inference
- Has notebooks for exploration / demos
- Needs scientific correctness validation (textbook references, recovery
  on synthetic data) beyond regular unit tests
- Ships example datasets or canonical workflows

If yes to ≥ 2 of these → add this addon.

## What it adds

| Path | Purpose |
|---|---|
| `validation/` (already in core tier-2, this version is more developed) | Scientific correctness suite separate from `tests/` |
| `notebooks/` | Runnable Jupyter examples with Binder config |
| `notebooks/README.md` | Gallery index with suggested learning path |
| `examples/` | Canonical example datasets + YAML configs |
| `binder/requirements.txt` | mybinder.org build config for one-click cloud notebooks |
| `binder/postBuild` | Install hook for editable repo install |
| `binder/runtime.txt` | Python version pin for Binder |

## Why this works (lessons from hmm_studio)

- **Notebook gallery ≫ web academy** : researchers live in Jupyter ;
  meeting them there is free distribution
- **`validation/` separate from `tests/`** : different tolerances, different
  cadence (fast tests on every commit, validation on releases)
- **Binder + Colab badges** : zero-install demo for new users — critical
  for academic adoption

## Integration with core template

- `validation/README.md` is already in tier-2 core — this addon develops it
- The `notebooks/` folder is added at the project root
- Update root README.md after bootstrap to add a "Notebook gallery" section
- Add `[ml]` optional dependency group to `pyproject.toml` if your ML deps
  are heavy (pymc, torch, etc.) — keep core install lean

## Files

See files in this folder. Bootstrap script merges them into the project
root.
