# Repo template — Robin's opinionated project skeleton

A battle-tested project structure extracted from real Robin Denis projects
(`Tools/hmm_studio`, `Experiment.Crypto.2026S1.RobinDenis`, `gitnexus`,
`plane`). Not "the Gemini-best-practices checklist" — it's what actually
worked across multiple solo / collaborative projects from 2024 through
2026.

## Philosophy

**Compose, don't copy.** A prototype shouldn't carry CODEOWNERS +
SECURITY.md ceremony ; a published OSS library needs them. A web service
needs Docker + start scripts ; a pure library doesn't. The template ships
two orthogonal dials :

- **Tier (1 / 2 / 3)** — linear discipline maturity (how much
  process / governance / paperwork).
- **Addons** — orthogonal capability packs you mix and match
  (`ml`, `web`, `academic`, `devcontainer`, `supply-chain`, `infra`).

A real project picks a tier **and** zero-or-more addons. To make this
ergonomic, the most common combinations are pre-baked as named
**recipes**.

```
project = tier (1|2|3) + addons[*]
```

## Tiers — discipline dial

| Tier | When to use | What it adds |
|---|---|---|
| **1 — Prototype** | Throwaway experiment, < 1 week lifespan | README, .gitignore, src/, tests/, LICENSE — no CHANGELOG, ADRs, specs, validation, notes |
| **2 — Tool** (default) | Solo project that might grow, private repo | + CHANGELOG, ADRs, specs, roadmap, `validation/`, `notes/`, CONTRIBUTING |
| **3 — OSS** | Public-facing, multiple contributors | + CODE_OF_CONDUCT, SECURITY, CODEOWNERS, CITATION.cff |

Tiers are **monotonic** : tier 3 ⊃ tier 2 ⊃ tier 1.

## Addons — capability dial

| Addon | When to add | What it adds |
|---|---|---|
| **`ml`** | Notebooks, gallery, reproducible experiments | `notebooks/`, `examples/`, `binder/` (mybinder.org config), Jupyter deps in `pyproject.toml [dev]` |
| **`web`** | Service with UI / API / DB | `Dockerfile`, `docker-compose.yml`, `start.ps1` / `start.bat`, `stop.ps1` / `stop.bat`, `.dockerignore` |
| **`academic`** | Doc site + paper citations | `mkdocs.yml` (material theme), `docs/papers/`, `CITATION.cff`, GH Action to deploy to gh-pages |
| **`devcontainer`** | Zero-friction collaborator onboarding (Codespaces / VS Code Remote) | `.devcontainer/devcontainer.json` + Dockerfile + postCreate script |
| **`supply-chain`** | OSS hygiene : SBOM + dep updates + scorecard | SBOM workflow (CycloneDX), Dependabot config, OpenSSF Scorecard workflow |
| **`infra`** | Project ships Terraform / k8s / CloudFormation | Checkov IaC-scan workflow, `infra/` layout, `.gitignore.infra` |
| **`code-intel`** | Project pair-programmed with Claude / Cursor, wants a code graph | GitNexus MCP wiring : ADR, `AGENTS.md` + `CLAUDE.md` blocks, `make reindex` target, `.gitnexus/` ignored, domain + policy templates |

Addons are **independent** — adding `web` doesn't force `devcontainer`,
adding `ml` doesn't force `academic`. They merge non-destructively onto
the tier skeleton.

## Recipes — pre-baked combinations

The 8 most common project profiles are pre-named in `recipes/*.json` so
you don't have to remember the combo :

| Recipe | Tier | Addons | Example |
|---|---|---|---|
| `prototype` | 1 | — | Throwaway experiment |
| `private-tool` | 2 | — | Default solo tool |
| `ai-pair-programming` | 2 | `code-intel`, `devcontainer` | Solo project optimised for Claude pair-programming |
| `ml-research` | 2 | `ml`, `academic`, `code-intel` | hmm_studio core, crypto experiments |
| `web-service` | 2 | `web`, `devcontainer` | gitnexus, hmm_studio web layer |
| `oss-library` | 3 | `supply-chain` | plane-like public libraries |
| `academic-library` | 3 | `academic`, `supply-chain` | Citable Python package |
| `full-stack-research` | 3 | `ml`, `academic`, `web`, `devcontainer`, `supply-chain`, `code-intel` | hmm_studio (magnum opus) |
| `cloud-deployment` | 2 | `web`, `devcontainer`, `infra`, `supply-chain` | SaaS shipped with Terraform |

See [recipes/README.md](recipes/README.md) for the full table.

## Decision tree

```
Is this a one-shot script / experiment ?
├── YES → recipe: prototype
└── NO ↓

Will external people see this code ?
├── NO  ↓
│   ├── notebooks / models / experiments       → ml-research
│   ├── web service / UI / API                 → web-service
│   ├── cloud-hosted with IaC                  → cloud-deployment
│   └── everything else                        → private-tool
│
└── YES ↓
    ├── library on PyPI                         → oss-library
    ├── citable academic library                → academic-library
    └── full research project (notebooks + UI)  → full-stack-research
```

When in doubt : start with `private-tool` and add addons as needs emerge.

## How to use

```powershell
# One-shot with a recipe (the easy path)
.\bootstrap.ps1 `
    -Name "my-engine" -Title "My Engine" `
    -Description "HMM toolkit." `
    -Recipe "ml-research"

# Or compose manually
.\bootstrap.ps1 `
    -Name "my-lib" -Title "My Lib" `
    -Description "Public lib." `
    -Tier 3 -Addons "supply-chain,academic"

# Or just defaults (tier 2, no addons)
.\bootstrap.ps1 `
    -Name "my-tool" -Title "My Tool" `
    -Description "Does X for Y."
```

See [BOOTSTRAP.md](BOOTSTRAP.md) for the manual walkthrough and the
placeholder cheat sheet.

## What's in the box

```
repo-template/
├── README.md              # This file — philosophy + tiers + addons + recipes
├── BOOTSTRAP.md           # Concrete "create new project" guide
├── PATTERNS.md            # Field guide — when to apply each pattern
├── bootstrap.ps1          # PowerShell bootstrap script
├── template/              # Tier-2 base skeleton
├── tier-3-additions/      # Layered on top when -Tier 3
├── addons/
│   ├── ml/                # Notebooks + Binder gallery
│   ├── web/               # Docker compose + start/stop scripts
│   ├── academic/          # mkdocs + papers + GH Pages deploy
│   ├── devcontainer/      # VS Code / Codespaces dev environment
│   ├── supply-chain/      # SBOM + Dependabot + OpenSSF Scorecard
│   ├── infra/             # Checkov IaC scanning + infra/ layout
│   └── code-intel/        # GitNexus MCP wiring (ADR + AGENTS/CLAUDE blocks + reindex)
└── recipes/               # Pre-baked tier+addon JSON profiles
```

## Lineage — what fed this template

| Source project | Patterns contributed |
|---|---|
| `Tools/hmm_studio` | ADR with revisit-if, dated specs (`YYYY-MM-DD-phase-X-name`), roadmap as living strategic doc, `validation/` separate from `tests/`, CHANGELOG Keep-a-Changelog, CITATION.cff, ml + academic addons |
| `Experiment.Crypto.2026S1.RobinDenis` | `notes/` gitignored cahier de laboratoire, `experiments/`, `configs/`, Makefile one-liners, ml addon |
| `gitnexus` | INVENTORY.md (codebase overview for AI agents), ROADMAP.md at root, web addon (Docker compose + start scripts) |
| `plane` | Tier-3 OSS additions : CODEOWNERS, CODE_OF_CONDUCT, SECURITY, CONTRIBUTING |
| **All four** | `AGENTS.md` + `CLAUDE.md` AI agent context |

## Why this beats a flat checklist

The original Gemini "best practices" list dumped everything into one
pile : SBOM, IaC scanning, DevContainers, CODE_OF_CONDUCT, ADRs,
specs, CITATION, validation, notes... Done at the start, that's 20
files of ceremony before line 1 of real code — and most of them
don't apply to *your* project.

The composable model says : tiers handle process maturity (1/2/3),
addons handle domain (web / ml / academic / IaC). Pick what fits.

> **Discipline scales with project lifespan ; capabilities scale with
> project domain.** Match each dial independently. A prototype dies if
> you add too much ceremony ; a real tool dies if you skip the
> discipline ; an OSS lib dies if it's missing the supply-chain stuff
> downstream users now demand.
