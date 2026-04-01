#!/usr/bin/env bash

set -euo pipefail

VERSION="${1:-}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"

mkdir -p "$DIST_DIR"

targets=(
  "linux amd64 mscript-linux-amd64"
  "linux arm64 mscript-linux-arm64"
)

for target in "${targets[@]}"; do
  read -r goos goarch output <<<"$target"

  if [[ -n "$VERSION" ]]; then
    output="$output-$VERSION"
  fi

  echo "Building $goos/$goarch -> $DIST_DIR/$output"
  (
    cd "$ROOT_DIR"
    GOOS="$goos" GOARCH="$goarch" CGO_ENABLED=0 \
      go build -trimpath -ldflags="-s -w" -o "$DIST_DIR/$output" .
  )
done
