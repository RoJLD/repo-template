<#
.SYNOPSIS
    Stop {{PROJECT_NAME}} services (graceful, keeps the named volume).
#>

Set-Location $PSScriptRoot
docker compose down
Write-Host "Stopped {{PROJECT_NAME}}. Volume kept (use 'docker compose down -v' to wipe state)." -ForegroundColor Yellow
