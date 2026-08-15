#!/bin/bash
#
# Symlinks and composed config. Packages come from packages/ and mise; this
# script does not install software.

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/manifest"

ASSUME_YES=0
DRY_RUN=0
ONLY=""

usage() {
    cat <<'EOF'
usage: install.sh [options]

  -y, --yes           answer yes to every category
      --only PATTERN  install only categories matching PATTERN (substring)
      --dry-run       print what would be linked, change nothing
  -h, --help          this

Run bootstrap.sh instead on a machine that has nothing installed yet.
EOF
}

while [ $# -gt 0 ]; do
    case $1 in
        -y|--yes) ASSUME_YES=1 ;;
        --only) ONLY=$2; shift ;;
        --dry-run) DRY_RUN=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
done

# Fail here rather than after twenty prompts. Every composed config needs node
# and every check needs jq, and without them this script "succeeds" while
# silently skipping the half that matters.
missing=""
for c in git node jq; do
    command -v "$c" > /dev/null || missing="$missing $c"
done
if [ -n "$missing" ]; then
    echo "install.sh needs:$missing" >&2
    echo "Run ./bootstrap.sh first." >&2
    exit 1
fi

# One place decides whether a category runs, so -y, --only and --dry-run cannot
# disagree with each other.
ask() {
    local what=$1
    if [ -n "$ONLY" ] && [[ $what != *"$ONLY"* ]]; then
        return 1
    fi
    if [ "$DRY_RUN" = 1 ]; then
        echo "would install [$what]"
        return 1
    fi
    if [ "$ASSUME_YES" = 1 ]; then
        echo "Installing [$what]..."
        return 0
    fi
    local yn
    read -rp "Install [$what]? (y/n): " yn
    case $yn in
        [Yy]*) echo "Installing [$what]..."; return 0 ;;
        *) echo "Skipped [$what]."; return 1 ;;
    esac
}

mkdir -p "$(dirname "$MANIFEST")"
[ "$DRY_RUN" = 1 ] || : >"$MANIFEST"

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
            local yn=y
            [ "$ASSUME_YES" = 1 ] || read -rp "Remove existing symlink $dst? (y/n): " yn
            case $yn in
                [Yy]*) unlink "$dst" || sudo unlink "$dst" ;;
                *) echo "Skipped."; return 1 ;;
            esac
        else
            local yn=y
            [ "$ASSUME_YES" = 1 ] || read -rp "Move $dst to ${dst}.${timestamp}? (y/n): " yn
            case $yn in
                [Yy]*) mv "$dst" "${dst}.${timestamp}" || sudo mv "$dst" "${dst}.${timestamp}" ;;
                *) echo "Skipped."; return 1 ;;
            esac
        fi
    fi

    local parent_dir
    parent_dir=$(dirname "$dst")
    if [ ! -d "$parent_dir" ]; then
        local yn=y
        [ "$ASSUME_YES" = 1 ] || read -rp "Parent directory $parent_dir does not exist. Create it? (y/n): " yn
        case $yn in
            [Yy]*) mkdir -p "$parent_dir" || sudo mkdir -p "$parent_dir" ;;
            *) echo "Skipped."; return 1 ;;
        esac
    fi

    if ! ln -s "$src" "$dst"; then
        echo "Retrying with sudo..."
        sudo ln -sf "$src" "$dst"
    fi
    echo "$dst" >>"$MANIFEST"
    echo "  -> $dst"
}

link_category() {
    local category=$1
    shift
    ask "$category" || return 0
    while [ $# -gt 0 ]; do
        local src=$1 dst=$2
        shift 2
        create_symlink "$DOTFILES_DIR/$src" "$dst" || true
    done
}

# -------------------------------------------------------------------------
# Core: Zsh + Starship configuration
# -------------------------------------------------------------------------
link_category "Core: Zsh + Starship" \
    ".zshenv"                "$HOME/.zshenv" \
    ".zprofile"              "$HOME/.zprofile" \
    ".config/zsh"            "$HOME/.config/zsh" \
    ".config/starship.toml"  "$HOME/.config/starship.toml"

# -------------------------------------------------------------------------
# Editor: Neovim
# -------------------------------------------------------------------------
link_category "Editor: Neovim" \
    ".config/nvim" "$HOME/.config/nvim"

# No terminal emulator config. The terminal is Windows Terminal over ssh, and
# it is configured on the Windows side; tmux owns everything on this end.

# -------------------------------------------------------------------------
# Development tools
# -------------------------------------------------------------------------
link_category "Tools: bin + git template" \
    "bin"            "$HOME/bin" \
    ".git_template"  "$HOME/.git_template"

link_category "Tools: Git config" \
    ".config/git/.gitconfig" "$HOME/.gitconfig"

# The tmux pin in here is load-bearing rather than a preference: tmux.conf targets
# 3.7, and a distro tmux must not be installed alongside it, because an older
# client kills a newer server outright instead of failing -- that is how session
# restore broke once, silently.
link_category "Tools: mise" \
    ".config/mise/config.toml" "$HOME/.config/mise/config.toml"

link_category "Tools: tmux" \
    ".config/tmux/.tmux.conf" "$HOME/.tmux.conf" \
    ".config/tmux/status.sh"  "$HOME/.tmux-status.sh"

# Three things tmux session restore needs that are not symlinks. Idempotent.
write_tmux_service() {
    ask "Tools: tmux runtime (mise trust + shim + systemd unit)" || return 0

    if ! command -v mise > /dev/null; then
        echo "  (mise not installed; run ./bootstrap.sh)"
        return 0
    fi

    # mise trusts ~/.config/mise/config.toml implicitly, but the symlink above
    # resolves into this repo, and an untrusted config does not degrade: every
    # shim fails, tmux included, which takes the terminal with it. Trusting is
    # config, not installation; bootstrap.sh runs `mise install`.
    mise trust "$DOTFILES_DIR/.config/mise/config.toml"

    # The systemd unit below runs this path literally, and it is also what the
    # tmux server's children find on PATH. mkdir first: on a fresh machine
    # ~/.local/bin does not exist, and under `set -e` the failed ln aborted the
    # whole installer, so every category below this line never ran.
    mkdir -p "$HOME/.local/bin"
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
    # A container or an ssh session with no user bus has nothing to enable
    # against. Under `set -e` that aborted the installer and every category
    # below never ran, so the unit is written either way and only the enabling
    # is conditional.
    if systemctl --user show-environment > /dev/null 2>&1; then
        systemctl --user daemon-reload
        systemctl --user enable tmux.service
    else
        echo "  (no user systemd bus; unit written but not enabled)"
    fi
}
write_tmux_service

# A shared library, so it is built rather than symlinked. For servers that offer
# no way to choose a listen address and would otherwise sit on 0.0.0.0 -- which
# on a shared machine means the LAN. Used from a unit as
# Environment=LD_PRELOAD=~/.local/lib/bind-localhost.so
build_bind_localhost() {
    command -v gcc >/dev/null || { echo "Skipped [Tools: bind-localhost]: no gcc."; return; }
    ask "Tools: bind-localhost.so" || return 0
    mkdir -p "$HOME/.local/lib"
    gcc -shared -fPIC -O2 -Wall -Wextra \
        -o "$HOME/.local/lib/bind-localhost.so" "$DOTFILES_DIR/lib/bind-localhost.c" -ldl
    echo "  -> $HOME/.local/lib/bind-localhost.so"
    "$DOTFILES_DIR/lib/test-bind-localhost.sh" || true
}
build_bind_localhost

# -------------------------------------------------------------------------
# Application settings
# -------------------------------------------------------------------------
link_category "App: GNOME + pictures" \
    ".config/gnome"    "$HOME/.config/gnome" \
    ".config/pictures" "$HOME/.config/pictures"

# -------------------------------------------------------------------------
# AI tools
# -------------------------------------------------------------------------
link_category "AI: Claude Code (hooks + skills + instructions)" \
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
compose_claude_settings() {
    local shared="$DOTFILES_DIR/.claude/settings.json"
    local target="$HOME/.claude/settings.json"

    [ -f "$shared" ] || { echo "Skipped [AI: Claude Code settings]: $shared missing."; return; }
    command -v node >/dev/null || { echo "Skipped [AI: Claude Code settings]: no node."; return; }

    ask "AI: Claude Code settings (shared + linux + local)" || return 0

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
compose_claude_settings

link_category "AI: Cursor Agent (status line)" \
    ".cursor/statusline.mjs" "$HOME/.cursor/statusline.mjs"

# ~/.config/cursor/cli-config.json is composed for the same reason the Claude
# settings are, but the composition runs the other way round, and that is
# deliberate: here the live file is the base and the repository layers go on
# top, where the Claude version rebuilds the file from the repository and
# discards what was there.
#
# The reason is that the Cursor CLI keeps things in this file that exist
# nowhere else -- authInfo, the OAuth identity behind `agent login`, plus
# privacyCache and serverConfigCache. Rebuilding the file from the repository
# would delete them and force a re-login on every setup run, and committing
# them would put an email address and user id into a shared repository.
#
# The cost of taking the live file as the base is that this cannot remove a
# key: drop approvalMode from the layer and whatever the CLI last wrote stays.
# Removal is a hand edit, once, on each machine.
#
# Path resolution matches the binary: CURSOR_CONFIG_DIR, else
# $XDG_CONFIG_HOME/cursor, else ~/.cursor. Guessing ~/.cursor unconditionally
# -- which is what the published documentation says -- writes a file that
# nothing reads on any machine that sets XDG_CONFIG_HOME.
compose_cursor_settings() {
    local shared="$DOTFILES_DIR/.cursor/cli-config.json"
    local dir

    [ -f "$shared" ] || { echo "Skipped [AI: Cursor settings]: $shared missing."; return; }
    command -v node >/dev/null || { echo "Skipped [AI: Cursor settings]: no node."; return; }

    if [ -n "${CURSOR_CONFIG_DIR:-}" ]; then
        dir="$CURSOR_CONFIG_DIR"
    elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
        dir="$XDG_CONFIG_HOME/cursor"
    else
        dir="$HOME/.cursor"
    fi

    ask "AI: Cursor settings (layered onto $dir/cli-config.json)" || return 0

    SHARED="$shared" \
    LOCAL="$DOTFILES_DIR/.cursor/cli-config.local.json" \
    TARGET="$dir/cli-config.json" node <<'NODE'
const fs = require('fs');
const path = require('path');

const read = (p) => {
  if (!p || !fs.existsSync(p)) return null;
  const o = JSON.parse(fs.readFileSync(p, 'utf8'));
  delete o['$comment'];
  return o;
};

const target = process.env.TARGET;
// A symlink from an older run would make writeFileSync write through into the
// repository, which is the failure this function exists to prevent.
if (fs.existsSync(target) && fs.lstatSync(target).isSymbolicLink()) {
  fs.unlinkSync(target);
  console.log('  removed the old symlink into the repo');
}

// The live file is the base. On a machine that has never run the CLI there is
// no live file, and starting from {} is right: the CLI fills in its own keys
// on first launch.
const out = read(target) || {};

for (const [name, layer] of [
  ['cli-config.json', read(process.env.SHARED)],
  ['cli-config.local.json', read(process.env.LOCAL)],
]) {
  if (!layer) continue;
  for (const [key, value] of Object.entries(layer)) {
    // permissions is the one key both the repository and the machine have a
    // stake in, so the rule lists union instead of the last writer winning.
    // Same treatment as the Claude side, and for the same reason.
    if (key === 'permissions') {
      out.permissions = out.permissions || {};
      for (const kind of ['allow', 'deny']) {
        if (!value[kind]) continue;
        out.permissions[kind] = [...new Set([...(out.permissions[kind] || []), ...value[kind]])];
      }
      continue;
    }
    out[key] = value;
    console.log(`  overlaid ${key} from ${name}`);
  }
}

const before = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : null;
const after = JSON.stringify(out, null, 2) + '\n';
if (after === before) { console.log('  already current'); process.exit(0); }
if (before !== null) {
  const backup = target + '.' + new Date().toISOString().replace(/\D/g, '').slice(0, 14);
  fs.copyFileSync(target, backup);
  console.log('  backed up -> ' + backup);
}
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.writeFileSync(target, after);
console.log('  -> ' + target);
NODE
}
compose_cursor_settings

# ~/.codex/config.toml holds my settings and the CLI's bookkeeping in one file:
# [projects.*] trust levels, [notice.model_migrations],
# [tui.model_availability_nux] and [marketplaces.*] timestamps all accumulate
# there as you work, and [projects.*] keys are absolute paths that mean nothing
# on another machine.
#
# Codex can layer config -- `codex -p <name>` reads $CODEX_HOME/<name>.config.toml
# on top of the base -- but only from the command line. Setting `profile` in
# config.toml makes 0.147.0 fail to load config at all (`codex doctor` reports
# "failed to load Codex config"), and the flag is refused outside the runtime
# subcommands, so it cannot cover `codex doctor` or `codex login`. Layering at
# install time is what is left.
#
# Role files under .codex/agents/ are mine only, so they are symlinked. Their
# config_file paths in the spliced config.toml are rewritten to absolute ones
# because 0.147's TUI rejects a relative AgentRoleToml.config_file.
#
# The merge is by section, not by value. TOML top-level tables are delimited by
# a [header] at column zero, so the repository's sections can replace the live
# file's sections as whole blocks of text, and every section the repository
# does not mention survives untouched. Nothing re-serialises a TOML value,
# which is where a hand-rolled merge would get the quoting of a key like
# [projects."/home/me/x"] wrong.
compose_codex_settings() {
    local shared="$DOTFILES_DIR/.codex/config.toml"
    local target="${CODEX_HOME:-$HOME/.codex}/config.toml"

    [ -f "$shared" ] || { echo "Skipped [AI: Codex settings]: $shared missing."; return; }
    command -v node >/dev/null || { echo "Skipped [AI: Codex settings]: no node."; return; }

    ask "AI: Codex settings (spliced into $target)" || return 0

    SHARED="$shared" TARGET="$target" node <<'NODE'
const fs = require('fs');
const path = require('path');

// Split a TOML document into a preamble (everything before the first table
// header) and an ordered list of [header, body] sections. A header is a line
// whose first character is '[' -- inside a multi-line array a continuation
// line can also start with '[', so only column zero counts, which is where
// TOML requires the header to be.
function split(text) {
  const pre = [];
  const sections = [];
  let cur = null;
  for (const line of text.split('\n')) {
    if (/^\[/.test(line)) {
      cur = { header: line.trim(), body: [] };
      sections.push(cur);
    } else if (cur) {
      cur.body.push(line);
    } else {
      pre.push(line);
    }
  }
  return { pre, sections };
}

const target = process.env.TARGET;
if (fs.existsSync(target) && fs.lstatSync(target).isSymbolicLink()) {
  fs.unlinkSync(target);
  console.log('  removed the old symlink into the repo');
}

const mine = split(fs.readFileSync(process.env.SHARED, 'utf8'));
const live = fs.existsSync(target)
  ? split(fs.readFileSync(target, 'utf8'))
  : { pre: [], sections: [] };

// The preamble is the bare top-level keys (model, model_reasoning_effort,
// approvals_reviewer). It is entirely mine, so it replaces the live one.
const owned = new Set(mine.sections.map((s) => s.header));
const merged = [
  ...mine.sections,
  ...live.sections.filter((s) => !owned.has(s.header)),
];

for (const s of mine.sections) {
  console.log(`  ${live.sections.some((l) => l.header === s.header) ? 'replaced' : 'added'} ${s.header}`);
}

const home = path.dirname(target);
let body = mine.pre.join('\n').replace(/\n+$/, '') + '\n\n' +
  merged.map((s) => s.header + '\n' + s.body.join('\n').replace(/\n+$/, '')).join('\n\n') + '\n';
body = body.replace(
  /^config_file = "agents\/([^"]+)"$/gm,
  (_, file) => `config_file = ${JSON.stringify(path.join(home, 'agents', file))}`,
);

const before = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : null;
if (body === before) { console.log('  already current'); process.exit(0); }
if (before !== null) {
  const backup = target + '.' + new Date().toISOString().replace(/\D/g, '').slice(0, 14);
  fs.copyFileSync(target, backup);
  console.log('  backed up -> ' + backup);
}
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.writeFileSync(target, body);
console.log('  -> ' + target);
NODE
}
link_category "AI: Codex agents" \
    ".codex/agents" "${CODEX_HOME:-$HOME/.codex}/agents"
compose_codex_settings


# -------------------------------------------------------------------------
# Gates
# -------------------------------------------------------------------------
# lefthook, not core.hooksPath: the global hooksPath already points at the
# lefthook dispatcher, and a per-repo hooksPath would disable it here.
if [ "$DRY_RUN" = 1 ]; then
    echo "would install [gates: lefthook]"
elif command -v lefthook > /dev/null; then
    (cd "$DOTFILES_DIR" && lefthook install)
else
    echo "Skipped [gates]: lefthook not installed."
fi

# -------------------------------------------------------------------------
# Directories
# -------------------------------------------------------------------------
[ -d "$HOME/.git-worktrees" ] || mkdir "$HOME/.git-worktrees"

# -------------------------------------------------------------------------
# Change default shell to zsh
# -------------------------------------------------------------------------
if [ "$DRY_RUN" = 0 ] && [ "$(basename "$SHELL")" != "zsh" ]; then
    yn=y
    [ "$ASSUME_YES" = 1 ] || read -rp "Change default shell to zsh? (y/n): " yn
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

