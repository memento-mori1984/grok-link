# Launch Grok Link (or focus the running instance) and verify the bridge.
$ErrorActionPreference = "Stop"

$installDir = Join-Path $env:LOCALAPPDATA "Programs\Grok Link"
$exe = Get-ChildItem $installDir -File -Filter "Grok Link *.exe" -ErrorAction SilentlyContinue |
    Sort-Object { [version]($_.BaseName -replace '^Grok Link ', '') } -Descending |
    Select-Object -First 1

if (-not $exe) {
    $dist = Join-Path (Split-Path $PSScriptRoot -Parent) "dist"
    $exe = Get-ChildItem $dist -File -Filter "Grok Link *.exe" -ErrorAction SilentlyContinue |
        Sort-Object { [version]($_.BaseName -replace '^Grok Link ', '') } -Descending |
        Select-Object -First 1
}

if (-not $exe) {
    Write-Error "Grok Link not installed. Run Install-Grok-Link.ps1 first."
}

$procName = [System.IO.Path]::GetFileNameWithoutExtension($exe.Name)
Write-Host "Launching $($exe.Name)..." -ForegroundColor Cyan
$proc = Start-Process -FilePath $exe.FullName -WorkingDirectory $exe.DirectoryName -PassThru
Start-Sleep -Seconds 2

$running = Get-Process -Name $procName -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $running) {
    if ($proc.HasExited -and $proc.ExitCode -eq 0) {
        try {
            $null = Invoke-RestMethod "http://127.0.0.1:3877/api/health" -TimeoutSec 3
            $running = Get-Process -Name $procName -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $running) {
                $running = Get-Process | Where-Object {
                    $_.ProcessName -eq 'grok-link' -or $_.ProcessName -like 'Grok Link*'
                } | Select-Object -First 1
            }
            if ($running) {
                Write-Host "Single-instance focus: existing Grok Link (PID $($running.Id))." -ForegroundColor Cyan
            }
        } catch {
            # fall through to error below
        }
    }
    if (-not $running) {
        if ($proc.HasExited) {
            Write-Error "Grok Link exited immediately (code $($proc.ExitCode))."
        }
        Write-Error "Grok Link process not found after launch."
    }
}

Start-Sleep -Seconds 1
try {
    $health = Invoke-RestMethod "http://127.0.0.1:3877/api/health" -TimeoutSec 5
    Write-Host "Grok Link running (PID $($running.Id)). Bridge: $($health.service)" -ForegroundColor Green
} catch {
    Write-Host "Process running (PID $($running.Id)) but bridge not responding yet." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "In Task Manager, look for: $procName" -ForegroundColor Cyan
Write-Host "Window title: Grok Link (close hides to tray; use tray icon to restore)" -ForegroundColor Cyan