param(
    [string]$Version = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root "dist"

New-Item -ItemType Directory -Force -Path $dist | Out-Null

$targets = @(
    @{ GOOS = "linux"; GOARCH = "amd64"; Output = "mscript-linux-amd64" },
    @{ GOOS = "linux"; GOARCH = "arm64"; Output = "mscript-linux-arm64" }
)

$originalGoos = $env:GOOS
$originalGoarch = $env:GOARCH
$originalCgo = $env:CGO_ENABLED

try {
    foreach ($target in $targets) {
        $name = $target.Output
        if ($Version -ne "") {
            $name = "$name-$Version"
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
