#!/usr/bin/env bash

set -euo pipefail

REPO="${MSCRIPT_REPO:-addamx/mscriptGo}"
VERSION="${MSCRIPT_VERSION:-latest}"
BIN_DIR="${MSCRIPT_BIN_DIR:-$HOME/.local/bin}"

uname_s="$(uname -s)"
uname_m="$(uname -m)"

case "$uname_s" in
  Linux)
    os="linux"
    ext=""
    ;;
  MINGW*|MSYS*|CYGWIN*)
    os="windows"
    ext=".exe"
    ;;
  *)
    echo "Unsupported OS: $uname_s"
    exit 1
    ;;
esac

case "$uname_m" in
  x86_64|amd64)
    arch="amd64"
    ;;
  aarch64|arm64)
    arch="arm64"
    ;;
  *)
    echo "Unsupported architecture: $uname_m"
    exit 1
    ;;
esac

asset="mscript-$os-$arch$ext"

if [[ "$VERSION" == "latest" ]]; then
  download_url="https://github.com/$REPO/releases/latest/download/$asset"
else
  download_url="https://github.com/$REPO/releases/download/$VERSION/$asset"
fi

mkdir -p "$BIN_DIR"

target="$BIN_DIR/mscript$ext"
temp_file="$(mktemp)"

cleanup() {
  rm -f "$temp_file"
}

trap cleanup EXIT

echo "Downloading $download_url"

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$download_url" -o "$temp_file"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$temp_file" "$download_url"
else
  echo "curl or wget is required"
  exit 1
fi

mv "$temp_file" "$target"
chmod +x "$target"

echo "Installed to $target"

case ":$PATH:" in
  *":$BIN_DIR:"*)
    ;;
  *)
    echo "Add $BIN_DIR to PATH to use mscript directly"
    ;;
esac

echo "Run: $target"
