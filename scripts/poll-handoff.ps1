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

$deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSec)

while ([DateTime]::UtcNow -lt $deadline) {
    $item = Get-Handoff -Id $Id -Port $Port
    if ($item.status -eq "answered" -and $item.response) {
        Write-Host "Handoff answered: $Id" -ForegroundColor Green
        $item | ConvertTo-Json -Depth 5
        exit 0
    }
    Start-Sleep -Seconds $IntervalSec
}

Write-Error "Timed out after ${TimeoutSec}s waiting for handoff $Id"
exit 1