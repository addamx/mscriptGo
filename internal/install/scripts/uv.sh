#!/bin/bash

set -e

UV_INSTALL_URL="https://astral.sh/uv/install.sh"
UV_CONFIG_DIR="$HOME/.config/uv"
UV_CONFIG_FILE="$UV_CONFIG_DIR/uv.toml"
MIRROR_URL="https://pypi.tuna.tsinghua.edu.cn/simple/"
PYTHON_VERSION="3.12"

echo "Start installing uv..."

if command -v uv >/dev/null 2>&1; then
    uv --version
    read -p "Reinstall uv? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        curl -LsSf "$UV_INSTALL_URL" | sh
    fi
else
    curl -LsSf "$UV_INSTALL_URL" | sh
fi

if [ -f "$HOME/.cargo/bin/uv" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

if [ -f "$HOME/.local/bin/uv" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

mkdir -p "$UV_CONFIG_DIR"

if [ -f "$UV_CONFIG_FILE" ]; then
    if grep -q "\[\[index\]\]" "$UV_CONFIG_FILE"; then
        sed -i '/\[\[index\]\]/,/^\[/ { /^url =/d; }' "$UV_CONFIG_FILE"
        sed -i '/\[\[index\]\]/a url = "'"$MIRROR_URL"'"' "$UV_CONFIG_FILE"
    else
        echo "" >> "$UV_CONFIG_FILE"
        echo "[[index]]" >> "$UV_CONFIG_FILE"
        echo "url = \"$MIRROR_URL\"" >> "$UV_CONFIG_FILE"
    fi
else
    cat > "$UV_CONFIG_FILE" <<EOF
[[index]]
url = "$MIRROR_URL"
EOF
fi

if uv python list | grep -q "Python $PYTHON_VERSION"; then
    read -p "Reinstall Python $PYTHON_VERSION? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        uv python install "$PYTHON_VERSION"
    fi
else
    uv python install "$PYTHON_VERSION"
fi

uv --version
uv python list
