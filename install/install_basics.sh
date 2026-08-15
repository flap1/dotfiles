#!/bin/bash

set -e

# Install if not found, with y/n prompt.
# Already installed tools are skipped silently.
ask_and_install() {
    local name=$1
    local cmd=$2
    local install_cmd=$3
    if command -v "$cmd" > /dev/null 2>&1; then
        echo "$name: already installed, skipping."
        return
    fi
    read -rp "Install $name? (y/n): " yn
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
ask_and_install "zsh"   zsh   "sudo apt install -y zsh"
ask_and_install "git"   git   "sudo apt install -y git"
ask_and_install "curl"  curl  "sudo apt install -y curl"
ask_and_install "unzip" unzip "sudo apt install -y unzip"
ask_and_install "gawk"  gawk  "sudo apt install -y gawk"  # for translate-shell
ask_and_install "clang" clang "sudo apt install -y clang libclang-dev"  # required by cargo crates using bindgen (e.g. ouch)

# Japanese input (sudo required, no alternative)
ask_and_install "fcitx5-mozc" fcitx5 "sudo apt install -y fcitx5 fcitx5-mozc"

# Wayland clipboard (sudo required)
ask_and_install "wl-clipboard" wl-copy "sudo apt install -y wl-clipboard"

# -------------------------------------------------------------------------
# Rust toolchain (user-local: ~/.cargo)
# -------------------------------------------------------------------------
ask_and_install "rustup/cargo" cargo "curl https://sh.rustup.rs -sSf | sh -s -- -y && source $HOME/.cargo/env"

# -------------------------------------------------------------------------
# Version managers (user-local)
# -------------------------------------------------------------------------
ask_and_install "mise" mise "curl https://mise.run | sh"

# Everything mise declares, in one pass. The list lives in
# .config/mise/config.toml with a lockfile beside it.
mise install
ask_and_install "pynvim (neovim python provider)" pynvim-python "uv tool install pynvim"

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
bash "$(dirname "$0")/install_tmux.sh"

# -------------------------------------------------------------------------
# Fonts (user-local: ~/.local/share/fonts)
# -------------------------------------------------------------------------
read -rp "Install Nerd Fonts? (y/n): " yn
[[ $yn == [Yy]* ]] && bash "$(dirname "$0")/install_fonts.sh" || echo "Skipped fonts."
