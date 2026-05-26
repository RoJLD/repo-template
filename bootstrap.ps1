#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Bootstrap a new project from the repo-template.

.DESCRIPTION
    Copies the tier-2 skeleton, layers tier-3 additions and addon packs, replaces
    placeholders with values, and optionally initializes git + first commit.

    Two ways to use:
      1. -Recipe <name>      : load a pre-baked recipe from recipes/<name>.json
                               (each recipe pins a tier + addon list).
      2. -Tier + -Addons     : compose manually.

    Recipes available (see recipes/README.md) :
      prototype | private-tool | ml-research | web-service |
      oss-library | academic-library | full-stack-research | cloud-deployment

    Addons available (see addons/) :
      ml | web | academic | devcontainer | supply-chain | infra

.PARAMETER Name
    Project name in kebab-case (e.g. "my-awesome-project").

.PARAMETER Title
    Human-readable title for the README h1.

.PARAMETER Description
    One-line description for README and pyproject.toml.

.PARAMETER Recipe
    Name of a recipe in recipes/<name>.json. Sets tier + addons in one shot.
    If provided, overrides -Tier and -Addons.

.PARAMETER Tier
    Discipline tier : 1 (prototype), 2 (private tool, default), 3 (OSS).

.PARAMETER Addons
    Comma-separated addon list, e.g. "ml,academic" or "web,devcontainer".

.PARAMETER Path
    Where to create the new project. Defaults to C:\Users\rdenis\VScode.

.PARAMETER Author / Email / GitHubUser / GitHubRepo / PythonVersion / License
    Standard project metadata (see defaults below).

.PARAMETER InitGit
    If true, runs git init + first commit. Default true.

.EXAMPLE
    .\bootstrap.ps1 -Name "my-tool" -Title "My Tool" -Description "Does X for Y."
    # Default : tier 2, no addons.

.EXAMPLE
    .\bootstrap.ps1 -Name "my-engine" -Title "My Engine" `
        -Description "HMM toolkit." -Recipe "ml-research"

.EXAMPLE
    .\bootstrap.ps1 -Name "my-lib" -Title "My Lib" `
        -Description "Public lib." -Tier 3 -Addons "supply-chain"
#>

param(
    [Parameter(Mandatory=$true)][string]$Name,
    [Parameter(Mandatory=$true)][string]$Title,
    [Parameter(Mandatory=$true)][string]$Description,
    [string]$Recipe = "",
    [ValidateSet("1","2","3")][string]$Tier = "2",
    [string]$Addons = "",
    [string]$Path = "C:\Users\rdenis\VScode",
    [string]$Author = "Robin Denis",
    [string]$Email = "robin.denis1207@gmail.com",
    [string]$GitHubUser = "RoJLD",
    [string]$GitHubRepo = "",
    [string]$PythonVersion = "3.11",
    [string]$License = "MIT",
    [bool]$InitGit = $true
)

$ErrorActionPreference = "Stop"

$TemplateDir = Split-Path -Parent $PSCommandPath

# --- Resolve recipe (if any) ----------------------------------------------
$AddonList = @()
if ($Recipe) {
    $recipePath = Join-Path $TemplateDir "recipes\$Recipe.json"
    if (-not (Test-Path $recipePath)) {
        Write-Host "ERROR : recipe not found : $recipePath" -ForegroundColor Red
        Write-Host "Available recipes :" -ForegroundColor Yellow
        Get-ChildItem (Join-Path $TemplateDir "recipes") -Filter "*.json" |
            ForEach-Object { Write-Host "  - $($_.BaseName)" }
        exit 1
    }
    $recipeData = Get-Content $recipePath -Raw | ConvertFrom-Json
    $Tier = "$($recipeData.tier)"
    if ($recipeData.addons) { $AddonList = @($recipeData.addons) }
    Write-Host "Loaded recipe : $Recipe (tier $Tier, addons: $($AddonList -join ', '))" -ForegroundColor Cyan
} elseif ($Addons) {
    $AddonList = $Addons -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

# Validate addons
$validAddons = @("ml", "web", "academic", "devcontainer", "supply-chain", "infra", "code-intel")
foreach ($a in $AddonList) {
    if ($a -notin $validAddons) {
        Write-Host "ERROR : unknown addon '$a'. Valid : $($validAddons -join ', ')" -ForegroundColor Red
        exit 1
    }
}

# --- Derived metadata -----------------------------------------------------
if (-not $GitHubRepo) {
    $GitHubRepo = ($Name -split '-' | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) }) -join ''
}
$Year = (Get-Date).Year
$PythonVersionNoDot = $PythonVersion -replace '\.', ''
$AuthorParts = $Author -split ' '
$AuthorNameLast = $AuthorParts[-1]
$AuthorNameFirst = ($AuthorParts | Select-Object -SkipLast 1) -join ' '

$Source = Join-Path $TemplateDir "template"
$Dest = Join-Path $Path $GitHubRepo

Write-Host ""
Write-Host "=== repo-template bootstrap ===" -ForegroundColor Cyan
Write-Host "Source       : $Source"
Write-Host "Destination  : $Dest"
Write-Host "Name         : $Name"
Write-Host "Title        : $Title"
Write-Host "Description  : $Description"
Write-Host "Author       : $Author <$Email>"
Write-Host "GitHub       : $GitHubUser/$GitHubRepo"
Write-Host "Python       : $PythonVersion"
Write-Host "License      : $License"
Write-Host "Year         : $Year"
Write-Host "Tier         : $Tier"
Write-Host "Addons       : $(if ($AddonList) { $AddonList -join ', ' } else { '(none)' })"
Write-Host "Init git     : $InitGit"
Write-Host ""

# --- Safety check ---------------------------------------------------------
if (Test-Path $Dest) {
    Write-Host "ERROR : Destination already exists : $Dest" -ForegroundColor Red
    Write-Host "Remove it first, or choose a different -GitHubRepo." -ForegroundColor Red
    exit 1
}

# --- Copy base skeleton ---------------------------------------------------
Write-Host "Copying template skeleton..." -ForegroundColor Yellow
Copy-Item -Recurse $Source $Dest

# --- Tier 1 trim : strip discipline overhead for prototypes ---------------
if ($Tier -eq "1") {
    Write-Host "Trimming for tier 1 (prototype)..." -ForegroundColor Yellow
    $tier1Strip = @(
        "CHANGELOG.md",
        "docs\specs",
        "docs\decisions",
        "validation",
        "notes",
        "CONTRIBUTING.md"
    )
    foreach ($p in $tier1Strip) {
        $full = Join-Path $Dest $p
        if (Test-Path $full) { Remove-Item -Recurse -Force $full }
    }
}

# --- Placeholders dict ----------------------------------------------------
$placeholders = @{
    'PROJECT_NAME'         = $Name
    'PROJECT_TITLE'        = $Title
    'PROJECT_DESCRIPTION'  = $Description
    'AUTHOR_NAME'          = $Author
    'AUTHOR_NAME_FIRST'    = $AuthorNameFirst
    'AUTHOR_NAME_LAST'     = $AuthorNameLast
    'AUTHOR_EMAIL'         = $Email
    'GITHUB_USER'          = $GitHubUser
    'GITHUB_REPO'          = $GitHubRepo
    'YEAR'                 = $Year
    'LICENSE'              = $License
    'PYTHON_VERSION'       = $PythonVersion
    'PYTHON_VERSION_NODOT' = $PythonVersionNoDot
}

function Apply-Placeholders {
    param([string]$Root)
    Get-ChildItem -Recurse -File $Root | ForEach-Object {
        $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            $modified = $false
            foreach ($key in $placeholders.Keys) {
                $token = "{{$key}}"
                if ($content -match [regex]::Escape($token)) {
                    $content = $content -replace [regex]::Escape($token), $placeholders[$key]
                    $modified = $true
                }
            }
            if ($modified) {
                Set-Content $_.FullName -Value $content -NoNewline
            }
        }
    }
}

# --- Tier 3 additions -----------------------------------------------------
if ($Tier -eq "3") {
    Write-Host "Copying tier-3 additions..." -ForegroundColor Yellow
    $tier3Source = Join-Path $TemplateDir "tier-3-additions"
    # Filter via Where-Object — PowerShell 5.1 has a known bug where
    # Get-ChildItem -File -Exclude returns nothing without a wildcard path.
    Get-ChildItem -File $tier3Source | Where-Object { $_.Name -ne "README.md" } | ForEach-Object {
        Copy-Item $_.FullName -Destination $Dest
    }
}

# --- Merge addons ---------------------------------------------------------
# Convention :
#   - addon/README.md at the addon root is excluded (it documents the addon)
#   - addon/foo.bar.append  -> appends to dest/foo.bar (or creates if absent)
#   - everything else copies as-is (subdirectories merge recursively)
#   - README.md inside subdirectories (e.g. notebooks/README.md) IS copied
function Copy-AddonTree {
    param(
        [string]$AddonRoot,
        [string]$DestRoot,
        [switch]$TopLevel
    )
    Get-ChildItem -Force $AddonRoot | Where-Object {
        # Only skip README.md at the top-level of the addon
        -not ($TopLevel -and $_.Name -eq "README.md")
    } | ForEach-Object {
        if ($_.PSIsContainer) {
            $target = Join-Path $DestRoot $_.Name
            if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target | Out-Null }
            Copy-AddonTree -AddonRoot $_.FullName -DestRoot $target
        } elseif ($_.Name -like "*.append") {
            $targetName = $_.Name -replace '\.append$', ''
            $target = Join-Path $DestRoot $targetName
            $content = Get-Content $_.FullName -Raw
            if (Test-Path $target) {
                # Append with a blank line separator
                Add-Content -Path $target -Value "`r`n$content"
            } else {
                # File doesn't exist yet -> create it from the fragment
                Set-Content -Path $target -Value $content -NoNewline
            }
        } else {
            $target = Join-Path $DestRoot $_.Name
            Copy-Item -Force $_.FullName $target
        }
    }
}

foreach ($addon in $AddonList) {
    Write-Host "Layering addon : $addon ..." -ForegroundColor Yellow
    $addonDir = Join-Path $TemplateDir "addons\$addon"
    if (-not (Test-Path $addonDir)) {
        Write-Host "  WARNING : addon dir missing : $addonDir" -ForegroundColor Yellow
        continue
    }
    Copy-AddonTree -AddonRoot $addonDir -DestRoot $Dest -TopLevel
}

# --- Apply placeholders across the merged tree ---------------------------
Write-Host "Replacing placeholders..." -ForegroundColor Yellow
Apply-Placeholders -Root $Dest

# --- Verify no placeholders left -----------------------------------------
$remaining = Get-ChildItem -Recurse -File $Dest | Select-String -Pattern '\{\{[A-Z_]+\}\}' -ErrorAction SilentlyContinue
if ($remaining) {
    Write-Host ""
    Write-Host "WARNING : remaining placeholders found :" -ForegroundColor Yellow
    $remaining | ForEach-Object { Write-Host "  $($_.Path):$($_.LineNumber) -> $($_.Matches[0].Value)" }
    Write-Host "Edit these manually."
}

# --- Init git ------------------------------------------------------------
if ($InitGit) {
    Write-Host "Initializing git..." -ForegroundColor Yellow
    Push-Location $Dest
    git init -q -b main
    git add -A
    $tierLabel = "Tier $Tier"
    $addonLabel = if ($AddonList) { " + addons: $($AddonList -join ', ')" } else { "" }
    $recipeLabel = if ($Recipe) { " (recipe: $Recipe)" } else { "" }
    git commit -q -m "chore: bootstrap from repo-template

Bootstrapped on $(Get-Date -Format 'yyyy-MM-dd') via bootstrap.ps1.
$tierLabel$addonLabel$recipeLabel.

Co-Authored-By: repo-template <noreply@example.com>"
    Pop-Location
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Next steps :" -ForegroundColor Cyan
Write-Host "  cd $Dest"
Write-Host "  # Read docs/roadmap.md and write your Phase A"
if ($Tier -ne "1") {
    Write-Host "  # Write docs/decisions/0001-*.md for your first major choice"
}
Write-Host "  pip install -e `".[dev]`""
Write-Host "  pytest"
if ($AddonList -contains "web") {
    Write-Host "  # web addon : .\start.ps1 to launch docker-compose"
}
if ($AddonList -contains "academic") {
    Write-Host "  # academic addon : mkdocs serve to preview the doc site"
}
if ($AddonList -contains "devcontainer") {
    Write-Host "  # devcontainer : open in VS Code -> 'Reopen in Container'"
}
if ($AddonList -contains "code-intel") {
    Write-Host "  # code-intel : ensure gitnexus daemon runs (cd ../gitnexus && .\start.ps1)"
    Write-Host "  # code-intel : index via .\scripts\reindex.ps1 (after first commit)"
}
if (-not $InitGit) {
    Write-Host "  git init && git add -A && git commit -m 'chore: bootstrap'"
}
Write-Host ""
