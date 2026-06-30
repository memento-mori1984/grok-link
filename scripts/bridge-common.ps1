# Shared helpers for Grok Link bridge scripts.
$script:DefaultBridgePort = 3877

function Get-BridgeBaseUrl {
    param([int]$Port = $script:DefaultBridgePort)
    "http://127.0.0.1:$Port"
}

function Format-SuperGrokMessage {
    param(
        [string]$Message,
        [string]$Context = ""
    )
    $message = ($Message | Out-String).Trim()
    $context = ($Context | Out-String).Trim()
    if (-not $message) { throw "Message is required." }
    if (-not $context) { return $message }
    "[Grok Build context]`n$context`n`n[Message]`n$message"
}

function Build-SuperGrokUrl {
    param(
        [string]$Message,
        [string]$Context = "",
        [string]$HandoffId = "",
        [ValidateSet("com", "xai")]
        [string]$GrokHost = "com"
    )
    $composed = Format-SuperGrokMessage -Message $Message -Context $Context
    $encoded = [uri]::EscapeDataString($composed)
    $base = if ($GrokHost -eq "xai") { "https://grok.x.ai/" } else { "https://grok.com/" }
    $url = "${base}?q=$encoded"
    if ($HandoffId) {
        $url += "#grok-link-id=$HandoffId"
    }
    $url
}

function Get-Handoff {
    param(
        [Parameter(Mandatory)][string]$Id,
        [int]$Port = $script:DefaultBridgePort
    )
    Invoke-RestMethod -Uri "$(Get-BridgeBaseUrl -Port $Port)/api/handoffs/$Id" -Method Get -TimeoutSec 10
}