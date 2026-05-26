#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Add one or more addons to an already-bootstrapped project.

.DESCRIPTION
    Inspired by Nx generators : you don't have to re-bootstrap a project
    just to add a capability. If you started with -Recipe private-tool
    and now need notebooks, run :

        .\add-addon.ps1 -Path "C:\path\to\project" -Addons "ml"

    The script :
      1. Reads .repo-template-answers.json in the target to know its
         current tier + addons
      2. Refuses to add an addon already present
      3. Layers the addon's files (using the same merge logic as
         bootstrap.ps1 : .append files are appended, others copied)
      4. Replaces placeholders using values from the answers file
      5. Updates the answers file to record the new addon

    The project must have been bootstrapped via bootstrap.ps1 (i.e. have
    a .repo-template-answers.json). Without it, run validate.ps1 first
    to confirm what state the project is in.

.PARAMETER Path
    Path to the existing project (must contain .repo-template-answers.json).

.PARAMETER Addons
    Comma-separated list of addons to add (e.g. "ml,academic").

.EXAMPLE
    .\add-addon.ps1 -Path "..\my-tool" -Addons "code-intel"

.EXAMPLE
    .\add-addon.ps1 -Path "..\my-research" -Addons "ml,academic"
#>

param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string]$Addons
)

$ErrorActionPreference = "Stop"
$TemplateDir = Split-Path -Parent $PSCommandPath
$Path = (Resolve-Path $Path).Path

# --- Load answers file ---------------------------------------------------
$answersPath = Join-Path $Path ".repo-template-answers.json"
if (-not (Test-Path $answersPath)) {
    Write-Host "ERROR : no .repo-template-answers.json at $answersPath" -ForegroundColor Red
    Write-Host "       This project wasn't bootstrapped via bootstrap.ps1, or the file was deleted." -ForegroundColor Yellow
    Write-Host "       Manually merge the addon, or re-bootstrap from scratch." -ForegroundColor Yellow
    exit 2
}
$answers = Get-Content $answersPath -Raw | ConvertFrom-Json
$currentAddons = @($answers.addons)

# --- Validate requested addons -------------------------------------------
$validAddons = @("ml", "web", "academic", "devcontainer", "supply-chain", "infra", "code-intel")
$requested = $Addons -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
$toAdd = @()

foreach ($a in $requested) {
    if ($a -notin $validAddons) {
        Write-Host "ERROR : unknown addon '$a'. Valid : $($validAddons -join ', ')" -ForegroundColor Red
        exit 1
    }
    if ($a -in $currentAddons) {
        Write-Host "SKIP : '$a' already installed (per answers file)." -ForegroundColor Yellow
    } else {
        $toAdd += $a
    }
}

if (-not $toAdd) {
    Write-Host "Nothing to do." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "=== add-addon.ps1 ===" -ForegroundColor Cyan
Write-Host "Project       : $Path"
Write-Host "Current tier  : $($answers.tier)"
Write-Host "Current addons: $($currentAddons -join ', ')"
Write-Host "Adding        : $($toAdd -join ', ')"
Write-Host ""

# --- Copy-AddonTree (mirrored from bootstrap.ps1) ------------------------
# Convention :
#   - addon/README.md at top-level is excluded
#   - addon/foo.bar.append  -> appends to dest/foo.bar (or creates)
#   - everything else copies; subdirectories recurse
function Copy-AddonTree {
    param(
        [string]$AddonRoot,
        [string]$DestRoot,
        [switch]$TopLevel
    )
    Get-ChildItem -Force $AddonRoot | Where-Object {
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
                Add-Content -Path $target -Value "`r`n$content"
            } else {
                Set-Content -Path $target -Value $content -NoNewline
            }
        } else {
            $target = Join-Path $DestRoot $_.Name
            if (Test-Path $target) {
                Write-Host "  WARN : overwriting existing $($_.Name)" -ForegroundColor Yellow
            }
            Copy-Item -Force $_.FullName $target
        }
    }
}

# --- Layer each new addon ------------------------------------------------
foreach ($a in $toAdd) {
    Write-Host "Layering $a ..." -ForegroundColor Yellow
    $addonDir = Join-Path $TemplateDir "addons\$a"
    if (-not (Test-Path $addonDir)) {
        Write-Host "  ERROR : addon dir missing : $addonDir" -ForegroundColor Red
        exit 1
    }
    Copy-AddonTree -AddonRoot $addonDir -DestRoot $Path -TopLevel
}

# --- Re-apply placeholders to the new files ------------------------------
# We use the placeholders dict recorded in the answers file at bootstrap time.
Write-Host "Replacing placeholders using values from answers file..." -ForegroundColor Yellow
$placeholders = @{}
foreach ($k in $answers.placeholders.PSObject.Properties.Name) {
    $placeholders[$k] = $answers.placeholders.$k
}
Get-ChildItem -Recurse -File $Path -ErrorAction SilentlyContinue | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return }
    $modified = $false
    foreach ($key in $placeholders.Keys) {
        $token = "{{$key}}"
        if ($content -match [regex]::Escape($token)) {
            $content = $content -replace [regex]::Escape($token), $placeholders[$key]
            $modified = $true
        }
    }
    if ($modified) { Set-Content $_.FullName -Value $content -NoNewline }
}

# --- Update answers file -------------------------------------------------
$newAddons = @($currentAddons + $toAdd) | Select-Object -Unique
$answers.addons = $newAddons
if (-not $answers.PSObject.Properties.Match('history').Count) {
    $answers | Add-Member -NotePropertyName history -NotePropertyValue @()
}
$entry = [ordered]@{
    at      = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')
    action  = "add-addon"
    addons  = $toAdd
}
$answers.history = @($answers.history) + @($entry)
$answers | ConvertTo-Json -Depth 5 | Set-Content -Path $answersPath -NoNewline
Write-Host "Updated $answersPath" -ForegroundColor DarkGray

# --- Verify nothing left in placeholders ---------------------------------
$remaining = Get-ChildItem -Recurse -File $Path | Select-String -Pattern '\{\{[A-Z_]+\}\}' -ErrorAction SilentlyContinue
if ($remaining) {
    Write-Host ""
    Write-Host "WARNING : leftover placeholders :" -ForegroundColor Yellow
    $remaining | Select-Object -First 5 | ForEach-Object {
        $rel = $_.Path.Replace($Path, "").TrimStart('\','/')
        Write-Host "  ${rel}:$($_.LineNumber) -> $($_.Matches[0].Value)"
    }
}

Write-Host ""
Write-Host "Done. Now :" -ForegroundColor Green
Write-Host "  1. Review the new files (git diff / git status)"
Write-Host "  2. Run .\validate.ps1 in the target project to confirm checks pass"
Write-Host "  3. Commit when ready : git add -A && git commit -m 'feat: add $($toAdd -join '+') addon'"
Write-Host ""
