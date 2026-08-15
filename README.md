# dotfiles

Public. Clone, then:

```bash
git clone https://gitlab.com/flap1/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` is a bare machine: system packages, mise, then links.
`./install.sh` is enough after that — links and composed config, no software.

```bash
./install.sh --dry-run
./install.sh --only zsh
./install.sh -y
```

## Layout

| path | what |
| --- | --- |
| `bootstrap.sh` | bare machine |
| `install.sh` | symlinks and composed configuration |
| `packages/` | `system.sh`; `tmux.sh` and `fonts.sh` from there |
| `bin/` | on PATH |
| `.config/` | linked into `~/.config` |
| `.config/sheldon/plugins.toml` | zsh plugins, pinned by git revision |
| `.claude/` `.cursor/` `.codex/` | AI CLI config. Upstream skills are gitignored; `npx skills update -g` |
| `lefthook.yml` | hooks for *this* repository only |
| `scripts/policy.sh` | ratchet: retired paths stay gone; no CJK in tracked files |

Files only this repository writes are symlinked. Files a CLI also writes are
composed into, because a symlink there sends machine-local churn — and, for
Cursor, an email address and user id — into a public repository.

Git hooks for this repository are lefthook writing into `.git/hooks`. New
repositories get a one-line identity check via `init.templatedir`. There is no
`core.hooksPath`.

```bash
dotfiles status
dotfiles pull
dotfiles doctor
```

## Windows

```powershell
powershell -File %UserProfile%\dotfiles\setup_windows.ps1
```

Directories are junctions, not hardlinks (`mklink /d` needs elevation). Git and
Windows Terminal replace files on save; a hardlink silently becomes a copy.

- `.config/nvim` → `~/.config/nvim`
- `.config/windows-terminal/LocalState` → Terminal LocalState. Close every
  Terminal window first. The whole directory, not `settings.json` alone:
  Terminal *replaces* that file on GUI save.
- `git core.sshCommand` is the Windows OpenSSH. Git for Windows ships an MSYS
  ssh that treats `C:\...` in `~/.ssh/config` as a literal and ignores the
  include.
- `-Gitconfig` includes `.config/git/.gitconfig`. Off by default: that file
  sets `core.pager = delta` and `core.editor = nvim`.
