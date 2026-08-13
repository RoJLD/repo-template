#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Audit an existing project against a claimed (or recorded) recipe.

.DESCRIPTION
    Inspired by scientific-python/sp-repo-review : numbered, documented
    checks that you can disable selectively. Each failure has a stable
    code (e.g. RT003 = missing CHANGELOG, ML002 = missing notebooks dir,
    PH001 = leftover placeholder) so you can grep / suppress / track.

    Resolution order for what to validate AGAINST :
      1. Explicit -Recipe / -Tier / -Addons flags (manual claim)
      2. .repo-template-answers.json in -Path (auto-detected, written
         by bootstrap.ps1)
      3. Defaults : tier 2, no addons

    All check codes :
      RT### = tier base checks (tier 1/2/3)
      ML###, WEB###, ACA###, DEV###, SUP###, IAC###, CI### = per-addon
      PH###  = placeholder hits anywhere in the tree

.PARAMETER Path
    Project to audit (default : current directory).

.PARAMETER Recipe
    Recipe name. Overrides answers file if both present.

.PARAMETER Tier
    Discipline tier (1/2/3). Used if no -Recipe and no answers file.

.PARAMETER Addons
    Comma-separated addon list.

.PARAMETER Disable
    Comma-separated list of check codes to skip (e.g. "RT003,ML002").

.PARAMETER FailFast
    Exit on first failure.

.EXAMPLE
    .\validate.ps1
    # Audits current directory, auto-loads .repo-template-answers.json if present

.EXAMPLE
    .\validate.ps1 -Path "..\hmm_studio"
    # Same, on another project

.EXAMPLE
    .\validate.ps1 -Path . -Recipe ml-research -Disable "ML002"
    # Force-claim a recipe and ignore a specific check
#>

param(
    [string]$Path = ".",
    [string]$Recipe = "",
    [ValidateSet("","1","2","3")][string]$Tier = "",
    [string]$Addons = "",
    [string]$Disable = "",
    [switch]$FailFast
)

$ErrorActionPreference = "Stop"

$TemplateDir = Split-Path -Parent $PSCommandPath
$Path = (Resolve-Path $Path).Path
$disabledCodes = @($Disable -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })

# --- Resolve claimed tier + addons ---------------------------------------
$AddonList = @()
$source = "defaults"

if ($Recipe) {
    $recipePath = Join-Path $TemplateDir "recipes\$Recipe.json"
    if (-not (Test-Path $recipePath)) {
        Write-Host "ERROR : recipe not found : $recipePath" -ForegroundColor Red
        exit 2
    }
    $r = Get-Content $recipePath -Raw | ConvertFrom-Json
    $Tier = "$($r.tier)"
    if ($r.addons) { $AddonList = @($r.addons) }
    $source = "recipe '$Recipe'"
} elseif ($Tier -or $Addons) {
    if (-not $Tier) { $Tier = "2" }
    if ($Addons) {
        $AddonList = $Addons -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }
    $source = "explicit -Tier/-Addons flags"
} else {
    # Try the answers file
    $answersPath = Join-Path $Path ".repo-template-answers.json"
    if (Test-Path $answersPath) {
        $a = Get-Content $answersPath -Raw | ConvertFrom-Json
        $Tier = "$($a.tier)"
        if ($a.addons) { $AddonList = @($a.addons) }
        if ($a.recipe) { $source = "answers file (recipe: $($a.recipe))" } else { $source = "answers file (manual composition)" }
    } else {
        $Tier = "2"
        $source = "defaults (no answers file, no flags)"
    }
}

# --- Check signature : code -> { description, predicate } ----------------
# Predicates are scriptblocks that take $Path and return $true on PASS.
$checks = [ordered]@{}

function Add-Check {
    param([string]$Code, [string]$Desc, [scriptblock]$Predicate)
    $checks[$Code] = @{ desc = $Desc ; predicate = $Predicate }
}

# Helpers
function Has-File { param($rel) Test-Path (Join-Path $Path $rel) -PathType Leaf }
function Has-Dir  { param($rel) Test-Path (Join-Path $Path $rel) -PathType Container }
function Has-Marker {
    param($rel, $marker)
    $full = Join-Path $Path $rel
    if (-not (Test-Path $full -PathType Leaf)) { return $false }
    $c = Get-Content $full -Raw -ErrorAction SilentlyContinue
    return ($c -match [regex]::Escape($marker))
}

# ---- Tier-1 (universal foundation) --------------------------------------
Add-Check "RT001" "Tier 1: README.md present"     { Has-File "README.md" }
Add-Check "RT002" "Tier 1: LICENSE present"       { Has-File "LICENSE" }
Add-Check "RT003" "Tier 1: .gitignore present"    { Has-File ".gitignore" }
Add-Check "RT004" "Tier 1: AGENTS.md present"     { Has-File "AGENTS.md" }
Add-Check "RT005" "Tier 1: CLAUDE.md present"     { Has-File "CLAUDE.md" }
Add-Check "RT006" "Tier 1: GEMINI.md present (multi-agent stub)" { Has-File "GEMINI.md" }
Add-Check "RT007" "Tier 1: CODEX.md present (multi-agent stub)" { Has-File "CODEX.md" }
Add-Check "RT008" "Tier 1: pyproject.toml present" { Has-File "pyproject.toml" }
Add-Check "RT009" "Tier 1: Makefile present"      { Has-File "Makefile" }
Add-Check "RT010" "Tier 1: src/ directory present" { Has-Dir "src" }
Add-Check "RT011" "Tier 1: tests/ directory present" { Has-Dir "tests" }

# ---- Tier-2 (process maturity) ------------------------------------------
Add-Check "RT020" "Tier 2: CHANGELOG.md present"  { Has-File "CHANGELOG.md" }
Add-Check "RT021" "Tier 2: CONTRIBUTING.md present" { Has-File "CONTRIBUTING.md" }
Add-Check "RT022" "Tier 2: docs/roadmap.md present" { Has-File "docs/roadmap.md" }
Add-Check "RT023" "Tier 2: docs/decisions/_template.md (ADR template) present" { Has-File "docs/decisions/_template.md" }
Add-Check "RT024" "Tier 2: docs/specs/_template.md present" { Has-File "docs/specs/_template.md" }
Add-Check "RT025" "Tier 2: validation/ directory present" { Has-Dir "validation" }
Add-Check "RT026" "Tier 2: notes/ directory present" { Has-Dir "notes" }
Add-Check "RT027" "Tier 2: docs/guides/ directory present" { Has-Dir "docs/guides" }
Add-Check "RT028" "Tier 2: docs/specs/README.md enforces spec-before-plan + historicization" { Has-Marker "docs/specs/README.md" "Mandatory before any implementation plan" }

# ---- Tier-3 (OSS) -------------------------------------------------------
Add-Check "RT040" "Tier 3: CODE_OF_CONDUCT.md present" { Has-File "CODE_OF_CONDUCT.md" }
Add-Check "RT041" "Tier 3: SECURITY.md present"   { Has-File "SECURITY.md" }
Add-Check "RT042" "Tier 3: CODEOWNERS present"    { Has-File "CODEOWNERS" }
Add-Check "RT043" "Tier 3: CITATION.cff present"  { Has-File "CITATION.cff" }

# ---- ml addon ------------------------------------------------------------
Add-Check "ML001" "ml: notebooks/ directory" { Has-Dir "notebooks" }
Add-Check "ML002" "ml: notebooks/README.md (gallery index)" { Has-File "notebooks/README.md" }
Add-Check "ML003" "ml: binder/ directory" { Has-Dir "binder" }
Add-Check "ML004" "ml: binder/requirements.txt" { Has-File "binder/requirements.txt" }
Add-Check "ML005" "ml: binder/postBuild" { Has-File "binder/postBuild" }
Add-Check "ML006" "ml: examples/ directory" { Has-Dir "examples" }

# ---- web addon -----------------------------------------------------------
Add-Check "WEB001" "web: Dockerfile" { Has-File "Dockerfile" }
Add-Check "WEB002" "web: docker-compose.yml" { Has-File "docker-compose.yml" }
Add-Check "WEB003" "web: start.ps1" { Has-File "start.ps1" }
Add-Check "WEB004" "web: stop.ps1" { Has-File "stop.ps1" }
Add-Check "WEB005" "web: .dockerignore" { Has-File ".dockerignore" }

# ---- academic addon ------------------------------------------------------
Add-Check "ACA001" "academic: mkdocs.yml" { Has-File "mkdocs.yml" }
Add-Check "ACA002" "academic: docs/papers/ directory" { Has-Dir "docs/papers" }
Add-Check "ACA003" "academic: docs/papers/README.md" { Has-File "docs/papers/README.md" }
Add-Check "ACA004" "academic: docs/index.md (mkdocs landing)" { Has-File "docs/index.md" }
Add-Check "ACA005" "academic: .github/workflows/docs.yml (gh-pages deploy)" { Has-File ".github/workflows/docs.yml" }
Add-Check "ACA006" "academic: CITATION.cff" { Has-File "CITATION.cff" }

# ---- devcontainer addon -------------------------------------------------
Add-Check "DEV001" "devcontainer: .devcontainer/devcontainer.json" { Has-File ".devcontainer/devcontainer.json" }
Add-Check "DEV002" "devcontainer: .devcontainer/Dockerfile" { Has-File ".devcontainer/Dockerfile" }
Add-Check "DEV003" "devcontainer: .devcontainer/postCreateCommand.sh" { Has-File ".devcontainer/postCreateCommand.sh" }

# ---- supply-chain addon -------------------------------------------------
Add-Check "SUP001" "supply-chain: .github/dependabot.yml" { Has-File ".github/dependabot.yml" }
Add-Check "SUP002" "supply-chain: .github/workflows/sbom.yml" { Has-File ".github/workflows/sbom.yml" }
Add-Check "SUP003" "supply-chain: .github/workflows/scorecard.yml" { Has-File ".github/workflows/scorecard.yml" }

# ---- infra addon --------------------------------------------------------
Add-Check "IAC001" "infra: .github/workflows/iac-scan.yml" { Has-File ".github/workflows/iac-scan.yml" }
Add-Check "IAC002" "infra: infra/ directory" { Has-Dir "infra" }

# ---- code-intel addon ---------------------------------------------------
Add-Check "CI001" "code-intel: scripts/reindex.ps1" { Has-File "scripts/reindex.ps1" }
Add-Check "CI002" "code-intel: docs/decisions/0002-code-graph-with-gitnexus.md" { Has-File "docs/decisions/0002-code-graph-with-gitnexus.md" }
Add-Check "CI003" "code-intel: .gitnexus-domains.json.example" { Has-File ".gitnexus-domains.json.example" }
Add-Check "CI004" "code-intel: AGENTS.md contains 'Code-graph context'" { Has-Marker "AGENTS.md" "Code-graph context" }
Add-Check "CI005" "code-intel: CLAUDE.md contains 'GitNexus MCP integration'" { Has-Marker "CLAUDE.md" "GitNexus MCP integration" }
Add-Check "CI006" "code-intel: .gitignore contains '.gitnexus/'" { Has-Marker ".gitignore" ".gitnexus/" }
Add-Check "CI007" "code-intel: Makefile contains 'graph-status' target" { Has-Marker "Makefile" "graph-status" }
Add-Check "CI008" "code-intel: .claude/skills/ directory" { Has-Dir ".claude/skills" }

# --- Compute which codes are active for the claimed tier+addons ----------
$activeCodes = @()
$activeCodes += $checks.Keys | Where-Object { $_ -match "^RT0(0|1)\d" }            # tier-1 baseline (RT001..RT019)
if ([int]$Tier -ge 2) { $activeCodes += $checks.Keys | Where-Object { $_ -like "RT02*" } }
if ([int]$Tier -eq 3) { $activeCodes += $checks.Keys | Where-Object { $_ -like "RT04*" } }
$addonPrefixMap = @{
    "ml"            = "ML"
    "web"           = "WEB"
    "academic"      = "ACA"
    "devcontainer"  = "DEV"
    "supply-chain"  = "SUP"
    "infra"         = "IAC"
    "code-intel"    = "CI"
}
foreach ($a in $AddonList) {
    $prefix = $addonPrefixMap[$a]
    if ($prefix) {
        $activeCodes += $checks.Keys | Where-Object { $_ -like "$prefix*" }
    }
}
$activeCodes = $activeCodes | Where-Object { $_ -notin $disabledCodes } | Select-Object -Unique

# --- Run checks ----------------------------------------------------------
Write-Host ""
Write-Host "=== validate.ps1 ===" -ForegroundColor Cyan
Write-Host "Project : $Path"
Write-Host "Claim   : tier $Tier, addons [$($AddonList -join ',')]  (source: $source)"
if ($disabledCodes) { Write-Host "Disabled: $($disabledCodes -join ', ')" -ForegroundColor DarkGray }
Write-Host "Codes   : $($activeCodes.Count) active"
Write-Host ""

$passed = @()
$failed = @()

foreach ($code in $activeCodes) {
    $check = $checks[$code]
    $ok = & $check.predicate
    if ($ok) {
        $passed += $code
    } else {
        $failed += @{ code = $code ; desc = $check.desc }
        if ($FailFast) { break }
    }
}

# --- Placeholder scan (always runs, never gated by tier/addons) ----------
$exclude = @(".git", "node_modules", ".venv", "venv", ".gitnexus", "site", "_build", "__pycache__", ".repo-template-answers.json")
$phHits = @(Get-ChildItem -Recurse -File $Path -ErrorAction SilentlyContinue |
    Where-Object {
        $p = $_.FullName
        -not ($exclude | Where-Object { $p -like "*\$_\*" -or $p -like "*\$_" -or $p -like "*$_" })
    } |
    Select-String -Pattern '\{\{[A-Z_]+\}\}' -ErrorAction SilentlyContinue)

$phFailed = @()
if (-not ($disabledCodes -contains "PH001") -and $phHits.Count -gt 0) {
    foreach ($h in $phHits) {
        $rel = $h.Path.Replace($Path, "").TrimStart('\','/')
        $phFailed += "${rel}:$($h.LineNumber) -> $($h.Matches[0].Value)"
    }
}

# --- Report --------------------------------------------------------------
Write-Host "PASSED   : $($passed.Count) / $($activeCodes.Count)" -ForegroundColor Green
if ($failed.Count) {
    Write-Host "FAILED   : $($failed.Count)" -ForegroundColor Red
    foreach ($f in $failed) {
        Write-Host ("  [{0}] {1}" -f $f.code, $f.desc) -ForegroundColor Red
    }
}
if ($phFailed.Count) {
    Write-Host "PH001    : $($phFailed.Count) leftover placeholder(s)" -ForegroundColor Red
    $phFailed | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    if ($phFailed.Count -gt 10) { Write-Host "  ... (+ $($phFailed.Count - 10) more)" -ForegroundColor Red }
}
Write-Host ""

if ($failed.Count -or $phFailed.Count) { exit 1 } else { exit 0 }
