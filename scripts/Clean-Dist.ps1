# Remove stale build artifacts from dist\ — keeps only the current version exe.
param(
    [switch]$IncludeRelease
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$ver = Get-Content (Join-Path $root "version.json") -Raw | ConvertFrom-Json
$version = "{0}.{1}.{2}" -f $ver.major, $ver.minor, $ver.iteration
$product = if ($ver.productName) { $ver.productName } else { "Grok Link" }
$keepExe = "$product $version.exe"
$keepSha = "$keepExe.sha256"

$dist = Join-Path $root "dist"
if (-not (Test-Path $dist)) {
    Write-Host "No dist folder." -ForegroundColor Yellow
    exit 0
}

$removed = 0
Get-ChildItem $dist -File | Where-Object {
    $_.Name -like "$product *.exe" -or $_.Name -like "$product *.exe.sha256"
} | Where-Object { $_.Name -ne $keepExe -and $_.Name -ne $keepSha } | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "Removed: $($_.Name)" -ForegroundColor DarkGray
    $removed++
}

if ($IncludeRelease) {
    $releaseDir = Join-Path $dist "release"
    if (Test-Path $releaseDir) {
        Get-ChildItem $releaseDir | Where-Object {
            $_.Name -notlike "Grok-Link-$version-win64*"
        } | ForEach-Object {
            Remove-Item $_.FullName -Recurse -Force
            Write-Host "Removed: release\$($_.Name)" -ForegroundColor DarkGray
            $removed++
        }
    }
}

Write-Host "Cleanup done. Kept: $keepExe ($removed removed)" -ForegroundColor Green