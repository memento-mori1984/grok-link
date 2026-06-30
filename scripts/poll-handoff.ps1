# Poll a Grok Link handoff until SuperGrok's reply is saved.
param(
    [Parameter(Mandatory = $true)]
    [string]$Id,
    [int]$Port = 3877,
    [int]$TimeoutSec = 600,
    [int]$IntervalSec = 5
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\bridge-common.ps1"

if (-not (Ensure-GrokLinkRunning -Port $Port)) {
    Write-Error "Grok Link bridge not available. Launch Grok Link from the desktop shortcut or tray."
}

$deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSec)
$lastStatus = ""

while ([DateTime]::UtcNow -lt $deadline) {
    try {
        $item = Get-Handoff -Id $Id -Port $Port
    } catch {
        Write-Host "Bridge unreachable — restarting Grok Link if needed..." -ForegroundColor Yellow
        if (-not (Ensure-GrokLinkRunning -Port $Port -WaitSec 30)) {
            Write-Host "Still waiting for bridge..." -ForegroundColor Yellow
        }
        Start-Sleep -Seconds $IntervalSec
        continue
    }
    if ($item.status -ne $lastStatus) {
        Write-Host "Handoff status: $($item.status)" -ForegroundColor Cyan
        $lastStatus = $item.status
    }
    if ($item.status -eq "answered" -and $item.response) {
        Write-Host "Handoff answered: $Id" -ForegroundColor Green
        $item | ConvertTo-Json -Depth 5
        exit 0
    }
    Start-Sleep -Seconds $IntervalSec
}

Write-Error "Timed out after ${TimeoutSec}s waiting for handoff $Id"
exit 1