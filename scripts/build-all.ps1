param(
    [string]$Version = ""
)

$ErrorActionPreference = "Stop"

$windowsScript = Join-Path $PSScriptRoot "build-windows.ps1"
$linuxScript = Join-Path $PSScriptRoot "build-linux.ps1"

Write-Host "Build windows binaries"
& $windowsScript -Version $Version

Write-Host ""
Write-Host "Build linux binaries"
& $linuxScript -Version $Version
