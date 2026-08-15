#!/bin/bash
# Clone the plugins tmux.conf names. tpm is still the loader; this exists
# so a systemd-started server has resurrect on disk before the first attach.

set -euo pipefail

ASSUME_YES=0
while [ $# -gt 0 ]; do
    case $1 in
        -y | --yes) ASSUME_YES=1 ;;
        -h | --help)
            echo "usage: tmux.sh [-y|--yes]"
            exit 0
            ;;
        *)
            echo "unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

if [ "$ASSUME_YES" != 1 ]; then
    read -rp "Install tmux plugins (tpm, resurrect, continuum, catppuccin)? (y/n): " yn
    case $yn in
        [Yy]*) ;;
        *)
            echo "Skipped tmux plugins."
            exit 0
            ;;
    esac
fi

PLUGINS_DIR="$HOME/.tmux/plugins"
mkdir -p "$PLUGINS_DIR"

clone() {
    local dest=$1 url=$2
    if [ -d "$dest/.git" ]; then
        echo "$(basename "$dest"): present"
        return
    fi
    git clone --depth=1 "$url" "$dest"
}

clone "$PLUGINS_DIR/tpm" "https://github.com/tmux-plugins/tpm"
clone "$PLUGINS_DIR/tmux-sensible" "https://github.com/tmux-plugins/tmux-sensible"
clone "$PLUGINS_DIR/tmux-resurrect" "https://github.com/flap1/tmux-resurrect"
clone "$PLUGINS_DIR/tmux-continuum" "https://github.com/tmux-plugins/tmux-continuum"
clone "$PLUGINS_DIR/tmux" "https://github.com/catppuccin/tmux"
