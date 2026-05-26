# Bootstrap a new project from this template

Two paths : **scripted** (use `bootstrap.ps1`, recommended) or **manual**
(copy + sed-replace). Allow ~2 minutes scripted, ~10 minutes manual.

## Quick discovery

```powershell
.\bootstrap.ps1 -List
# Prints every recipe + every addon with short descriptions.
```

## Path A — scripted (recommended)

### Quickest — pick a recipe

```powershell
# From the repo-template folder
.\bootstrap.ps1 `
    -Name "my-engine" -Title "My Engine" `
    -Description "HMM toolkit for sequence modelling." `
    -Recipe "ml-research"
```

Available recipes (`recipes/*.json`) :

| Recipe | What it is |
|---|---|
| `prototype` | Tier 1, no addons — throwaway |
| `private-tool` | Tier 2, no addons — default solo |
| `ai-pair-programming` | Tier 2 + `code-intel` + `devcontainer` — Claude pair-programming |
| `ml-research` | Tier 2 + `ml` + `academic` + `code-intel` — notebook research |
| `web-service` | Tier 2 + `web` + `devcontainer` — API / dashboard |
| `oss-library` | Tier 3 + `supply-chain` — public Python lib |
| `academic-library` | Tier 3 + `academic` + `supply-chain` — citable lib |
| `full-stack-research` | Tier 3 + everything except `infra` (includes `code-intel`) |
| `cloud-deployment` | Tier 2 + `web` + `devcontainer` + `infra` + `supply-chain` — SaaS |

### Composing manually

```powershell
.\bootstrap.ps1 `
    -Name "my-lib" -Title "My Lib" `
    -Description "Public Python library." `
    -Tier 3 -Addons "supply-chain,academic"
```

Valid addons : `ml`, `web`, `academic`, `devcontainer`, `supply-chain`,
`infra`, `code-intel`. See `addons/<name>/README.md` for what each adds.

### Defaults

The script defaults to **tier 2, no addons** if neither `-Recipe` nor
`-Addons` is given :

```powershell
.\bootstrap.ps1 -Name "my-tool" -Title "My Tool" -Description "Does X."
```

### What it does, step by step

1. Loads the recipe (if `-Recipe`) → resolves `Tier` + `Addons` list.
2. Validates addons against the known set.
3. Copies `template/` → `$Dest`.
4. If `Tier = 1` : trims overhead (`CHANGELOG.md`, `docs/specs/`,
   `docs/decisions/`, `validation/`, `notes/`, `CONTRIBUTING.md`).
5. If `Tier = 3` : layers `tier-3-additions/` on top.
6. For each addon : merges `addons/<name>/` into `$Dest` (non-destructive
   directory merge ; addon README excluded ; `*.append` files are
   *appended* to their target instead of overwriting).
7. Replaces all `{{PLACEHOLDERS}}` across the merged tree.
8. **Writes `.repo-template-answers.json`** to the project root (records
   tier, addons, placeholders, template commit, timestamp). Lets
   `validate.ps1` and `add-addon.ps1` know what was applied.
9. Reports any leftover placeholders.
10. Runs `git init` + first commit (unless `-InitGit $false`).

## Audit an existing project

```powershell
# Auto-detects what to check via .repo-template-answers.json
.\validate.ps1 -Path "..\my-project"

# Or force-claim a recipe
.\validate.ps1 -Path "..\my-project" -Recipe ml-research

# Disable specific check codes
.\validate.ps1 -Path "..\my-project" -Disable "RT020,ML002"
```

Numbered check codes (inspired by sp-repo-review) :
- `RT001..RT019` = tier 1 baseline (README, LICENSE, AGENTS.md, ...)
- `RT020..RT039` = tier 2 (CHANGELOG, ADRs, validation/, notes/, ...)
- `RT040..RT049` = tier 3 (CODE_OF_CONDUCT, SECURITY, ...)
- `ML*` / `WEB*` / `ACA*` / `DEV*` / `SUP*` / `IAC*` / `CI*` = per-addon
- `PH001` = leftover `{{PLACEHOLDER}}` anywhere

Exit code 0 = all checks pass, 1 = at least one failure.

## Add an addon to an existing project

```powershell
# Start as private-tool, later realize you need notebooks
.\add-addon.ps1 -Path "..\my-tool" -Addons "ml"

# Or layer several at once
.\add-addon.ps1 -Path "..\my-tool" -Addons "ml,code-intel"
```

Reuses the merge logic of `bootstrap.ps1` (`*.append` semantics
included), refuses to add addons already present, and updates
`.repo-template-answers.json` so future `validate.ps1` knows.

## Path B — manual

### Step 1 — Copy the skeleton

```powershell
$NEW_NAME = "MyAwesomeProject"
$NEW_PATH = "C:\Users\rdenis\VScode\$NEW_NAME"
Copy-Item -Recurse C:\Users\rdenis\VScode\repo-template\template $NEW_PATH
cd $NEW_PATH
```

### Step 2 — Layer additions

For tier 3 :
```powershell
$TIER3 = "C:\Users\rdenis\VScode\repo-template\tier-3-additions"
Get-ChildItem -File $TIER3 -Exclude "README.md" |
    ForEach-Object { Copy-Item $_.FullName -Destination $NEW_PATH }
```

For each addon (example with `ml`) :
```powershell
$ADDON = "C:\Users\rdenis\VScode\repo-template\addons\ml"
Copy-Item -Recurse "$ADDON\*" $NEW_PATH -Exclude "README.md"
```

### Step 3 — Replace placeholders

Discover them :
```powershell
Get-ChildItem -Recurse -File | Select-String -Pattern "\{\{" | Format-Table -AutoSize
```

The full list :

| Placeholder | Example | Where |
|---|---|---|
| `{{PROJECT_NAME}}` | `my-awesome-project` | README, pyproject.toml, CHANGELOG |
| `{{PROJECT_TITLE}}` | `My Awesome Project` | README h1 |
| `{{PROJECT_DESCRIPTION}}` | `One-line elevator pitch.` | README, pyproject.toml |
| `{{AUTHOR_NAME}}` | `Robin Denis` | pyproject.toml, LICENSE, CITATION |
| `{{AUTHOR_NAME_FIRST}}` | `Robin` | CITATION |
| `{{AUTHOR_NAME_LAST}}` | `Denis` | CITATION |
| `{{AUTHOR_EMAIL}}` | `robin.denis1207@gmail.com` | pyproject.toml, CITATION |
| `{{GITHUB_USER}}` | `RoJLD` | URLs in pyproject.toml, badges |
| `{{GITHUB_REPO}}` | `MyAwesomeProject` | URLs |
| `{{YEAR}}` | `2026` | LICENSE, CITATION |
| `{{LICENSE}}` | `MIT` | LICENSE choice |
| `{{PYTHON_VERSION}}` | `3.11` | pyproject.toml requires-python |
| `{{PYTHON_VERSION_NODOT}}` | `311` | CI matrix labels |

Bulk-replace one placeholder :
```powershell
Get-ChildItem -Recurse -File | ForEach-Object {
    (Get-Content $_.FullName -Raw) -replace '\{\{PROJECT_NAME\}\}', 'my-awesome-project' |
        Set-Content $_.FullName -NoNewline
}
```

### Step 4 — Choose package manager

`pyproject.toml` ships by default. For other stacks :
- **Node/TS** : delete `pyproject.toml`, run `npm init -y`.
- **Rust** : delete `pyproject.toml`, run `cargo init`.
- **Mixed (Python backend + React)** : keep `pyproject.toml` at root,
  put `package.json` under `frontend/` or `src/web/`.

### Step 5 — Initialize git

```powershell
git init -b main
git add -A
git commit -m "chore: bootstrap from repo-template"
gh repo create $NEW_NAME --private --source=. --remote=origin    # optional
git push -u origin main                                          # optional
```

## After bootstrap — first day on the project

### Tier 2+ minimum

- [ ] `docs/roadmap.md` → write vision + Phase A + Phase Z.
- [ ] `docs/decisions/0001-*.md` → first ADR (stack choice).
- [ ] `tests/` → at least one passing sanity test.
- [ ] `git log --oneline` shows the bootstrap commit.

### If you added `ml` addon

- [ ] `notebooks/README.md` → start your gallery index.
- [ ] First notebook : `notebooks/01-quick-tour.ipynb`.
- [ ] `binder/requirements.txt` reflects your actual deps.

### If you added `web` addon

- [ ] Edit `Dockerfile` for your real backend (Python / Node / Go ...).
- [ ] `docker-compose.yml` services match what you actually need.
- [ ] `.\start.ps1` boots cleanly on a fresh machine.

### If you added `academic` addon

- [ ] `mkdocs.yml` → set `site_url`, `repo_url`, nav titles.
- [ ] `CITATION.cff` placeholders filled (DOI when published).
- [ ] First push to `main` should auto-deploy to gh-pages.

### If you added `devcontainer` addon

- [ ] Open the folder in VS Code → "Reopen in Container" works.
- [ ] `postCreateCommand.sh` finishes without error.

### If you added `supply-chain` addon

- [ ] Enable GitHub Actions for the repo.
- [ ] First Dependabot PR lands within a week (Monday morning).
- [ ] OpenSSF Scorecard score visible on first weekly run.

### If you added `infra` addon

- [ ] `infra/<terraform|k8s|helm>/` has at least a placeholder.
- [ ] First Checkov scan passes (or has documented exceptions).

### If you added `code-intel` addon

- [ ] GitNexus daemon running (`cd ..\gitnexus ; .\start.ps1`).
- [ ] First reindex : `.\scripts\reindex.ps1` (after first commit).
- [ ] `docs/decisions/0002-code-graph-with-gitnexus.md` reviewed + dated.
- [ ] `.gitnexus-domains.json.example` either filled (rename to `.gitnexus-domains.json`) or deleted.
- [ ] `AGENTS.md` and `CLAUDE.md` confirmed to contain the gitnexus section (auto-appended).
- [ ] Optional : `make graph-skills` to generate `.claude/skills/SKILL.md` files.

## Optional — Claude / AI memory

If you'll use Claude on this project regularly :

```powershell
$slug = $pwd.Path -replace '[\\:]', '-'
$AGENT_MEM = "$HOME\.claude\projects\$slug\memory"
New-Item -ItemType Directory -Force $AGENT_MEM
```

Create `MEMORY.md` inside as the index. Persist project-strategic
context here so future Claude sessions don't re-litigate decisions.
See PATTERNS.md § "Claude memory persistence".

## Cheat sheet

| Want | Command |
|---|---|
| Pure prototype | `-Recipe prototype` |
| Solo tool (default) | `-Recipe private-tool` |
| Claude pair-programming | `-Recipe ai-pair-programming` |
| Notebook-driven research | `-Recipe ml-research` |
| Web service with Docker | `-Recipe web-service` |
| Public Python lib | `-Recipe oss-library` |
| Citable academic lib | `-Recipe academic-library` |
| The magnum opus | `-Recipe full-stack-research` |
| SaaS with IaC | `-Recipe cloud-deployment` |
| Bespoke combo | `-Tier <N> -Addons "x,y,z"` |
