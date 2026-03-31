#!/bin/bash

set -e

MINIFORGE_VERSION="Miniforge3-Linux-x86_64"
MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/${MINIFORGE_VERSION}.sh"
INSTALL_DIR="$HOME/miniforge3"

echo "Start installing Miniforge..."

if [ -d "$INSTALL_DIR" ]; then
    read -p "Reinstall Miniforge at $INSTALL_DIR? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skip install"
        exit 0
    fi
    rm -rf "$INSTALL_DIR"
fi

TEMP_SCRIPT="/tmp/${MINIFORGE_VERSION}.sh"
curl -L -o "$TEMP_SCRIPT" "$MINIFORGE_URL"
bash "$TEMP_SCRIPT" -b -p "$INSTALL_DIR"
rm -f "$TEMP_SCRIPT"

source "$INSTALL_DIR/bin/activate"

conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/pro
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge
conda config --set show_channel_urls yes

mkdir -p "$HOME/.pip"
cat > "$HOME/.pip/pip.conf" <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF

echo "Miniforge installed at $INSTALL_DIR"
