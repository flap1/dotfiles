#!/bin/bash
# Clone the plugins tmux.conf names, at the revisions this tree was reviewed
# with. tpm is still the loader; this exists so a systemd-started server has
# resurrect on disk before the first attach.

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
    local dest=$1 url=$2 rev=$3
    if [ ! -d "$dest/.git" ]; then
        git clone --filter=blob:none "$url" "$dest"
    fi
    git -C "$dest" fetch --quiet --filter=blob:none origin
    git -C "$dest" checkout --quiet --detach "$rev"
}

clone "$PLUGINS_DIR/tpm" "https://github.com/tmux-plugins/tpm" \
    99469c4a9b1ccf77fade25842dc7bafbc8ce9946
clone "$PLUGINS_DIR/tmux-sensible" "https://github.com/tmux-plugins/tmux-sensible" \
    25cb91f42d020f675bb0a2ce3fbd3a5d96119efa
clone "$PLUGINS_DIR/tmux-resurrect" "https://github.com/flap1/tmux-resurrect" \
    392f2a72b7911df5d28564b4f7cf1c03db7dc868
clone "$PLUGINS_DIR/tmux-continuum" "https://github.com/tmux-plugins/tmux-continuum" \
    0698e8f4b17d6454c71bf5212895ec055c578da0
clone "$PLUGINS_DIR/tmux" "https://github.com/catppuccin/tmux" \
    8b0b9150f9d7dee2a4b70cdb50876ba7fd6d674a
