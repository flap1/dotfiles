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

  -y, --yes           every category
      --only ID       one category id (zsh, nvim, bin, git, mise, tmux,
                      tmux-runtime, bind-localhost, claude, cursor, claude-settings,
                      cursor-settings, codex, codex-settings)
      --dry-run       print ids, change nothing
  -h, --help

Bare machine: ./bootstrap.sh
EOF
}

while [ $# -gt 0 ]; do
    case $1 in
        -y | --yes) ASSUME_YES=1 ;;
        --only)
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

missing=""
for c in git node jq; do
    command -v "$c" >/dev/null || missing="$missing $c"
done
if [ -n "$missing" ]; then
    echo "install.sh needs:$missing" >&2
    echo "Run ./bootstrap.sh first." >&2
    exit 1
fi

ask() {
    local id=$1
    if [ -n "$ONLY" ] && [ "$id" != "$ONLY" ]; then
        return 1
    fi
    if [ "$DRY_RUN" = 1 ]; then
        echo "would install [$id]"
        return 1
    fi
    if [ "$ASSUME_YES" = 1 ]; then
        echo "Installing [$id]..."
        return 0
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
if [ "$DRY_RUN" != 1 ] && [ "$ASSUME_YES" = 1 ] && [ -z "$ONLY" ]; then
    : >"$MANIFEST"
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
        if [ "$ASSUME_YES" = 1 ]; then
            if [ -L "$dst" ]; then
                unlink "$dst"
            else
                mv "$dst" "$dst.$(date +%Y%m%d%H%M%S)"
            fi
        else
            local yn
            if [ -L "$dst" ]; then
                read -rp "Remove existing symlink $dst? (y/n): " yn
                case $yn in
                    [Yy]*) unlink "$dst" ;;
                    *)
                        echo "Skipped."
                        return 1
                        ;;
                esac
            else
                read -rp "Move $dst aside? (y/n): " yn
                case $yn in
                    [Yy]*) mv "$dst" "$dst.$(date +%Y%m%d%H%M%S)" ;;
                    *)
                        echo "Skipped."
                        return 1
                        ;;
                esac
            fi
        fi
    fi

    parent_dir=$(dirname "$dst")
    if [ ! -d "$parent_dir" ]; then
        if [ "$ASSUME_YES" = 1 ]; then
            mkdir -p "$parent_dir"
        else
            local yn
            read -rp "Create $parent_dir? (y/n): " yn
            case $yn in
                [Yy]*) mkdir -p "$parent_dir" ;;
                *)
                    echo "Skipped."
                    return 1
                    ;;
            esac
        fi
    fi

    ln -s "$src" "$dst"
    echo "$dst" >>"$MANIFEST"
    echo "  -> $dst"
}

link_category() {
    local id=$1
    shift
    ask "$id" || return 0
    while [ $# -gt 0 ]; do
        local src=$1 dst=$2
        shift 2
        if [ "$ASSUME_YES" = 1 ]; then
            create_symlink "$DOTFILES_DIR/$src" "$dst"
        else
            create_symlink "$DOTFILES_DIR/$src" "$dst" || true
        fi
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
link_category mise \
    ".config/mise" "$HOME/.config/mise"

link_category tmux \
    ".config/tmux/.tmux.conf" "$HOME/.tmux.conf" \
    ".config/tmux/status.sh" "$HOME/.tmux-status.sh"

write_tmux_service() {
    ask tmux-runtime || return 0

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

build_bind_localhost() {
    command -v gcc >/dev/null || {
        echo "Skipped [bind-localhost]: no gcc."
        return
    }
    ask bind-localhost || return 0
    mkdir -p "$HOME/.local/lib"
    gcc -shared -fPIC -O2 -Wall -Wextra \
        -o "$HOME/.local/lib/bind-localhost.so" "$DOTFILES_DIR/lib/bind-localhost.c" -ldl
    echo "  -> $HOME/.local/lib/bind-localhost.so"
    "$DOTFILES_DIR/lib/test-bind-localhost.sh"
}
build_bind_localhost

link_category claude \
    ".claude/hooks" "$HOME/.claude/hooks" \
    ".claude/skills" "$HOME/.claude/skills" \
    ".claude/statusline.mjs" "$HOME/.claude/statusline.mjs" \
    ".claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md" \
    ".claude/RTK.md" "$HOME/.claude/RTK.md"

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
