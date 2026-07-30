#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create symbolic link with timestamp and move existing file or directory if necessary.
# Returns 0 on success, 1 if skipped.
create_symlink() {
    local src
    src=$(realpath "$1")
    local dst=$2
    local timestamp
    timestamp=$(date "+%Y%m%d%H%M%S")

    if [ -e "$dst" ] || [ -h "$dst" ]; then
        if [ -L "$dst" ]; then
            read -rp "Remove existing symlink $dst? (y/n): " yn
            case $yn in
                [Yy]*) unlink "$dst" || sudo unlink "$dst" ;;
                *) echo "Skipped."; return 1 ;;
            esac
        else
            read -rp "Move $dst to ${dst}.${timestamp}? (y/n): " yn
            case $yn in
                [Yy]*) mv "$dst" "${dst}.${timestamp}" || sudo mv "$dst" "${dst}.${timestamp}" ;;
                *) echo "Skipped."; return 1 ;;
            esac
        fi
    fi

    local parent_dir
    parent_dir=$(dirname "$dst")
    if [ ! -d "$parent_dir" ]; then
        read -rp "Parent directory $parent_dir does not exist. Create it? (y/n): " yn
        case $yn in
            [Yy]*) mkdir -p "$parent_dir" || sudo mkdir -p "$parent_dir" ;;
            *) echo "Skipped."; return 1 ;;
        esac
    fi

    if ! ln -s "$src" "$dst"; then
        echo "Retrying with sudo..."
        sudo ln -sf "$src" "$dst"
    fi
    echo "  -> $dst"
}

# Ask whether to install a category, then run symlinks for it.
install_category() {
    local category=$1
    shift
    read -rp "Install [$category]? (y/n): " yn
    case $yn in
        [Yy]*) ;;
        *) echo "Skipped [$category]."; return ;;
    esac
    echo "Installing [$category]..."
    while [ $# -gt 0 ]; do
        local src=$1 dst=$2
        shift 2
        create_symlink "$DOTFILES_DIR/$src" "$dst" || true
    done
}

# -------------------------------------------------------------------------
# Core: Zsh + Starship configuration
# -------------------------------------------------------------------------
install_category "Core: Zsh + Starship" \
    ".zshenv"                "$HOME/.zshenv" \
    ".zprofile"              "$HOME/.zprofile" \
    ".config/zsh"            "$HOME/.config/zsh" \
    ".config/starship.toml"  "$HOME/.config/starship.toml"

# -------------------------------------------------------------------------
# Editor: Neovim
# -------------------------------------------------------------------------
install_category "Editor: Neovim" \
    ".config/nvim" "$HOME/.config/nvim"

# No terminal emulator config. The terminal is Windows Terminal over ssh, and
# it is configured on the Windows side; tmux owns everything on this end.

# -------------------------------------------------------------------------
# Development tools
# -------------------------------------------------------------------------
install_category "Tools: bin + git template" \
    "bin"            "$HOME/bin" \
    ".git_template"  "$HOME/.git_template"

install_category "Tools: Git config" \
    ".config/git/.gitconfig" "$HOME/.gitconfig"

# The tmux pin here is load-bearing rather than a preference. tmux.conf targets
# 3.7 (escape-time, and the comments reason about 3.7 defaults), and the
# systemd --user unit that restores sessions after a reboot runs
# ~/.local/bin/tmux by absolute path. Point that at the mise shim once:
#     ln -sfn ~/.local/share/mise/shims/tmux ~/.local/bin/tmux
# Distro tmux must NOT be installed alongside: an older client silently kills a
# newer server, which is how the whole restore path broke once.
install_category "Tools: mise" \
    ".config/mise/config.toml" "$HOME/.config/mise/config.toml"

install_category "Tools: tmux" \
    ".config/tmux/.tmux.conf" "$HOME/.tmux.conf" \
    ".config/tmux/status.sh"  "$HOME/.tmux-status.sh"

# -------------------------------------------------------------------------
# Document creation
# -------------------------------------------------------------------------
# LaTeX is not written here any more; Typst replaced it. remark stays for the
# markdown language server.
install_category "Docs: remark" \
    ".remarkrc.yml"  "$HOME/.remarkrc.yml"

# -------------------------------------------------------------------------
# Application settings
# -------------------------------------------------------------------------
install_category "App: GNOME + pictures" \
    ".config/gnome"    "$HOME/.config/gnome" \
    ".config/pictures" "$HOME/.config/pictures"

# -------------------------------------------------------------------------
# Server / ops tools
# -------------------------------------------------------------------------
install_category "Server: Ansible" \
    ".config/ansible/.ansible.cfg" "$HOME/.ansible.cfg"

# -------------------------------------------------------------------------
# AI tools
# -------------------------------------------------------------------------
install_category "AI: Claude Code (hooks + skills + settings + instructions)" \
    ".claude/hooks"        "$HOME/.claude/hooks" \
    ".claude/skills"       "$HOME/.claude/skills" \
    ".claude/settings.json" "$HOME/.claude/settings.json" \
    ".claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh" \
    ".claude/CLAUDE.md"    "$HOME/.claude/CLAUDE.md" \
    ".claude/RTK.md"       "$HOME/.claude/RTK.md"

# -------------------------------------------------------------------------
# Directories
# -------------------------------------------------------------------------
[ -d "$HOME/.git-worktrees" ] || mkdir "$HOME/.git-worktrees"

# -------------------------------------------------------------------------
# Change default shell to zsh
# -------------------------------------------------------------------------
if [ "$(basename "$SHELL")" != "zsh" ]; then
    read -rp "Change default shell to zsh? (y/n): " yn
    case $yn in
        [Yy]*)
            sudo chsh -s "$(command -v zsh)" "$USER"
            echo "Default shell changed to zsh. Re-login to apply." ;;
        *)
            echo "Skipped shell change." ;;
    esac
else
    echo "Default shell is already zsh."
fi

# -------------------------------------------------------------------------
# Starship prompt
# -------------------------------------------------------------------------
if ! command -v starship > /dev/null 2>&1; then
    read -rp "Starship not found. Install it now? (y/n): " yn
    case $yn in
        [Yy]*)
            curl -sS https://starship.rs/install.sh | sh ;;
        *)
            echo "Skipped. Install starship later: https://starship.rs" ;;
    esac
fi
