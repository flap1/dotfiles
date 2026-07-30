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

# The tmux pin in here is load-bearing rather than a preference: tmux.conf targets
# 3.7, and a distro tmux must not be installed alongside it, because an older
# client kills a newer server outright instead of failing -- that is how session
# restore broke once, silently.
install_category "Tools: mise" \
    ".config/mise/config.toml" "$HOME/.config/mise/config.toml"

install_category "Tools: tmux" \
    ".config/tmux/.tmux.conf" "$HOME/.tmux.conf" \
    ".config/tmux/status.sh"  "$HOME/.tmux-status.sh"

# Three things tmux session restore needs that are not symlinks. Idempotent.
install_tmux_runtime() {
    read -rp "Install [Tools: tmux runtime (mise trust + shim + systemd unit)]? (y/n): " yn
    case $yn in
        [Yy]*) ;;
        *) echo "Skipped [Tools: tmux runtime]."; return ;;
    esac

    # mise trusts ~/.config/mise/config.toml implicitly, but the symlink above
    # resolves into this repo, and an untrusted config does not degrade: every
    # shim fails, tmux included, which takes the terminal with it.
    mise trust "$DOTFILES_DIR/.config/mise/config.toml"
    mise install

    # The systemd unit below runs this path literally, and it is also what the
    # tmux server's children find on PATH.
    ln -sfn "$HOME/.local/share/mise/shims/tmux" "$HOME/.local/bin/tmux"
    echo "  -> $HOME/.local/bin/tmux"

    # tmux-continuum writes this unit when @continuum-boot is on, but only if it
    # does not exist (write_unit_file_unless_exists) -- an existing one is left
    # alone and merely kept enabled. So own it outright rather than layering
    # drop-ins on a generated file.
    #
    # Two differences from what continuum generates. PATH, because every plugin
    # script is a child of the tmux server and calls bare `tmux`, and systemd's
    # default PATH has no ~/.local/bin: without it the server comes up and not one
    # plugin loads -- no restore on boot, no periodic save, no save on shutdown,
    # and no error anywhere. And no DISPLAY=:0, which continuum hardcodes: there
    # is no X server at :0 here, and every restored pane inherits it and then
    # believes there is a GUI.
    local unit="$HOME/.config/systemd/user/tmux.service"
    mkdir -p "$(dirname "$unit")"
    cat > "$unit" <<EOF
[Unit]
Description=tmux default session (detached)
Documentation=man:tmux(1)

[Service]
Type=forking
Environment=PATH=$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=$HOME/.local/bin/tmux new-session -d

ExecStop=$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh
ExecStop=$HOME/.local/bin/tmux kill-server
# Stopping takes the panes with it. Only what is listed in @resurrect-processes
# comes back, so a server that has to survive belongs in its own unit, not in a
# pane.
KillMode=control-group

RestartSec=2

[Install]
WantedBy=default.target
EOF
    echo "  -> $unit"
    systemctl --user daemon-reload
    systemctl --user enable tmux.service
}
install_tmux_runtime

# A shared library, so it is built rather than symlinked. For servers that offer
# no way to choose a listen address and would otherwise sit on 0.0.0.0 -- which
# on a shared machine means the LAN. Used from a unit as
# Environment=LD_PRELOAD=~/.local/lib/bind-localhost.so
install_bind_localhost() {
    command -v gcc >/dev/null || { echo "Skipped [Tools: bind-localhost]: no gcc."; return; }
    read -rp "Install [Tools: bind-localhost.so]? (y/n): " yn
    case $yn in
        [Yy]*) ;;
        *) echo "Skipped [Tools: bind-localhost]."; return ;;
    esac
    mkdir -p "$HOME/.local/lib"
    gcc -shared -fPIC -O2 -Wall -Wextra \
        -o "$HOME/.local/lib/bind-localhost.so" "$DOTFILES_DIR/lib/bind-localhost.c" -ldl
    echo "  -> $HOME/.local/lib/bind-localhost.so"
    "$DOTFILES_DIR/lib/test-bind-localhost.sh" || true
}
install_bind_localhost

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

# settings.json above is cross-platform on purpose, so the hooks and the status
# line that only work here are not in it. They live in settings.linux.json and
# are merged into ~/.claude/settings.local.json, which cannot be symlinked
# because it also holds per-project permissions and MCP servers that are not in
# version control. Idempotent: rerunning prints "already current".
install_claude_linux_settings() {
    local layer="$DOTFILES_DIR/.claude/settings.linux.json"
    local target="$HOME/.claude/settings.local.json"

    [ -f "$layer" ] || { echo "Skipped [AI: Claude Code Linux layer]: $layer missing."; return; }
    command -v node >/dev/null || { echo "Skipped [AI: Claude Code Linux layer]: no node."; return; }

    read -rp "Install [AI: Claude Code Linux layer (hooks + statusLine)]? (y/n): " yn
    case $yn in
        [Yy]*) ;;
        *) echo "Skipped [AI: Claude Code Linux layer]."; return ;;
    esac

    LAYER="$layer" TARGET="$target" node <<'NODE'
const fs = require('fs');
const layer = JSON.parse(fs.readFileSync(process.env.LAYER, 'utf8'));
delete layer['$comment'];

const target = process.env.TARGET;
const before = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : '{}';
const out = JSON.parse(before);

for (const [key, value] of Object.entries(layer)) {
  // permissions.allow is the one key both sides own: this file adds rtk, the
  // machine-local file accumulates per-project grants. Union them rather than
  // letting either side win, and keep it sorted-stable so reruns are no-ops.
  if (key === 'permissions') {
    out.permissions = out.permissions || {};
    const have = new Set(out.permissions.allow || []);
    for (const rule of value.allow || []) have.add(rule);
    out.permissions.allow = [...have];
  } else {
    // hooks and statusLine are owned outright by this file. Replacing rather
    // than merging is what makes a rerun idempotent, and what lets a hook be
    // removed here and actually disappear.
    out[key] = value;
  }
}

const after = JSON.stringify(out, null, 2) + '\n';
if (after === before) { console.log('  already current'); process.exit(0); }
if (fs.existsSync(target)) {
  const backup = target + '.' + new Date().toISOString().replace(/\D/g, '').slice(0, 14);
  fs.copyFileSync(target, backup);
  console.log('  backed up -> ' + backup);
}
fs.mkdirSync(require('path').dirname(target), { recursive: true });
fs.writeFileSync(target, after);
console.log('  -> ' + target);
NODE
}
install_claude_linux_settings

# Receives screenshots from the Windows side so a Claude Code session over ssh
# can be shown a picture. See .config/paste-shot/README.md for why this is
# needed at all and why it is a socket rather than scp.
install_paste_shot() {
    read -rp "Install [AI: paste-shot receiver]? (y/n): " yn
    case $yn in
        [Yy]*) ;;
        *) echo "Skipped [AI: paste-shot receiver]."; return ;;
    esac

    mkdir -p "$HOME/.config/systemd/user"
    # Symlinked rather than copied: a `git pull` that changes the unit should
    # only need a daemon-reload, not a rerun of this script.
    ln -sfn "$DOTFILES_DIR/.config/paste-shot/paste-shot.service" \
            "$HOME/.config/systemd/user/paste-shot.service"
    echo "  -> $HOME/.config/systemd/user/paste-shot.service"

    systemctl --user daemon-reload
    systemctl --user enable --now paste-shot.service
    if systemctl --user is-active --quiet paste-shot.service; then
        echo "  active on ${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/paste-shot.sock"
    else
        echo "  NOT running -- journalctl --user -u paste-shot.service"
    fi

    echo "  the Windows side needs this under Host $(hostname) in ~/.ssh/config:"
    echo "      LocalForward 127.0.0.1:47291 ${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/paste-shot.sock"
}
install_paste_shot

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
