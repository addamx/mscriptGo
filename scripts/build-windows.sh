#!/usr/bin/env bash

set -euo pipefail

VERSION="${1:-}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"

mkdir -p "$DIST_DIR"

targets=(
  "windows amd64 mscript-windows-amd64.exe"
  "windows arm64 mscript-windows-arm64.exe"
)

for target in "${targets[@]}"; do
  read -r goos goarch output <<<"$target"

  if [[ -n "$VERSION" ]]; then
    output="${output%.exe}-$VERSION.exe"
  fi

  echo "Building $goos/$goarch -> $DIST_DIR/$output"
  (
    cd "$ROOT_DIR"
    GOOS="$goos" GOARCH="$goarch" CGO_ENABLED=0 \
      go build -trimpath -ldflags="-s -w" -o "$DIST_DIR/$output" .
  )
done
