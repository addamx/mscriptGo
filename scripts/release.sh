#!/usr/bin/env bash

set -euo pipefail

VERSION="${1:-}"
REPO="${MSCRIPT_REPO:-addamx/mscriptGo}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: bash scripts/release.sh <version>"
  echo "Example: bash scripts/release.sh v0.1.0"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"

cd "$ROOT_DIR"

echo "Build release artifacts"
bash "$ROOT_DIR/scripts/build-all.sh"

echo
echo "Create GitHub release $VERSION"

assets=(
  "$DIST_DIR/mscript-windows-amd64.exe"
  "$DIST_DIR/mscript-windows-arm64.exe"
  "$DIST_DIR/mscript-linux-amd64"
  "$DIST_DIR/mscript-linux-arm64"
)

if command -v gh >/dev/null 2>&1; then
  gh release create "$VERSION" \
    "${assets[@]}" \
    --repo "$REPO" \
    --title "$VERSION" \
    --notes "mscript $VERSION"
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: gh not found, and curl is also unavailable."
  echo "Install GitHub CLI, or set GITHUB_TOKEN and ensure curl is installed."
  exit 1
fi

TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [[ -z "$TOKEN" ]]; then
  echo "Error: gh not found."
  echo "Fallback requires GITHUB_TOKEN or GH_TOKEN."
  exit 1
fi

api_url="https://api.github.com/repos/$REPO/releases"
payload="$(printf '{"tag_name":"%s","name":"%s","body":"mscript %s"}' "$VERSION" "$VERSION" "$VERSION")"

response_file="$(mktemp)"
cleanup() {
  rm -f "$response_file"
}
trap cleanup EXIT

curl -fsSL \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "$api_url" \
  -d "$payload" \
  > "$response_file"

upload_url="$(sed -n 's/.*"upload_url":[[:space:]]*"\([^"]*\){.*$/\1/p' "$response_file" | head -n 1)"
upload_url="${upload_url%\{*}"

if [[ -z "$upload_url" ]]; then
  echo "Error: failed to create release or parse upload_url."
  cat "$response_file"
  exit 1
fi

for asset in "${assets[@]}"; do
  name="$(basename "$asset")"
  echo "Upload $name"
  curl -fsSL \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/octet-stream" \
    --data-binary @"$asset" \
    "${upload_url}?name=${name}" \
    > /dev/null
done
