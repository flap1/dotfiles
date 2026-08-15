# dotfiles

A Linux workstation reached over ssh from Windows Terminal and driven from
tmux: zsh with zinit and starship, Neovim, and the configuration for the AI
CLIs.

Public repository. Nothing secret belongs here, and gitleaks runs on every
commit and in CI to keep it that way.

## Install

```bash
git clone https://gitlab.com/flap1/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` is for a machine with nothing on it: system packages, then every
tool mise declares, then the symlinks. Once a machine is set up, `./install.sh`
is enough — it links and composes configuration and installs no software.

```bash
./install.sh --dry-run          # what would change
./install.sh --only Cursor      # one category
./install.sh -y                 # no questions
```

## Layout

| path | what |
| --- | --- |
| `bootstrap.sh` | the entry point on a bare machine |
| `install.sh` | symlinks and composed configuration, nothing else |
| `packages/` | what installs software |
| `bin/` | scripts on PATH |
| `.config/` | linked into `~/.config` |
| `.claude/` `.cursor/` `.codex/` | AI CLI configuration |
| `lefthook.yml` | pre-commit gates: gitleaks, shellcheck, shfmt |

Tools are declared in `.config/mise/config.toml` with `mise.lock` beside it, so
`mise install` is the entire install step and versions are pinned by checksum.

Configuration takes one of two shapes, and picking the wrong one is the
recurring mistake here. Files only this repository writes are symlinked. Files
a CLI also writes are composed into, because a symlink there sends
machine-local churn — and, for Cursor, an email address and user id — straight
into a public repository.

## Day to day

```bash
dotfiles status    # dirty, unpushed, unpulled
dotfiles pull      # fast-forward, then say whether install.sh needs rerunning
dotfiles doctor    # broken links, config drift, whether the gates are live
```

A shell started more than a day after the last check fetches in the background
and prints one line if origin has moved.

## Commands

Pipe suffixes, after any command:

| suffix | expands to |
| --- | --- |
| `L` | `\| bat --style=plain` |
| `H` | `\| head` |
| `G` | `\| rg -S` |
| `A` | `\| awk` |
| `C` | `\| tee >(pbcopy)` |
| `X` | `\| xargs` |

Replacements:

| command | runs |
| --- | --- |
| `cat` `less` | `bat` |
| `ls` `l` `ll` `lt` `tree` | `eza`, variously |
| `du` | `dust` |
| `ps` | `procs --tree` |
| `gre` | `grep -H -n -I --color=auto` |
| `fd` | `fd -E gdrive` |
| `diff` | `delta` |
| `vim` `v` | `$EDITOR`, which is nvim where it exists |
| `rm` | `trash put` — recoverable, not deleted |
| `mv` `cp` | the same, with `-i` |
| `python` `pip` | `python3` `pip3` |

Additions:

| command | what |
| --- | --- |
| `..` `.2` … `.5` | up that many directories |
| `<dir_name>` | cd to a directory of that name in `.`, `..` or `~`; use `./name` when it collides with a command |
| `mkcd` | make a directory and enter it |
| `cb` `ch` | search Chrome bookmarks / history |
| `gitfix` | repair a commit made on the wrong branch |
| `update` | system update |
| `pdf_unlock` | remove a PDF password |
| `ga` `gc` `gp` `gl` `gpo` `glom` `gll` | git add / commit / push / pull / push -u / pull origin main / log --oneline |
| `di` `dr` `ds` `dps` `drm` `dcb` `dcu` `dcd` | docker and compose |
| `zmv` | e.g. `zmv -w 'from' 'to'` |

## Keybindings

There is no keymap document here. Both tools list their own bindings at
runtime, and a checked-in copy silently disagrees with the config the moment
either changes.

| | |
| --- | --- |
| nvim | `<Leader>fk`, or which-key after any prefix |
| tmux | `prefix ?` |
| lazygit | `?` |

The rules the nvim keymaps follow are stated at the top of
`.config/nvim/lua/core/keymaps.lua`.

## Windows

```powershell
powershell -File %UserProfile%\dotfiles\setup_windows.ps1
```

No elevation needed. Directories are linked with junctions rather than
symlinks, because `mklink /d` requires elevation or Developer Mode and a
junction does not. Never hardlinks: git and Windows Terminal replace files on
save, which breaks the link at that moment and leaves the old configuration in
place with nothing to say so.

What the script does:

- junctions `.config/nvim` to `~/.config/nvim`. This machine sets
  `XDG_CONFIG_HOME` to `~/.config`, so not the Windows-native
  `~/AppData/Local/nvim`
- junctions `.config/windows-terminal/LocalState` to Terminal's LocalState.
  **Close every Terminal window first**: while one is running it holds
  settings.json and the directory cannot be renamed, which the script detects
  and stops on
- pins `git core.sshCommand` to the Windows OpenSSH
- with `-Gitconfig`, includes `.config/git/.gitconfig` from `~/.gitconfig`. Off
  by default because the shared gitconfig sets `core.pager = delta` and
  `core.editor = nvim`, which break git where neither is installed
  (`scoop install delta neovim`, then enable it). The include goes first, so
  machine-specific settings in `~/.gitconfig` win

**Why the whole LocalState and not settings.json alone.** Terminal *replaces*
the file when the GUI saves, which breaks a link to it and stops hot-reload for
edits made in an editor. A junction over LocalState avoids both and is
bidirectional: a GUI change shows up as a repository diff with no import step.
Runtime state is excluded by `LocalState/.gitignore`.

**Why ssh is pinned.** Git for Windows ships an MSYS build of ssh that comes
first on PATH in Git Bash, and the two implementations disagree: the MSYS one
treats `C:\...` in `~/.ssh/config` as a literal string, silently ignores the
include, and keeps keys in a different agent. A host that works in PowerShell
then fails in Git Bash with nothing reported. Pinning git to the Windows binary
leaves one ssh.

Shift+Enter is bound to send ESC + CR through `sendInput`, which Claude Code
reads as alt+enter and turns into a newline. `/terminal-setup` covers iTerm2
and VSCode, not Windows Terminal.

## Fonts

[UDEV Gothic 35NFLG](https://github.com/yuru7/udev-gothic) and
[Nerd Fonts](https://www.nerdfonts.com/). `packages/fonts.sh` installs them
into `~/.local/share/fonts`; on Windows, drag the ttf files onto
Settings > Personalisation > Fonts.
