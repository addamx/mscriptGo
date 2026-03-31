#!/bin/bash

set -e

echo "Start installing Node.js toolchain..."

if ! command -v volta >/dev/null 2>&1; then
    curl https://get.volta.sh | bash
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
fi

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

volta install node@lts
volta install pnpm

npm config set registry https://registry.npmmirror.com
pnpm config set registry https://registry.npmmirror.com

echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "pnpm: $(pnpm --version)"
echo "Volta: $(volta --version)"
