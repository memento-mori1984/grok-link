# Install Grok Link portable exe to LocalAppData\Programs and create a desktop shortcut.
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$dist = Join-Path $root "dist"
$exe = Get-ChildItem $dist -File -Filter "Grok Link *.exe" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $exe) {
    Write-Error "No build in dist\. Run .\scripts\build.ps1 first."
}

$installDir = Join-Path $env:LOCALAPPDATA "Programs\Grok Link"
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Get-ChildItem $installDir -File -Filter "Grok Link *.exe" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne $exe.Name } | Remove-Item -Force
Get-ChildItem $installDir -File -Filter "Grok Link *.exe.sha256" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne "$($exe.Name).sha256" } | Remove-Item -Force
Copy-Item $exe.FullName (Join-Path $installDir $exe.Name) -Force
$browserSrc = Join-Path $root "browser"
if (Test-Path $browserSrc) {
    Copy-Item $browserSrc (Join-Path $installDir "browser") -Recurse -Force
}
$sha = "$($exe.FullName).sha256"
if (Test-Path $sha) {
    Copy-Item $sha (Join-Path $installDir "$($exe.Name).sha256") -Force
}

$desktop = [Environment]::GetFolderPath("Desktop")
$lnkPath = Join-Path $desktop "Grok Link.lnk"
$sh = New-Object -ComObject WScript.Shell
$lnk = $sh.CreateShortcut($lnkPath)
$installedExe = Join-Path $installDir $exe.Name
$lnk.TargetPath = $installedExe
$lnk.WorkingDirectory = $installDir
$lnk.Save()

& (Join-Path $PSScriptRoot "scripts\Set-Startup.ps1") -ExePath $installedExe

Write-Host "Installed: $installedExe" -ForegroundColor Green
Write-Host "Shortcut:  $lnkPath" -ForegroundColor Green
Write-Host "Startup:   enabled (Grok Link launches when you sign in to Windows)" -ForegroundColor Green