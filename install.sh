#!/bin/bash
# Symlinks and composed config. Software comes from packages/ and mise.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/manifest"

ASSUME_YES=0
DRY_RUN=0
ONLY=""

usage() {
    cat <<'EOF'
usage: install.sh [options]

  -y, --yes           categories already on this machine; all of them
                      when the machine has none yet
      --only ID       one category (adds it under --yes)
      --dry-run       print ids, change nothing
  -h, --help

A new machine: ./bootstrap.sh, or ./install.sh -y after software exists.
dotfiles update reruns --yes and only refreshes what this machine already
took. To add a category later: ./install.sh --only yazi --yes.
A category is all of its paths or none of them.
EOF
}

while [ $# -gt 0 ]; do
    case $1 in
        -y | --yes) ASSUME_YES=1 ;;
        --only)
            if [ $# -lt 2 ] || [ -z "$2" ] || [ "$2" != "${2#-}" ]; then
                echo "install.sh: --only needs a category id" >&2
                usage >&2
                exit 1
            fi
            ONLY=$2
            shift
            ;;
        --dry-run) DRY_RUN=1 ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            echo "unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

if ! command -v git >/dev/null; then
    echo "install.sh needs git" >&2
    echo "Run ./bootstrap.sh first." >&2
    exit 1
fi

ask() {
    local id=$1
    shift
    if [ -n "$ONLY" ] && [ "$id" != "$ONLY" ]; then
        return 1
    fi
    if [ "$DRY_RUN" = 1 ]; then
        echo "would install [$id]"
        return 1
    fi
    if [ "$ASSUME_YES" = 1 ]; then
        if [ -n "$ONLY" ] || [ "$FULL_YES" = 1 ]; then
            echo "Installing [$id]..."
            return 0
        fi
        local d
        for d in "$@"; do
            if grep -qxF "$d" "$MANIFEST" 2>/dev/null; then
                echo "Installing [$id]..."
                return 0
            fi
        done
        echo "Skipping [$id] (not on this machine; ./install.sh --only $id --yes)"
        return 1
    fi
    local yn
    read -rp "Install [$id]? (y/n): " yn
    case $yn in
        [Yy]*)
            echo "Installing [$id]..."
            return 0
            ;;
        *)
            echo "Skipped [$id]."
            return 1
            ;;
    esac
}

mkdir -p "$(dirname "$MANIFEST")"
FULL_YES=0
if [ "$ASSUME_YES" = 1 ] && [ -z "$ONLY" ] && [ ! -s "$MANIFEST" ]; then
    FULL_YES=1
fi

create_symlink() {
    local src dst parent_dir
    src=$(realpath "$1")
    dst=$2

    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "$dst" >>"$MANIFEST"
        return 0
    fi

    if [ -e "$dst" ] || [ -h "$dst" ]; then
        if [ -L "$dst" ]; then
            unlink "$dst"
        else
            mv "$dst" "$dst.$(date +%Y%m%d%H%M%S)"
        fi
    fi

    parent_dir=$(dirname "$dst")
    mkdir -p "$parent_dir"

    ln -s "$src" "$dst"
    echo "$dst" >>"$MANIFEST"
    echo "  -> $dst"
}

link_category() {
    local id=$1
    shift
    local -a pairs=("$@")
    local dests=()
    while [ $# -gt 0 ]; do
        dests+=("$2")
        shift 2
    done
    ask "$id" "${dests[@]}" || return 0
    set -- "${pairs[@]}"
    while [ $# -gt 0 ]; do
        create_symlink "$DOTFILES_DIR/$1" "$2"
        shift 2
    done
}

link_category zsh \
    ".zshenv" "$HOME/.zshenv" \
    ".config/zsh" "$HOME/.config/zsh" \
    ".config/sheldon" "$HOME/.config/sheldon" \
    ".config/starship.toml" "$HOME/.config/starship.toml"

link_category nvim \
    ".config/nvim" "$HOME/.config/nvim"

link_category bin \
    "bin" "$HOME/bin" \
    ".git_template" "$HOME/.git_template"

link_category git \
    ".config/git/.gitconfig" "$HOME/.gitconfig"

# tmux.conf targets 3.7; an older distro client kills a newer server.
# .config/powershell is Windows-only (install.ps1 writes the profile hook).
link_category mise \
    ".config/mise" "$HOME/.config/mise"

link_category tmux \
    ".config/tmux/.tmux.conf" "$HOME/.tmux.conf" \
    ".config/tmux/status.sh" "$HOME/.tmux-status.sh"

link_category yazi \
    ".config/yazi" "$HOME/.config/yazi"

link_category lazygit \
    ".config/lazygit" "$HOME/.config/lazygit"

write_tmux_service() {
    ask tmux-runtime "$HOME/.tmux.conf" "$HOME/.tmux-status.sh" || return 0

    if ! command -v mise >/dev/null; then
        echo "  (mise not installed; run ./bootstrap.sh)"
        return 0
    fi

    # The symlink resolves into this repo; an untrusted config makes every shim fail.
    mise trust "$HOME/.config/mise/config.toml"

    mkdir -p "$HOME/.local/bin"
    ln -sfn "$HOME/.local/share/mise/shims/tmux" "$HOME/.local/bin/tmux"
    echo "  -> $HOME/.local/bin/tmux"

    # Own the unit: continuum will not overwrite an existing one, and its
    # generated PATH has no ~/.local/bin (plugins then call a missing tmux).
    local unit="$HOME/.config/systemd/user/tmux.service"
    mkdir -p "$(dirname "$unit")"
    cat >"$unit" <<EOF
[Unit]
Description=tmux default session (detached)
Documentation=man:tmux(1)

[Service]
Type=forking
Environment=PATH=$HOME/.local/share/mise/shims:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=$HOME/.local/bin/tmux new-session -d
ExecStop=$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh
ExecStop=$HOME/.local/bin/tmux kill-server
KillMode=control-group
RestartSec=2

[Install]
WantedBy=default.target
EOF
    echo "  -> $unit"
    if systemctl --user show-environment >/dev/null 2>&1; then
        systemctl --user daemon-reload
        systemctl --user enable tmux.service
    else
        echo "  (no user systemd bus; unit written but not enabled)"
    fi
}
write_tmux_service

link_category claude \
    ".claude/hooks" "$HOME/.claude/hooks" \
    ".claude/skills" "$HOME/.claude/skills" \
    ".claude/statusline.mjs" "$HOME/.claude/statusline.mjs"

link_category cursor \
    ".cursor/statusline.mjs" "$HOME/.cursor/statusline.mjs"

# shellcheck source=lib/compose.sh
. "$DOTFILES_DIR/lib/compose.sh"
compose_claude_settings
compose_cursor_settings
link_category codex \
    ".codex/agents" "${CODEX_HOME:-$HOME/.codex}/agents"
compose_codex_settings

if [ "$DRY_RUN" = 1 ]; then
    echo "would install [lefthook]"
elif command -v lefthook >/dev/null; then
    (cd "$DOTFILES_DIR" && lefthook install)
else
    echo "Skipped [lefthook]: not installed."
fi

[ -d "$HOME/.git-worktrees" ] || mkdir "$HOME/.git-worktrees"

if [ "$DRY_RUN" = 0 ] && [ "$(basename "${SHELL:-}")" != "zsh" ]; then
    echo "Default shell is not zsh. Run: chsh -s $(command -v zsh)"
fi

if [ "$DRY_RUN" != 1 ] && [ -f "$MANIFEST" ]; then
    tmp=$(mktemp)
    awk 'NF && !seen[$0]++' "$MANIFEST" >"$tmp"
    mv "$tmp" "$MANIFEST"
fi
