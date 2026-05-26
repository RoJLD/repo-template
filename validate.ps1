#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Audit an existing project against a claimed recipe / tier / addons.

.DESCRIPTION
    The substitute for "copier update" that this template lacks. Given
    a project path and what it CLAIMS to be (recipe or tier+addons),
    validate.ps1 checks that the project actually matches :

      1. Required files for the claimed tier (1/2/3) are present
      2. Required files for each claimed addon are present
      3. For .append-ed files, the addon's signature content is found
         in the target file
      4. No {{PLACEHOLDERS}} are left anywhere in the project

    This catches drift between what you SAY a project is and what's
    actually on disk. Useful when projects evolve organically and lose
    track of their tier / addon labels.

.PARAMETER Path
    Path to the project to audit (default : current directory).

.PARAMETER Recipe
    Recipe name (loads tier+addons from recipes/<name>.json).
    Mutually exclusive with -Tier / -Addons.

.PARAMETER Tier
    Discipline tier (1 / 2 / 3). Default : 2.

.PARAMETER Addons
    Comma-separated addon list, e.g. "ml,academic".

.PARAMETER FailFast
    Exit on first failure (default : run all checks).

.EXAMPLE
    .\validate.ps1 -Path "..\hmm_studio" -Recipe full-stack-research

.EXAMPLE
    .\validate.ps1 -Path . -Tier 3 -Addons "supply-chain,academic"
#>

param(
    [string]$Path = ".",
    [string]$Recipe = "",
    [ValidateSet("1","2","3")][string]$Tier = "2",
    [string]$Addons = "",
    [switch]$FailFast
)

$ErrorActionPreference = "Stop"

$TemplateDir = Split-Path -Parent $PSCommandPath
$Path = (Resolve-Path $Path).Path

# --- Resolve recipe (if any) ----------------------------------------------
$AddonList = @()
if ($Recipe) {
    $recipePath = Join-Path $TemplateDir "recipes\$Recipe.json"
    if (-not (Test-Path $recipePath)) {
        Write-Host "ERROR : recipe not found : $recipePath" -ForegroundColor Red
        exit 2
    }
    $recipeData = Get-Content $recipePath -Raw | ConvertFrom-Json
    $Tier = "$($recipeData.tier)"
    if ($recipeData.addons) { $AddonList = @($recipeData.addons) }
} elseif ($Addons) {
    $AddonList = $Addons -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

# --- Signatures : what each pack MUST contribute --------------------------
$signatures = @{
    "tier-1" = @{
        files = @("README.md", "LICENSE", ".gitignore", "AGENTS.md", "CLAUDE.md", "pyproject.toml", "Makefile")
        dirs  = @("src", "tests")
    }
    "tier-2" = @{
        files = @("CHANGELOG.md", "CONTRIBUTING.md", "docs/roadmap.md", "docs/decisions/_template.md", "docs/specs/_template.md")
        dirs  = @("docs/decisions", "docs/specs", "docs/guides", "validation", "notes")
    }
    "tier-3" = @{
        files = @("CODE_OF_CONDUCT.md", "SECURITY.md", "CODEOWNERS", "CITATION.cff")
    }
    "ml" = @{
        files = @("notebooks/README.md", "binder/requirements.txt", "binder/postBuild", "examples/README.md")
        dirs  = @("notebooks", "binder", "examples")
    }
    "web" = @{
        files = @("Dockerfile", "docker-compose.yml", "start.ps1", "stop.ps1", ".dockerignore")
    }
    "academic" = @{
        files = @("mkdocs.yml", "docs/papers/README.md", "docs/index.md", ".github/workflows/docs.yml", "CITATION.cff")
        dirs  = @("docs/papers")
    }
    "devcontainer" = @{
        files = @(".devcontainer/devcontainer.json", ".devcontainer/Dockerfile", ".devcontainer/postCreateCommand.sh")
        dirs  = @(".devcontainer")
    }
    "supply-chain" = @{
        files = @(".github/dependabot.yml", ".github/workflows/sbom.yml", ".github/workflows/scorecard.yml")
    }
    "infra" = @{
        files = @(".github/workflows/iac-scan.yml", "infra/README.md")
        dirs  = @("infra")
    }
    "code-intel" = @{
        files = @(
            "scripts/reindex.ps1",
            "docs/decisions/0002-code-graph-with-gitnexus.md",
            ".gitnexus-domains.json.example",
            ".gitnexus-policy.json.example",
            ".claude/skills/.gitkeep"
        )
        appends = @{
            "AGENTS.md"  = "Code-graph context"
            "CLAUDE.md"  = "GitNexus MCP integration"
            ".gitignore" = ".gitnexus/"
            "Makefile"   = "graph-status"
        }
    }
}

# --- Counters / state -----------------------------------------------------
$failures = @()
$warnings = @()
$checksPassed = 0
$packsChecked = @()

function Test-Pack {
    param([string]$Name)
    $sig = $signatures[$Name]
    if (-not $sig) { return }
    $script:packsChecked += $Name

    if ($sig.dirs) {
        foreach ($d in $sig.dirs) {
            $full = Join-Path $Path $d
            if (-not (Test-Path $full -PathType Container)) {
                $script:failures += "[$Name] missing directory : $d"
                if ($FailFast) { Show-Report; exit 1 }
            } else {
                $script:checksPassed++
            }
        }
    }
    if ($sig.files) {
        foreach ($f in $sig.files) {
            $full = Join-Path $Path $f
            if (-not (Test-Path $full -PathType Leaf)) {
                $script:failures += "[$Name] missing file : $f"
                if ($FailFast) { Show-Report; exit 1 }
            } else {
                $script:checksPassed++
            }
        }
    }
    if ($sig.appends) {
        foreach ($target in $sig.appends.Keys) {
            $marker = $sig.appends[$target]
            $full = Join-Path $Path $target
            if (-not (Test-Path $full -PathType Leaf)) {
                $script:failures += "[$Name] missing append target : $target"
                if ($FailFast) { Show-Report; exit 1 }
                continue
            }
            $content = Get-Content $full -Raw -ErrorAction SilentlyContinue
            if ($content -notmatch [regex]::Escape($marker)) {
                $script:failures += "[$Name] $target exists but does NOT contain expected marker '$marker' (the .append fragment may not have been applied)"
                if ($FailFast) { Show-Report; exit 1 }
            } else {
                $script:checksPassed++
            }
        }
    }
}

function Show-Report {
    Write-Host ""
    Write-Host "=== validate.ps1 report ===" -ForegroundColor Cyan
    Write-Host "Project   : $Path"
    Write-Host "Claimed   : tier $Tier, addons $($AddonList -join ',')"
    Write-Host "Packs     : $($packsChecked -join ', ')"
    Write-Host ""
    Write-Host "PASSED    : $checksPassed checks" -ForegroundColor Green
    if ($warnings.Count) {
        Write-Host "WARNINGS  : $($warnings.Count)" -ForegroundColor Yellow
        $warnings | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    }
    if ($failures.Count) {
        Write-Host "FAILED    : $($failures.Count)" -ForegroundColor Red
        $failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }
    Write-Host ""
}

# --- Run checks -----------------------------------------------------------
Write-Host "Validating $Path against tier $Tier + addons [$($AddonList -join ',')] ..." -ForegroundColor Cyan

# Tier checks are monotonic : tier 2 ⊃ tier 1, tier 3 ⊃ tier 2
Test-Pack "tier-1"
if ([int]$Tier -ge 2) { Test-Pack "tier-2" }
if ([int]$Tier -eq 3) { Test-Pack "tier-3" }

foreach ($addon in $AddonList) {
    Test-Pack $addon
}

# --- Placeholder scan -----------------------------------------------------
Write-Host "Scanning for leftover placeholders..." -ForegroundColor Cyan
$exclude = @(".git", "node_modules", ".venv", "venv", ".gitnexus", "site", "_build", "__pycache__")
$placeholderHits = Get-ChildItem -Recurse -File $Path -ErrorAction SilentlyContinue |
    Where-Object {
        $p = $_.FullName
        -not ($exclude | Where-Object { $p -like "*\$_\*" -or $p -like "*\$_" })
    } |
    Select-String -Pattern '\{\{[A-Z_]+\}\}' -ErrorAction SilentlyContinue

if ($placeholderHits) {
    foreach ($hit in $placeholderHits) {
        $rel = $hit.Path.Replace($Path, "").TrimStart('\','/')
        $failures += "[placeholder] $rel`:$($hit.LineNumber) -> $($hit.Matches[0].Value)"
    }
}

# --- Report + exit --------------------------------------------------------
Show-Report
if ($failures.Count) { exit 1 } else { exit 0 }
