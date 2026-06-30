# Open SuperGrok in the default browser for an existing handoff.
param(
    [Parameter(Mandatory = $true)]
    [string]$Id,
    [int]$Port = 3877,
    [ValidateSet("com", "xai")]
    [string]$GrokHost = "com"
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\bridge-common.ps1"

$item = Get-Handoff -Id $Id -Port $Port
$url = Build-SuperGrokUrl -Message $item.message -Context $item.context -HandoffId $Id -GrokHost $GrokHost

Write-Host "Opening SuperGrok for handoff $Id" -ForegroundColor Cyan
Write-Host $url -ForegroundColor Gray
Start-Process $url