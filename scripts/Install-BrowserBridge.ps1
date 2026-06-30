# Install instructions for the Grok Link browser bridge (Tampermonkey userscript).
$ErrorActionPreference = "Stop"

$root = Split-Path $PSScriptRoot -Parent
$scriptPath = Join-Path $root "browser\grok-link-bridge.user.js"

if (-not (Test-Path $scriptPath)) {
    Write-Error "Browser bridge not found: $scriptPath"
}

Write-Host "=== Grok Link Browser Bridge ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "This userscript auto-syncs SuperGrok replies back to Grok Build." -ForegroundColor White
Write-Host ""
Write-Host "1. Install Tampermonkey (Chrome/Edge/Firefox)" -ForegroundColor Yellow
Write-Host "   https://www.tampermonkey.net/" -ForegroundColor Gray
Write-Host "2. Tampermonkey -> Create new script -> replace contents with:" -ForegroundColor Yellow
Write-Host "   $scriptPath" -ForegroundColor Green
Write-Host "3. Save. Ensure the script is enabled on grok.com" -ForegroundColor Yellow
Write-Host ""
Write-Host "Opening script file..." -ForegroundColor Cyan
Start-Process notepad.exe $scriptPath