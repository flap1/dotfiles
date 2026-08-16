#!/bin/bash
#
# Software this machine needs before install.sh can do anything: the system
# packages with no user-local equivalent, plus mise itself. Agent CLIs
# (claude, codex, agent) come from mise / packages/cursor-agent.sh, not
# from install.sh.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/user-path.sh
. "$DOTFILES_DIR/lib/user-path.sh"

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

# True if $1 (dotted) >= $2. sort -V is coreutils; this script is apt/Linux.
# Read the last line so sort finishes; head would SIGPIPE under pipefail.
version_ge() {
    [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n1)" = "$1" ]
}

# Shared gitconfig uses zdiff3 (git 2.35). Presence is not enough: Ubuntu
# 22.04's 2.34 treats an unknown conflictstyle as fatal on clone.
ensure_git() {
    local need=2.35 have yn=y id

    if ! command -v git >/dev/null 2>&1; then
        ensure "git" git "git"
        command -v git >/dev/null 2>&1 || return 0
    fi

    have=$(git version | awk '{print $3}')
    if version_ge "$have" "$need"; then
        echo "git: $have"
        return 0
    fi

    echo "git $have is older than $need; gitconfig names merge.conflictstyle=zdiff3."
    [ "$ASSUME_YES" = 1 ] || read -rp "Install git from the Ubuntu git-core PPA? (y/n): " yn
    case $yn in
        [Yy]*) ;;
        *)
            echo "git $have cannot apply this repository's gitconfig." >&2
            exit 1
            ;;
    esac

    id=
    if [ -r /etc/os-release ]; then
        id=$(. /etc/os-release && printf '%s' "$ID")
    fi
    if [ "$id" != ubuntu ]; then
        echo "Need git $need+ (this machine has $have). ${id:-unknown} has no git-core PPA." >&2
        exit 1
    fi

    if [ "$need_apt" = 0 ]; then
        sudo apt-get update
        need_apt=1
    fi
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:git-core/ppa
    sudo apt-get update
    sudo apt-get install -y git
    hash -r
    have=$(git version | awk '{print $3}')
    if ! version_ge "$have" "$need"; then
        echo "git is still $have after the PPA; need $need+" >&2
        exit 1
    fi
    echo "git: $have"
}

ensure "zsh" zsh "zsh"
ensure_git
ensure "curl" curl "curl"
ensure "unzip" unzip "unzip"
ensure "clang" clang "clang libclang-dev"
ensure "fcitx5-mozc" fcitx5 "fcitx5 fcitx5-mozc"
ensure "wl-clipboard" wl-copy "wl-clipboard"

prepend_user_path

# mise: signed apt package via extrepo, not curl | sh.
if command -v mise >/dev/null 2>&1; then
    echo "mise: already installed, skipping."
else
    yn=y
    [ "$ASSUME_YES" = 1 ] || read -rp "Install mise? (y/n): " yn
    case $yn in
        [Yy]*)
            if [ "$need_apt" = 0 ]; then
                sudo apt-get update
                need_apt=1
            fi
            sudo apt-get install -y extrepo
            sudo extrepo enable mise
            sudo apt-get update
            sudo apt-get install -y mise
            ;;
        *) echo "Skipped mise." ;;
    esac
fi

if command -v mise >/dev/null 2>&1; then
    # This script runs before install.sh links ~/.config/mise. Without an
    # explicit file, `mise install` would use an empty or leftover catalog.
    mise -C "$DOTFILES_DIR/.config/mise" install
    if ! command -v pynvim-python >/dev/null 2>&1; then
        yn=y
        [ "$ASSUME_YES" = 1 ] || read -rp "Install pynvim (neovim python provider)? (y/n): " yn
        case $yn in
            [Yy]*) uv tool install pynvim ;;
            *) echo "Skipped pynvim." ;;
        esac
    fi
fi

# Docker is opt-in even with -y: a clone used as CI must not install a daemon.
if command -v docker >/dev/null 2>&1; then
    echo "docker: already installed, skipping."
elif [ "$ASSUME_YES" = 1 ]; then
    echo "Skipped Docker (pass without -y to be asked)."
else
    read -rp "Install Docker? (y/n): " yn
    if [[ $yn == [Yy]* ]]; then
        if [ "$need_apt" = 0 ]; then
            sudo apt-get update
            need_apt=1
        fi
        sudo apt-get install -y docker.io
        sudo usermod -aG docker "$USER"
        echo "Docker installed. Re-login to use without sudo."
    else
        echo "Skipped Docker."
    fi
fi

if [ "$ASSUME_YES" = 1 ]; then
    bash "$(dirname "$0")/tmux.sh" -y
    bash "$(dirname "$0")/cursor-agent.sh" -y
else
    bash "$(dirname "$0")/tmux.sh"
    bash "$(dirname "$0")/cursor-agent.sh"
fi

yn=y
[ "$ASSUME_YES" = 1 ] || read -rp "Install Nerd Fonts? (y/n): " yn
[[ $yn == [Yy]* ]] && bash "$(dirname "$0")/fonts.sh" || echo "Skipped fonts."
