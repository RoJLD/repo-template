# addon : academic

Patterns for academic / research projects that get cited in papers,
need a documentation site, or target the scientific community.

## When to add

Your project :
- Will be cited in academic papers (you want a `CITATION.cff`)
- Needs a polished documentation site (mkdocs / sphinx)
- Reproduces published results / benchmarks
- Has a research narrative beyond the code

## What it adds

| File | Purpose |
|---|---|
| `CITATION.cff` | Machine-readable citation metadata (GitHub auto-renders "Cite this repository" button) |
| `mkdocs.yml` | Material-themed doc site config |
| `docs/index.md` | Doc site homepage (separate from README) |
| `docs/papers/README.md` | Reading list / related work index |
| `.github/workflows/docs.yml` | Auto-deploy docs to GitHub Pages |

## Why this works

- `CITATION.cff` makes the project citable in 1 click — critical for
  academic adoption
- mkdocs-material is the de-facto standard for Python project docs
  (used by FastAPI, Pydantic, etc.)
- `docs/papers/` accumulates the reading list — saves "wait, why did we
  choose method X again ?" debates 6 months later

## Integration with core template

- `CITATION.cff` is also in `tier-3-additions/` — this addon adds it
  earlier (tier-2) for projects with academic intent
- `mkdocs.yml` at root, doc site source goes under `docs/`
- The CI workflow auto-publishes to `gh-pages` branch on push to main
