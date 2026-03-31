#!/bin/bash

echo "Start installing zsh and oh-my-zsh..."

if ! command -v zsh >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y zsh
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if command -v curl >/dev/null 2>&1; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    elif command -v wget >/dev/null 2>&1; then
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        sudo apt install -y curl
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    PLUGINS_DIR="$ZSH_CUSTOM/plugins"
    mkdir -p "$PLUGINS_DIR"

    if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions" 2>/dev/null || true
    fi

    if [ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGINS_DIR/zsh-syntax-highlighting" 2>/dev/null || true
    fi

    ZSHRC_FILE="$HOME/.zshrc"
    if [ -f "$ZSHRC_FILE" ]; then
        if ! grep -q "^plugins=" "$ZSHRC_FILE"; then
            if grep -q "^ZSH_THEME=" "$ZSHRC_FILE"; then
                sed -i '/^ZSH_THEME=/a plugins=(extract git sudo z zsh-autosuggestions zsh-syntax-highlighting)' "$ZSHRC_FILE"
            else
                sed -i '1i plugins=(extract git sudo z zsh-autosuggestions zsh-syntax-highlighting)' "$ZSHRC_FILE"
            fi
        else
            sed -i 's/^plugins=.*/plugins=(extract git sudo z zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC_FILE"
        fi

        if ! grep -q "source .*zsh-autosuggestions" "$ZSHRC_FILE"; then
            echo "" >> "$ZSHRC_FILE"
            echo "source $PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$ZSHRC_FILE"
        fi

        sed -i '/source .*zsh-syntax-highlighting/d' "$ZSHRC_FILE"
        echo "" >> "$ZSHRC_FILE"
        echo "source $PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$ZSHRC_FILE"
    fi
fi

ZSH_PATH=$(command -v zsh)
if [ -n "$ZSH_PATH" ] && [ "$(basename "$SHELL" 2>/dev/null)" != "zsh" ]; then
    if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    chsh -s "$ZSH_PATH" || true
fi

echo "zsh install finished"
