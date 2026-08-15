#!/bin/bash
#
# Software this machine needs before install.sh can do anything: the system
# packages with no user-local equivalent, plus mise itself.

set -euo pipefail

ASSUME_YES=0
while [ $# -gt 0 ]; do
    case $1 in
        -y | --yes) ASSUME_YES=1 ;;
        -h | --help)
            echo "usage: system.sh [-y|--yes]"
            exit 0
            ;;
        *)
            echo "unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

need_apt=0
ensure() {
    local name=$1 cmd=$2 packages=$3 yn=y
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "$name: already installed, skipping."
        return
    fi
    [ "$ASSUME_YES" = 1 ] || read -rp "Install $name? (y/n): " yn
    case $yn in
        [Yy]*)
            if [ "$need_apt" = 0 ]; then
                sudo apt-get update
                need_apt=1
            fi
            # packages is a space-separated apt name list, not one package.
            # shellcheck disable=SC2086
            sudo apt-get install -y $packages
            ;;
        *) echo "Skipped $name." ;;
    esac
}

ensure "zsh" zsh "zsh"
ensure "git" git "git"
ensure "curl" curl "curl"
ensure "unzip" unzip "unzip"
ensure "clang" clang "clang libclang-dev"
ensure "fcitx5-mozc" fcitx5 "fcitx5 fcitx5-mozc"
ensure "wl-clipboard" wl-copy "wl-clipboard"

# mise's official installer. rust is a mise tool, not a second toolchain.
if command -v mise >/dev/null 2>&1; then
    echo "mise: already installed, skipping."
else
    yn=y
    [ "$ASSUME_YES" = 1 ] || read -rp "Install mise? (y/n): " yn
    case $yn in
        [Yy]*) curl https://mise.run | sh ;;
        *) echo "Skipped mise." ;;
    esac
fi

export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
if command -v mise >/dev/null 2>&1; then
    # This script runs before install.sh links ~/.config/mise. Without an
    # explicit file, `mise install` would use an empty or leftover catalog.
    mise -C "$(dirname "$0")/../.config/mise" install
    if ! command -v pynvim-python >/dev/null 2>&1; then
        yn=y
        [ "$ASSUME_YES" = 1 ] || read -rp "Install pynvim (neovim python provider)? (y/n): " yn
        case $yn in
            [Yy]*) uv tool install pynvim ;;
            *) echo "Skipped pynvim." ;;
        esac
    fi
fi

# Docker is opt-in even with -y: CI must not curl get.docker.com.
if command -v docker >/dev/null 2>&1; then
    echo "docker: already installed, skipping."
elif [ "$ASSUME_YES" = 1 ]; then
    echo "Skipped Docker (pass without -y to be asked)."
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

if [ "$ASSUME_YES" = 1 ]; then
    bash "$(dirname "$0")/tmux.sh" -y
else
    bash "$(dirname "$0")/tmux.sh"
fi

yn=y
[ "$ASSUME_YES" = 1 ] || read -rp "Install Nerd Fonts? (y/n): " yn
[[ $yn == [Yy]* ]] && bash "$(dirname "$0")/fonts.sh" || echo "Skipped fonts."
