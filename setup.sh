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
install_category "AI: Claude Code (hooks + skills + instructions)" \
    ".claude/hooks"        "$HOME/.claude/hooks" \
    ".claude/skills"       "$HOME/.claude/skills" \
    ".claude/statusline.mjs" "$HOME/.claude/statusline.mjs" \
    ".claude/CLAUDE.md"    "$HOME/.claude/CLAUDE.md" \
    ".claude/RTK.md"       "$HOME/.claude/RTK.md"

# ~/.claude/settings.json is composed, not symlinked, for the same reason
# setup_windows.ps1 composes it: Claude Code rewrites that file whenever you
# change anything from /config or /model, so a symlink hands machine-local
# choices straight into the shared repo. That is not hypothetical -- the symlink
# this replaced turned one /model on a server into a tracked change to the file
# every other machine reads.
#
# Three layers, each narrower than the last, matching the Windows side:
#
#   .claude/settings.json        every machine
#   .claude/settings.linux.json  every Linux machine: rtk hooks, statusLine
#   .claude/settings.local.json  this machine only; gitignored, often absent
#
# The layers land in ~/.claude/settings.json rather than settings.local.json,
# which is where the Linux layer used to go. Claude Code has no user-scope local
# settings file: its .claude/settings.local.json is project-scoped, resolved
# against the repository you started in. $HOME is not a repository here, so that
# file was read only by sessions started from $HOME, and every session started
# in a project ran without the rtk hooks or the status line. User scope has no
# such condition.
#
# Idempotent: rerunning prints "already current".
install_claude_settings() {
    local shared="$DOTFILES_DIR/.claude/settings.json"
    local target="$HOME/.claude/settings.json"

    [ -f "$shared" ] || { echo "Skipped [AI: Claude Code settings]: $shared missing."; return; }
    command -v node >/dev/null || { echo "Skipped [AI: Claude Code settings]: no node."; return; }

    read -rp "Install [AI: Claude Code settings (shared + linux + local)]? (y/n): " yn
    case $yn in
        [Yy]*) ;;
        *) echo "Skipped [AI: Claude Code settings]."; return ;;
    esac

    SHARED="$shared" \
    LINUX="$DOTFILES_DIR/.claude/settings.linux.json" \
    LOCAL="$DOTFILES_DIR/.claude/settings.local.json" \
    TARGET="$HOME/.claude/settings.json" node <<'NODE'
const fs = require('fs');
const path = require('path');

const read = (p) => {
  if (!p || !fs.existsSync(p)) return null;
  const o = JSON.parse(fs.readFileSync(p, 'utf8'));
  delete o['$comment'];
  return o;
};

const out = read(process.env.SHARED);
// A missing layer is normal rather than an error: settings.local.json is
// gitignored, so a fresh clone has none by definition.
const layers = [
  ['settings.linux.json', read(process.env.LINUX)],
  ['settings.local.json', read(process.env.LOCAL)],
];

for (const [name, layer] of layers) {
  if (!layer) continue;
  for (const [key, value] of Object.entries(layer)) {
    // permissions is the one key every layer has a stake in: the shared file
    // carries the baseline, the Linux layer adds rtk, and the local file
    // accumulates grants for this box. Letting the last layer win would
    // silently drop rtk, so union the rule lists instead. Order is preserved
    // and duplicates collapse, which keeps a rerun a no-op.
    if (key === 'permissions') {
      out.permissions = out.permissions || {};
      for (const kind of ['allow', 'deny', 'ask']) {
        if (!value[kind]) continue;
        out.permissions[kind] = [...new Set([...(out.permissions[kind] || []), ...value[kind]])];
      }
      continue;
    }
    // Everything else is top level only. A deep merge would let a layer
    // half-override a nested object, which is harder to reason about than
    // replacing the whole key and being able to see what you replaced.
    out[key] = value;
    console.log(`  overlaid ${key} from ${name}`);
  }
}

const target = process.env.TARGET;
// A symlink left by an older run has to go, or writeFileSync follows it and
// writes through to the repo -- the exact failure this function exists to end.
if (fs.existsSync(target) && fs.lstatSync(target).isSymbolicLink()) {
  fs.unlinkSync(target);
  console.log('  removed the old symlink into the repo');
}

const before = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : null;
const after = JSON.stringify(out, null, 2) + '\n';
if (after === before) { console.log('  already current'); process.exit(0); }
if (before !== null) {
  // Hand edits made through /config live only here, so keep a copy.
  const backup = target + '.' + new Date().toISOString().replace(/\D/g, '').slice(0, 14);
  fs.copyFileSync(target, backup);
  console.log('  backed up -> ' + backup);
}
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.writeFileSync(target, after);
console.log('  -> ' + target);
NODE
}
install_claude_settings


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
