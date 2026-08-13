# Patterns — field guide

Reusable patterns extracted from real Robin projects, with the
"why this works" explained. Refer back here when you need to decide
*how* to do something in a project — and *which addon* gives you that
capability ready-made.

## How the template composes

This template has **three layers** that stack non-destructively :

1. **Tier base** (`template/`) — the universal foundation.
2. **Tier 3 additions** (`tier-3-additions/`) — overlay when going OSS.
3. **Addons** (`addons/<name>/`) — orthogonal capability packs you opt in.

**File-merge convention** : when an addon ships a file named
`foo.bar.append`, the bootstrap script *appends* it to the existing
`foo.bar` instead of overwriting (creates the file if absent). This
lets addons extend `AGENTS.md`, `CLAUDE.md`, `.gitignore`, `Makefile`
etc. without each addon clobbering the previous one's changes. Used by
`code-intel` to inject MCP wiring into `AGENTS.md` / `CLAUDE.md`.

Every pattern below is tagged with **where it lives** :
- 🧱 *base* — in the tier-2 skeleton, always present
- ⬆️ *tier-3* — only when going OSS
- 🧩 *addon: X* — only if you opted into addon X

---

## Discipline patterns (the high-value foundation)

### 🧱 Pattern : ADR with revisit-if section

**Source** : `Tools/hmm_studio/docs/decisions/`

Every architecturally significant decision goes in a numbered ADR file :
`docs/decisions/0001-name-of-decision.md`. The structure :

```markdown
# ADR-NNNN — One-line title

**Date** : YYYY-MM-DD
**Status** : ACCEPTED / SUPERSEDED-BY-NNNN / DEPRECATED

## Context
What pressure / decision-forcing situation triggered this.

## Decision
What we decided. Be concrete and committed.

## Alternatives considered
Numbered list, each with one-paragraph "why rejected".

## Consequences
What changes downstream (positive AND negative).

## Revisit if
Concrete events that would trigger re-opening this decision
(e.g. "if X library deprecates Y", "if we get > 100 users",
"if the regression test starts failing").
```

**Why this works** : the "Revisit if" section is the killer feature. It
turns a static "we decided X" into a living decision with explicit
expiration conditions. Six months later, grep ADRs for revisit triggers
and re-evaluate only the ones whose triggers fired.

**When to use** : every decision that would take > 30 minutes to
re-debate six months from now.

### 🧱 Pattern : Spec dated, historicized, mandatory before any plan

**Source** : `Tools/hmm_studio/docs/specs/2026-05-22-phase-a10-gmm-nhmm.md`,
formalized in the workspace `CLAUDE.md` "Specs discipline" section
(2026-05-26).

When a change needs implementation planning beyond a 1-line description :

```
docs/specs/YYYY-MM-DD-<slug>.md
```

For phase-driven projects, include the phase ID in the slug
(`2026-05-22-phase-a10-gmm-nhmm.md`). Otherwise just a descriptive
kebab-slug. The date is the spec **creation** date (immutable, even
when the spec is revised). The ship date goes in CHANGELOG instead.

**Mandatory before drafting any plan**. The full contract lives in
`docs/specs/README.md` (shipped by tier-2+ bootstrap). Operational
summary :

- **Required** when : change touches > 1 file / introduces a new
  concept / user described it in 2+ sentences / about to invoke a
  multi-step planning skill (`superpowers:writing-plans`,
  `brainstorming`, `subagent-driven-development`).
- **Not required** for : bug fixes, one-line tweaks, doc fixes,
  dependency bumps.

**Structure** (see `template/docs/specs/_template.md` for the canonical
form) :

1. Status (`draft / current / superseded by <file> / withdrawn / stale`)
2. Context + motivation
3. Goal (one paragraph "what done looks like")
4. State of the art / alternatives considered (each with *why
   rejected* — this is the part future-you needs)
5. Design / architecture (concrete : API surface, data shapes)
6. Limits / edge cases
7. Tests minimum (named)
8. Definition of "done" (checklist, ends with "flip status to
   `current`")
9. Out-of-scope (anti-scope-creep)
10. `## Update YYYY-MM-DD` sections (append-only, for amendments)

**Lifecycle / historicization** :

- Specs are **append-only history**. Never delete.
- Substantive amendment → add `## Update YYYY-MM-DD — <reason>` section
  at the bottom of the existing spec. Body above stays intact.
- Genuine redesign → write a successor spec with `Supersedes:
  <old-file>` ; flip the old one's status to
  `superseded by <new-file>` ; leave its body intact.
- When the feature ships, flip status to `current`. When it's later
  ripped out or redesigned, do NOT delete the spec — flip status to
  `superseded by ...` or `withdrawn` so the rationale survives.

**Maintenance contract** : when a feature changes, the relevant spec
is updated **in the same commit as the code change**. Same rule as
CHANGELOG and ROADMAP. A code change without the spec update is an
incomplete change.

**Why this works** : specs become the project's durable design
documentation rather than throwaway planning artifacts. Six months
later, you can read the specs directory in chronological order and
reconstruct every design decision — including the rejected
alternatives, which are usually invisible in commit history.

**When to use** : every tier-2+ project. Tier-1 prototypes deliberately
skip this — the bootstrap script trims `docs/specs/` for them.

### 🧱 Pattern : Roadmap as living strategic doc

**Source** : `Tools/hmm_studio/docs/roadmap.md`

`docs/roadmap.md` is **distinct from** CHANGELOG (history of what shipped)
and from `docs/specs/` (per-phase planning details). The roadmap is the
**strategic overview** :

- **Vision** : 1 paragraph
- **Strategic positioning** : the wedge, the moat, what we DON'T do
- **Overview table** : every phase with status (SHIPPED / PLANNED /
  SPEC ONLY / DEFERRED / GATED), dependencies, effort estimate
- **Per-phase details** : 1-2 paragraphs each, linking to specs
- **Out-of-scope appendix** : explicit list of rejected things, with
  revisit conditions

**Why this works** : the table doubles as a status dashboard. The
out-of-scope appendix is the anti-scope-creep tool — every "should we
also do X?" gets answered by "no, it's in the out-of-scope list with
this justification".

**When to use** : any project with more than 3 phases.

### 🧱 Pattern : `validation/` separate from `tests/`

**Source** : `Tools/hmm_studio/validation/`

`tests/` = code correctness (regressions, contracts, edge cases).
`validation/` = scientific / model correctness (textbook references,
recovery on synthetic, numerical stability).

The two suites run separately. Tests run in CI on every commit ;
validation runs on releases or when bumping core dependencies.

**Why this works** : different tolerances, different audiences. Code
tests use `atol=1e-12` strict. Validation tests use statistical
tolerances (e.g. "recover means within 0.5 σ") and are inherently
slower / sometimes flaky. Mixing them dilutes both.

**When to use** : scientific / numerical projects. Skip for pure
CRUD / web projects.

### 🧱 Pattern : `notes/` (gitignored) for cahier de laboratoire

**Source** : `Experiment.Crypto.2026S1.RobinDenis/notes/`

A folder for **private working notes** :
- `notes/decisions.md` — private ADR draft pad
- `notes/journal.md` — daily lab journal
- `notes/ideas.md` — brain-dump
- `notes/kanban_dev.md`, `kanban_experiments.md` — todo lists
- `notes/cahier_laboratoire.md` — scientific protocol records

**Key** : `notes/` is in `.gitignore` always. The discipline :
- Capture freely in `notes/`
- Promote to `docs/` when a decision is final and shareable

### 🧱 Pattern : `AGENTS.md` + `CLAUDE.md` for AI assistants

**Source** : all four Robin projects

Two files at root :
- `AGENTS.md` — canonical project context for AI agents
- `CLAUDE.md` — Claude-specific overrides (MCP instructions, custom tools)

**Recommended minimum content** :
- 1-paragraph "what this project is"
- File layout summary (which folder = what)
- Common commands (test, build, lint)
- Conventions (commit format, ADR pattern, validation/ vs tests/)
- Anti-patterns (things this project does NOT do)

### 🧱 Pattern : Claude memory persistence

**Source** : Robin's personal `~/.claude/projects/{path-slug}/memory/`

For projects where Claude is used regularly across sessions :

```
~/.claude/projects/c--Users-rdenis-VScode-{ProjectName}/memory/
├── MEMORY.md                 # Index
├── positioning.md            # Strategic framing
├── scope_discipline.md       # What we don't do
└── ...
```

Each memory file has YAML frontmatter (name, description, type) + a
markdown body documenting a `feedback` / `project` / `user` / `reference`
fact that should persist across sessions.

### 🧱 Pattern : Conventional Commits + Keep-a-Changelog

**Source** : `Tools/hmm_studio/CHANGELOG.md`

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) :
`<type>(<scope>): <description>` where type ∈ `feat | fix | docs | style |
refactor | test | chore | perf | build | ci`.

`CHANGELOG.md` follows [Keep a Changelog](https://keepachangelog.com/) :
sections `Added / Changed / Deprecated / Removed / Fixed / Security`
under each version.

### 🧱 Pattern : Phase IDs (A, B, C, V, E, I, Z)

**Source** : `Tools/hmm_studio/docs/roadmap.md`

Phases are letter-prefixed with stable IDs :
- `A` = core engine / library
- `B` = UI / web layer
- `C` = advanced visualizations / polish
- `D` = migration of an existing system
- `V` = validation suite
- `E` = academy / educational content
- `I` = integrations (Jupyter, sklearn, PyMC bridges)
- `Z` = cross-cutting (CI, license, doc site)

**Why** : letters carry no implicit ordering (vs numbers, which read as
priority). The roadmap can list them in logical order, separate from
shipping order.

---

## ⬆️ Tier-3 additions (going public)

When `-Tier 3`, these files are layered on top of the tier-2 skeleton :

### `CODE_OF_CONDUCT.md`
Standard Contributor Covenant template :
https://www.contributor-covenant.org/

### `SECURITY.md`
Vulnerability reporting policy :
- Email for private disclosure
- Supported versions
- Response timeline (e.g. "we acknowledge within 7 days")

### `CODEOWNERS`
Auto-assigns reviewers based on path :
```
* @your-github-username
docs/specs/* @your-coauthor
```

### `CITATION.cff`
For academic projects — let users cite your code in papers.

### `.github/ISSUE_TEMPLATE/` + `PULL_REQUEST_TEMPLATE.md`
Pre-fill bug reports and PRs.

---

## 🧩 Addon packs

Each addon is a self-contained folder under `addons/<name>/`. The
bootstrap script merges them into the destination tree
non-destructively.

### 🧩 Addon : `ml` — notebook gallery + Binder

**Adds** : `notebooks/` with gallery index, `examples/` for scripts,
`binder/` config (`requirements.txt`, `postBuild`, `runtime.txt`),
Jupyter extras in `pyproject.toml`.

**Why** : a one-click Binder badge is the single biggest barrier-
remover for new users. They can run your code in their browser, in
60 seconds, without installing anything. Combined with a curated
`notebooks/README.md` index, this becomes the de-facto "academy" of
your project.

**When to use** : research / ML projects with notebooks. Also useful
for any library where you want to ship "try it now" examples.

**Inspired by** : hmm_studio's notebook gallery (phase E reframed —
the gallery IS the academy).

### 🧩 Addon : `web` — Docker + start/stop scripts

**Adds** : `Dockerfile` (multi-stage scaffold for frontend-build +
Python backend), `docker-compose.yml` (with healthcheck), `start.ps1`
(launches compose + polls `/health` + opens browser), `start.bat`,
`stop.ps1`, `stop.bat`, `.dockerignore`.

**Why** : the start/stop scripts make "git clone → run" achievable in
~60 seconds for someone on Windows who has Docker Desktop. The `.bat`
fallback handles users who haven't enabled PowerShell execution policy.

**When to use** : projects with a web UI / API / DB. Skip for pure
libraries.

**Inspired by** : gitnexus (full pattern : compose + start/stop +
healthcheck polling) and hmm_studio's web layer.

### 🧩 Addon : `academic` — mkdocs + papers + auto-deploy

**Adds** : `mkdocs.yml` (material theme + nav), `docs/papers/`
folder for paper PDFs / references, `.github/workflows/docs.yml`
(auto-deploys to gh-pages on push to `main`), `CITATION.cff` (if
not already in tier 3).

**Why** : a doc site at `<repo>.github.io` is the single most
professional signal you can ship. Material theme + auto-deploy means
zero ongoing maintenance. `docs/papers/` keeps the academic context
discoverable.

**When to use** : research projects, academic libraries, anything
where you want a published doc site.

### 🧩 Addon : `devcontainer` — VS Code / Codespaces dev env

**Adds** : `.devcontainer/devcontainer.json` (Python 3.12 base, with
ruff/python/jupyter VS Code extensions pinned), `.devcontainer/Dockerfile`,
`.devcontainer/postCreateCommand.sh` (`pip install -e .[dev]`).

**Why** : a collaborator who clicks "Open in Codespaces" gets a
fully-configured environment in 90 seconds — no Docker setup, no
"works on my machine". Also serves as a `from-scratch` reproducibility
spec : the devcontainer config IS the setup documentation.

**When to use** : whenever you anticipate collaborators (interns,
co-authors, external contributors). Strong synergy with `ml` and
`web` addons.

### 🧩 Addon : `supply-chain` — SBOM + Dependabot + Scorecard

**Adds** :
- `.github/workflows/sbom.yml` — CycloneDX SBOM (JSON + XML),
  uploaded as release assets.
- `.github/dependabot.yml` — weekly dep PRs (Monday 06:00 Europe/Paris,
  conservative config).
- `.github/workflows/scorecard.yml` — OpenSSF Scorecard, weekly +
  on-push to `main`.

**Why** : after the XZ-utils backdoor (March 2024), downstream users
*do* check supply-chain hygiene on libraries they depend on. SBOM is no
longer enterprise-only — it's table-stakes for any library that wants
to be picked. Dependabot keeps you on patched versions without you
thinking about it.

**When to use** : any tier-3 OSS library, or any tier-2 project shipped
to external users (commercial / regulated).

**The justification** : "SBOM is enterprise overkill" was true in 2022.
In 2026, the XZ incident changed that — and `cyclonedx-bom` makes it a
zero-config pip install. The cost dropped to zero.

### 🧩 Addon : `code-intel` — GitNexus MCP wiring

**Adds** : `.gitignore.append` (ignore `.gitnexus/`), `AGENTS.md.append`
+ `CLAUDE.md.append` (MCP endpoint + tool-use protocol),
`Makefile.append` (`reindex`, `reindex-force`, `graph-status`,
`graph-skills`, `graph-up` targets), `scripts/reindex.ps1`,
`docs/decisions/0002-code-graph-with-gitnexus.md`,
`.claude/skills/.gitkeep`, `.gitnexus-domains.json.example`,
`.gitnexus-policy.json.example`.

**Why** : Claude / Cursor / Codex work *dramatically* better when they
have a graph view of the codebase instead of grepping blindly. GitNexus
([github.com/abhigyanpatwari/gitnexus](https://github.com/abhigyanpatwari/gitnexus))
is a graph-code-intelligence MCP server that indexes any repo and
exposes :
- `analyze_change` — blast radius before refactor
- `generate_map` — mermaid architecture diagrams
- Graph search / context / references — faster than grep for
  structural questions
- Auto-generated skills (`.claude/skills/SKILL.md`) per detected
  Leiden community

The daemon is **global** (one instance serves all projects under
`PROJECTS_ROOT`), so this addon adds zero per-project infrastructure —
only the *contract documentation* that tells Claude "use the graph
first, grep as fallback".

**When to use** : every project where Claude / Cursor / Codex is a
daily pair-programmer, AND the project lives under a folder mounted
by gitnexus's `PROJECTS_ROOT`. Skip for tiny one-file experiments or
projects with < ~50 source files (grep wins at that scale).

**The killer file** : `AGENTS.md.append` defines the *operational
protocol* — "for structural questions, use MCP graph tools ; for
literal string search, use grep ; before any refactor with > 5
expected touch sites, run `analyze_change` first". This contract,
documented once, sticks across every Claude session.

**Inspired by** : Robin's `gitnexus/` local deployment at
`C:/Users/rdenis/VScode/gitnexus/` (see its INVENTORY.md). The addon
codifies what Robin already does informally on every project.

### 🧩 Addon : `infra` — Checkov + IaC layout

**Adds** : `.github/workflows/iac-scan.yml` (Checkov action v12,
runs on PR + push), `infra/` skeleton (terraform / k8s / helm /
cloudformation subdirs ready to populate), `.gitignore.infra`
(merged into root `.gitignore` if both exist).

**Why** : if your repo ships Terraform / k8s / Helm / CloudFormation,
Checkov catches the misconfigurations that cause 80% of cloud breaches
(public S3 buckets, unencrypted volumes, IAM `*:*` policies, etc.).
Runs in CI ; zero ongoing cost.

**When to use** : *only* if the project actually ships IaC. Don't add
for a pure library — it adds noise (empty `infra/` folder) without
benefit.

---

## Tier-1 trimming (prototypes)

When `-Tier 1`, the bootstrap script removes :
- `CHANGELOG.md` (no shipping history)
- `CONTRIBUTING.md` (no contributors)
- `docs/specs/`, `docs/decisions/` (overkill for < 1-week experiments)
- `validation/` (no scientific correctness layer yet)
- `notes/` (often not needed for one-shots)

Keep even for tier 1 :
- README, LICENSE, `.gitignore`, `.editorconfig`
- `src/`, `tests/` (even just one smoke test)
- `AGENTS.md` + `CLAUDE.md` (if using Claude)

---

## Recipes — common compositions

Recipes pre-bake the most common `tier + addons` combinations so you
don't have to remember them. See `recipes/*.json` for the canonical
list ; the table below is the human-readable version.

| Recipe | = Tier + addons | When |
|---|---|---|
| `prototype` | 1 | One-shot experiment |
| `private-tool` | 2 | Default solo tool |
| `ai-pair-programming` | 2 + code-intel + devcontainer | Claude as daily co-pilot |
| `ml-research` | 2 + ml + academic + code-intel | Notebook-driven research |
| `web-service` | 2 + web + devcontainer | API / dashboard |
| `oss-library` | 3 + supply-chain | Public Python lib |
| `academic-library` | 3 + academic + supply-chain | Citable lib |
| `full-stack-research` | 3 + ml + academic + web + devcontainer + supply-chain + code-intel | The magnum opus |
| `cloud-deployment` | 2 + web + devcontainer + infra + supply-chain | SaaS with IaC |

Adding a new recipe is a one-file change : create
`recipes/<name>.json`, pin the tier + addons, document an example
project. The bootstrap script auto-discovers it.

---

## Borrowed-from-the-best patterns

After auditing the scaffolding ecosystem (cookiecutter, copier,
cookie-composer, scientific-python/cookie, Yeoman, Nx, AGENTS.md
standard), four patterns were worth stealing :

### Pattern : Answers file (from copier)

Every bootstrapped project gets a `.repo-template-answers.json` at
root, recording :

```json
{
  "schema_version": 1,
  "bootstrapped_at": "2026-05-26T12:34:56+02:00",
  "template_commit": "b514c03...",
  "recipe": "ml-research",
  "tier": 2,
  "addons": ["ml", "academic", "code-intel"],
  "placeholders": { "PROJECT_NAME": "...", ... },
  "history": [
    { "at": "...", "action": "add-addon", "addons": ["code-intel"] }
  ]
}
```

**Why it works** : the project is now self-describing. `validate.ps1`
auto-detects what to check. `add-addon.ps1` knows what's already
applied. Future "what version of the template did I bootstrap from ?"
is answered by `template_commit`.

### Pattern : Numbered check codes (from sp-repo-review)

`validate.ps1` failures use stable codes (`RT001` = missing LICENSE,
`ML002` = missing notebooks/, `CI004` = AGENTS.md doesn't contain
GitNexus block, `PH001` = leftover placeholder).

**Why it works** : codes are stable and searchable. Disable a check
via `-Disable RT020,ML002` when a project deliberately deviates. Codes
also make CI failures actionable (paste the code → grep the validator
script → find the rule).

### Pattern : Multi-agent canonical file (AGENTS.md standard)

The base skeleton ships `AGENTS.md` as canonical + `CLAUDE.md` +
`GEMINI.md` + `CODEX.md` as stubs pointing back. AGENTS.md is the
open standard governed by the Agentic AI Foundation (Sourcegraph +
OpenAI + Google + Cursor + Factory).

**Why it works** : every agent looks for "its" filename and finds the
expected context. No symlinks needed (Windows-friendly). Stub files
say "see AGENTS.md" so the agent reads the canonical content. Future
agents fitting the standard just need one more stub.

### Pattern : Incremental addons (from Nx generators)

`add-addon.ps1` lets you start with a minimal recipe and grow.
Common journey :

```
private-tool (tier 2)
  → add ml          (notebooks for an experiment)
    → add academic  (paper to cite)
      → tier-3 + add supply-chain (publishing on PyPI)
```

**Why it works** : you don't have to predict the project's final shape
at day 0. Recipes are starting points, not commitments. Each addon is
reversible (delete its files, edit `.repo-template-answers.json`).

## Closing thoughts

The single biggest lesson from across Robin's projects :

> **Discipline scales with project lifespan ; capabilities scale with
> project domain.** Match each dial independently. A prototype dies if
> you add too much ceremony ; a real tool dies if you skip the
> discipline ; an OSS lib dies without supply-chain hygiene that
> downstream users now demand.

When in doubt :
- Start tier-1 with no addons.
- Upgrade to tier-2 the first time you think "I should write that
  down somewhere".
- Add `ml` the first time you write a notebook worth keeping.
- Add `web` the first time you boot Docker.
- Add `devcontainer` the first time someone else clones the repo.
- Upgrade to tier-3 + `supply-chain` when you publish.
- Add `academic` when you cite a paper or publish a doc site.
- Add `infra` only if you actually ship IaC.

Each addon is reversible — just delete its files if you change your
mind. None of them couple to each other.
