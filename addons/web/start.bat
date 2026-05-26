@echo off
REM Windows fallback for users without PowerShell execution policy.
REM Adapt to your project — this is a minimal docker compose + browser-open.

cd /d "%~dp0"
docker compose up -d --build
if errorlevel 1 (
    echo Build/start failed.
    pause
    exit /b 1
)

timeout /t 5 /nobreak >nul
start "" http://localhost:8000
