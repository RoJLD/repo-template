#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Trigger a gitnexus re-analysis of this repo.

.DESCRIPTION
    Thin wrapper around the gitnexus daemon's /api/analyze endpoint.
    Assumes :
      - gitnexus daemon is running at http://localhost:4747
      - This repo lives under the daemon's PROJECTS_ROOT bind mount
        (so it's reachable as /data/projects/<folder-name>)

    Pass -Force to drop the existing index and re-index from scratch
    (useful after a big refactor or when the index looks corrupted).

.EXAMPLE
    .\scripts\reindex.ps1
    .\scripts\reindex.ps1 -Force
#>

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Resolve this repo's folder name (matches what gitnexus sees inside the container)
$repoName = Split-Path -Leaf (Get-Location)
$pathInContainer = "/data/projects/$repoName"
$daemon = "http://localhost:4747"

Write-Host "GitNexus reindex" -ForegroundColor Cyan
Write-Host "  Daemon : $daemon"
Write-Host "  Path   : $pathInContainer"
Write-Host "  Force  : $Force"
Write-Host ""

# Health check
try {
    $null = Invoke-RestMethod -Uri "$daemon/api/health" -Method GET -TimeoutSec 3
} catch {
    Write-Host "ERROR : gitnexus daemon not reachable at $daemon" -ForegroundColor Red
    Write-Host "Start it with : cd ..\gitnexus ; .\start.ps1" -ForegroundColor Yellow
    exit 1
}

# Fire the analyze request
$body = @{
    path  = $pathInContainer
    force = [bool]$Force
} | ConvertTo-Json

Write-Host "Triggering analysis..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$daemon/api/analyze" -Method POST -ContentType "application/json" -Body $body
    Write-Host "Response :" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5
} catch {
    Write-Host "ERROR : analyze request failed : $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Done. The index lives at .gitnexus\ next to .git\ (gitignored)." -ForegroundColor Green
Write-Host "Open the web UI : http://localhost:4173" -ForegroundColor Cyan
