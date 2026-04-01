#!/usr/bin/env bash

set -euo pipefail

VERSION="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Build windows binaries"
"$SCRIPT_DIR/build-windows.sh" "$VERSION"

echo
echo "Build linux binaries"
"$SCRIPT_DIR/build-linux.sh" "$VERSION"
