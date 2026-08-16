# dotfiles

[![CI](https://github.com/flap1/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/flap1/dotfiles/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Personal Linux and Windows configuration. Not a framework: fork it and
delete what you do not use.

There is no coverage badge and no release badge. Neither job exists.
This repository is applied with `git`, not installed from a GitHub Release.

## Install

```bash
git clone https://github.com/flap1/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` is a bare machine: system packages, mise (including
`claude` and `codex`), the Cursor CLI (`agent`), then links.
`./install.sh` is enough after that — links and composed config, no software.
Git identity is not in this repository: put `user.name` and `user.email` in
`~/.gitconfig.local` before the first commit.

```bash
./install.sh --dry-run
./install.sh -y
./install.sh --only yazi --yes
```

`-y` on a machine that has nothing yet installs every category. The same
flag later (including `dotfiles update`) only refreshes categories already
in the manifest. A category is every path it names, or none. To take one
you skipped, `--only` that id with `--yes`.

Files only this repository writes are symlinked. Files a CLI also writes
are composed into: a symlink there sends machine-local churn — and, for
Cursor, an email address and user id — into a public repository.

Git hooks for this repository are lefthook writing into `.git/hooks`. New
repositories get a one-line identity check via `init.templatedir`. There is
no `core.hooksPath`.

```bash
dotfiles status
dotfiles update
dotfiles doctor
```

A new interactive shell runs `dotfiles check` at most once a day. If
`origin/main` is ahead it prints one line pointing at `dotfiles update`.
That command fast-forwards, then applies: Linux runs `mise install` when
the catalog moved and `install.sh --yes` when linked or composed files
moved (only categories already on the machine); Windows runs `install.ps1`. Neither side auto-runs bootstrap
(`bootstrap.sh` needs sudo; `bootstrap.ps1` installs software).

On Linux, `C` / `Y` copy a pipeline to the clipboard (`wl-copy` or `pbcopy`).

Neovim does not download language servers or treesitter parsers when a
file opens. `:Mason` / `:LspInstall` and `:TSInstall` / `:TSUpdate` are
the install steps, and they are yours to run.

## Layout

| path | what |
| --- | --- |
| `bootstrap.sh` | bare Linux machine |
| `bootstrap.ps1` | bare Windows machine (scoop, then `install.ps1`) |
| `install.sh` | Linux: symlinks and composed configuration |
| `install.ps1` | Windows: junctions and composed configuration |
| `packages/` | `system.sh`; `tmux.sh`, `fonts.sh`, `cursor-agent.sh` from there |
| `bin/` | on PATH (`~\bin` on Windows too) |
| `.config/` | linked into `~/.config` |
| `.config/sheldon/plugins.toml` | zsh plugins, pinned by git revision |
| `.claude/` `.cursor/` `.codex/` | AI CLI config. Upstream skills are gitignored; `npx skills update -g` |
| `lefthook.yml` | hooks for *this* repository only |
| `scripts/policy.sh` | ratchet: retired paths stay gone; no CJK in tracked files |
| `.config/paste-shot/` | optional screenshot path; `setup.sh` / `setup.ps1` |

Machine-wide Claude session files (`.claude/CLAUDE.md`, `.claude/RTK.md`)
are gitignored. They are not part of a clone.

## Windows

```powershell
cd $HOME\dotfiles
.\bootstrap.ps1
```

Already set up? `.\install.ps1` is links and composed config, no scoop.

```powershell
dotfiles status
dotfiles update
dotfiles doctor
```

`install.ps1` puts `~\bin` on the user PATH (junction to this repo's `bin`)
and adds a one-line hook to the PowerShell profile so a new session runs
`dotfiles check`. Git Bash `dotfiles` execs the same `bin/dotfiles.ps1`.

Directories are junctions, not hardlinks (`mklink /d` needs elevation). Git
replaces files on save; a hardlink silently becomes a copy.

- Neovim: `%LOCALAPPDATA%\nvim` (what Neovim reads) and `~\.config\nvim`
- `.config/yazi` → `%APPDATA%\yazi\config`
- Windows Terminal LocalState is **not** linked. Close Terminal and rerun
  `install.ps1` once to unhook a leftover junction.
- `git core.sshCommand` is the Windows OpenSSH.
- Shared gitconfig is included once nvim and delta are on PATH (`-Gitconfig`
  forces it).
- SSH hosts and Desktop `sshConfigs` live in gitignored `settings.local.json`
  on that clone.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Install and policy bugs are welcome;
do not send your aliases.

## Security

See [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE)
