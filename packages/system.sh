#!/bin/bash
#
# Software this machine needs before install.sh can do anything: the system
# packages with no user-local equivalent, plus mise itself.

set -e

ASSUME_YES=0
while [ $# -gt 0 ]; do
    case $1 in
        -y|--yes) ASSUME_YES=1 ;;
        -h|--help) echo "usage: system.sh [-y|--yes]"; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

ensure() {
    local name=$1 cmd=$2 install_cmd=$3 yn=y
    if command -v "$cmd" > /dev/null 2>&1; then
        echo "$name: already installed, skipping."
        return
    fi
    [ "$ASSUME_YES" = 1 ] || read -rp "Install $name? (y/n): " yn
    case $yn in
        [Yy]*) eval "$install_cmd" ;;
        *) echo "Skipped $name." ;;
    esac
}

# -------------------------------------------------------------------------
# System packages (sudo required - unavoidable)
# -------------------------------------------------------------------------
# zsh, git, curl, unzip, gawk are system-level and have no user-local alternative
sudo apt update
ensure "zsh"   zsh   "sudo apt install -y zsh"
ensure "git"   git   "sudo apt install -y git"
ensure "curl"  curl  "sudo apt install -y curl"
ensure "unzip" unzip "sudo apt install -y unzip"
ensure "gawk"  gawk  "sudo apt install -y gawk"  # for translate-shell
ensure "clang" clang "sudo apt install -y clang libclang-dev"  # bindgen, for the crates mise still builds from source

# Japanese input (sudo required, no alternative)
ensure "fcitx5-mozc" fcitx5 "sudo apt install -y fcitx5 fcitx5-mozc"

# Wayland clipboard (sudo required)
ensure "wl-clipboard" wl-copy "sudo apt install -y wl-clipboard"

# -------------------------------------------------------------------------
# Rust toolchain (user-local: ~/.cargo)
# -------------------------------------------------------------------------
ensure "rustup/cargo" cargo "curl https://sh.rustup.rs -sSf | sh -s -- -y && source $HOME/.cargo/env"

# -------------------------------------------------------------------------
# Version managers (user-local)
# -------------------------------------------------------------------------
ensure "mise" mise "curl https://mise.run | sh"

# Everything mise declares, in one pass. The list lives in
# .config/mise/config.toml with a lockfile beside it.
mise install
ensure "pynvim (neovim python provider)" pynvim-python "uv tool install pynvim"

# -------------------------------------------------------------------------
# Docker (sudo required for daemon install + usermod)
# -------------------------------------------------------------------------
if command -v docker > /dev/null 2>&1; then
    echo "docker: already installed, skipping."
else
    read -rp "Install Docker? (y/n): " yn
    if [[ $yn == [Yy]* ]]; then
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker "$USER"
        echo "Docker installed. Re-login to use without sudo."
    else
        echo "Skipped Docker."
    fi
fi

# docker compose plugin (user-local: ~/.docker/cli-plugins, no sudo)
if docker compose version > /dev/null 2>&1; then
    echo "docker compose: already installed, skipping."
else
    read -rp "Install docker compose plugin? (y/n): " yn
    if [[ $yn == [Yy]* ]]; then
        mkdir -p "$HOME/.docker/cli-plugins"
        curl -sL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
            -o "$HOME/.docker/cli-plugins/docker-compose"
        chmod +x "$HOME/.docker/cli-plugins/docker-compose"
        echo "docker compose installed."
    else
        echo "Skipped docker compose."
    fi
fi

# -------------------------------------------------------------------------
# tmux plugins (TPM + catppuccin + cpu + sensible + resurrect + continuum)
# -------------------------------------------------------------------------
bash "$(dirname "$0")/tmux.sh"

# -------------------------------------------------------------------------
# Fonts (user-local: ~/.local/share/fonts)
# -------------------------------------------------------------------------
yn=y
[ "$ASSUME_YES" = 1 ] || read -rp "Install Nerd Fonts? (y/n): " yn
[[ $yn == [Yy]* ]] && bash "$(dirname "$0")/fonts.sh" || echo "Skipped fonts."
