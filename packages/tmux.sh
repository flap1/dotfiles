#!/bin/bash

set -e

TPM_DIR="$HOME/.tmux/plugins/tpm"
PLUGINS_DIR="$HOME/.tmux/plugins"

clone_or_update() {
    local name=$1
    local url=$2
    local dest=$3
    if [ -d "$dest/.git" ]; then
        echo "$name: already installed, skipping."
    else
        echo "Installing $name..."
        git clone --depth=1 "$url" "$dest"
    fi
}

read -rp "Install tmux plugins (TPM + catppuccin + cpu + sensible + resurrect + continuum)? (y/n): " yn
case $yn in
    [Yy]*) ;;
    *) echo "Skipped tmux plugins."; exit 0 ;;
esac

mkdir -p "$PLUGINS_DIR"

clone_or_update "tpm"            "https://github.com/tmux-plugins/tpm"           "$TPM_DIR"
clone_or_update "tmux-sensible"  "https://github.com/tmux-plugins/tmux-sensible"  "$PLUGINS_DIR/tmux-sensible"
clone_or_update "tmux-resurrect" "https://github.com/tmux-plugins/tmux-resurrect" "$PLUGINS_DIR/tmux-resurrect"
clone_or_update "tmux-continuum" "https://github.com/tmux-plugins/tmux-continuum" "$PLUGINS_DIR/tmux-continuum"
clone_or_update "tmux-cpu"       "https://github.com/tmux-plugins/tmux-cpu"       "$PLUGINS_DIR/tmux-cpu"
clone_or_update "catppuccin/tmux" "https://github.com/catppuccin/tmux"            "$PLUGINS_DIR/tmux"

echo "tmux plugins installed to $PLUGINS_DIR"
echo "Start tmux and run: tmux source ~/.tmux.conf"
