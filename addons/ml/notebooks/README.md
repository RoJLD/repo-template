# {{PROJECT_TITLE}} notebook gallery

[![Open in Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/{{GITHUB_USER}}/{{GITHUB_REPO}}/main?urlpath=lab/tree/notebooks)
[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/{{GITHUB_USER}}/{{GITHUB_REPO}}/blob/main/notebooks/)

Runnable notebooks demonstrating `{{PROJECT_NAME}}` capabilities.

## One-click run

Click the Binder badge above. ~30 seconds to first cell output, no
install needed.

## Local

```bash
pip install -e ".[dev]"
jupyter lab notebooks/
```

## Notebooks

| # | Notebook | Topic |
|---|---|---|
| 01 | Quickstart | Minimal working example, ~30 seconds |
| ... | ... | (add as you create notebooks) |

## Philosophy

These notebooks ARE the documentation. They demonstrate :
1. **Pip-installable** — no separate environment
2. **Composable** — every object is an input or output of others
3. **Reproducible** — fixed seeds where appropriate
4. **Jupyter-native** — rich HTML displays where applicable
