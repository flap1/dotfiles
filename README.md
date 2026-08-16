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

`bootstrap.sh` is a bare machine: system packages, mise, then links.
`./install.sh` is enough after that — links and composed config, no software.
Git identity is not in this repository: put `user.name` and `user.email` in
`~/.gitconfig.local` before the first commit.

```bash
./install.sh --dry-run
./install.sh --only zsh
./install.sh -y
```

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

A new interactive shell runs `dotfiles check` in the background at most
once a day. If `origin/main` is ahead it prints one line pointing at
`dotfiles update`. That command fast-forwards, runs `mise install` when
the catalog moved, and reruns `install.sh --yes` when linked or composed
files moved. `bootstrap.sh` still needs a person: it uses sudo.

On Linux, `C` / `Y` copy a pipeline to the clipboard (`wl-copy` or `pbcopy`).

## Layout

| path | what |
| --- | --- |
| `bootstrap.sh` | bare Linux machine |
| `bootstrap.ps1` | bare Windows machine (scoop, then `install.ps1`) |
| `install.sh` | Linux: symlinks and composed configuration |
| `install.ps1` | Windows: junctions and composed configuration |
| `packages/` | `system.sh`; `tmux.sh` and `fonts.sh` from there |
| `bin/` | on PATH |
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

Directories are junctions, not hardlinks (`mklink /d` needs elevation). Git
replaces files on save; a hardlink silently becomes a copy.

- `.config/nvim` → `~/.config/nvim`
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
