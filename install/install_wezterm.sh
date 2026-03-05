#!/bin/bash

set -e

if command -v wezterm > /dev/null 2>&1; then
    echo "wezterm: already installed, skipping."
    exit 0
fi

read -rp "Install WezTerm? (y/n): " yn
case $yn in
    [Yy]*) ;;
    *) echo "Skipped WezTerm."; exit 0 ;;
esac

curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
sudo apt update && sudo apt install -y wezterm

echo "WezTerm installed."
