param(
    [string]$Version = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root "dist"

New-Item -ItemType Directory -Force -Path $dist | Out-Null

$targets = @(
    @{ GOOS = "windows"; GOARCH = "amd64"; Output = "mscript-windows-amd64.exe" },
    @{ GOOS = "windows"; GOARCH = "arm64"; Output = "mscript-windows-arm64.exe" }
)

$originalGoos = $env:GOOS
$originalGoarch = $env:GOARCH
$originalCgo = $env:CGO_ENABLED

try {
    foreach ($target in $targets) {
        $name = $target.Output
        if ($Version -ne "") {
            $name = $name.Replace(".exe", "-$Version.exe")
        }

        $output = Join-Path $dist $name

        $env:GOOS = $target.GOOS
        $env:GOARCH = $target.GOARCH
        $env:CGO_ENABLED = "0"

        Write-Host "Building $($target.GOOS)/$($target.GOARCH) -> $output"
        go build -trimpath -ldflags "-s -w" -o $output .
    }
}
finally {
    $env:GOOS = $originalGoos
    $env:GOARCH = $originalGoarch
    $env:CGO_ENABLED = $originalCgo
}
