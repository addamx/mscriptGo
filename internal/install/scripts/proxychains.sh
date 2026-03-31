#!/bin/bash

set -e

echo "Start installing proxychains-ng..."

sudo apt update
sudo apt install -y proxychains-ng

if [ -f "/etc/proxychains4.conf" ]; then
    PROXYCHAINS_CONF="/etc/proxychains4.conf"
elif [ -f "/etc/proxychains.conf" ]; then
    PROXYCHAINS_CONF="/etc/proxychains.conf"
else
    echo "proxychains config file not found"
    exit 1
fi

BACKUP_CONF="${PROXYCHAINS_CONF}.backup.$(date +%Y%m%d_%H%M%S)"
sudo cp "$PROXYCHAINS_CONF" "$BACKUP_CONF"

if [ -n "$GLOBAL_HTTP_PROXY" ]; then
    PROXY_URL="${GLOBAL_HTTP_PROXY#http://}"
    PROXY_URL="${PROXY_URL#https://}"
    PROXY_HOST="${PROXY_URL%%:*}"
    PROXY_PORT="${PROXY_URL##*:}"
    PROXY_LINE="http ${PROXY_HOST} ${PROXY_PORT}"

    if ! sudo grep -q "^http[[:space:]]\+${PROXY_HOST}[[:space:]]\+${PROXY_PORT}" "$PROXYCHAINS_CONF"; then
        sudo sed -i '/^\[ProxyList\]/,/^\[/ {
            /^\[ProxyList\]/b
            /^\[/b
            /^[[:space:]]*$/b
            /^[[:space:]]*#/b
            s/^/#/
        }' "$PROXYCHAINS_CONF"

        TMP_FILE=$(mktemp)
        sudo cp "$PROXYCHAINS_CONF" "$TMP_FILE"
        sudo awk -v proxy="$PROXY_LINE" '
            /^\[ProxyList\]/ {
                print
                print proxy
                next
            }
            { print }
        ' "$TMP_FILE" | sudo tee "$PROXYCHAINS_CONF" > /dev/null
        rm -f "$TMP_FILE"
    fi
fi

echo "Backup: $BACKUP_CONF"
