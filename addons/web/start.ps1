<#
.SYNOPSIS
    Start {{PROJECT_NAME}} via docker compose, wait for health, open browser.

.DESCRIPTION
    Windows one-click launcher. Builds image if needed, brings up services,
    waits for /health, opens default browser. Mirror of start.bat for users
    who can't run .ps1 scripts.
#>

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "Building and starting {{PROJECT_NAME}}..." -ForegroundColor Cyan
docker compose up -d --build

Write-Host "Waiting for /health..." -ForegroundColor Yellow
$maxAttempts = 60
for ($i = 1; $i -le $maxAttempts; $i++) {
    try {
        $r = Invoke-WebRequest -Uri http://localhost:8000/health -TimeoutSec 2 -UseBasicParsing
        if ($r.StatusCode -eq 200) {
            Write-Host "Healthy after $i attempts." -ForegroundColor Green
            break
        }
    } catch {
        Start-Sleep -Seconds 1
    }
    if ($i -eq $maxAttempts) {
        Write-Host "Timed out waiting for /health. Check 'docker compose logs'." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Opening browser..." -ForegroundColor Cyan
Start-Process "http://localhost:8000"
