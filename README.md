# dotfiles

[![pipeline](https://gitlab.com/flap1/dotfiles/badges/main/pipeline.svg)](https://gitlab.com/flap1/dotfiles/-/pipelines)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Personal Linux and Windows configuration. Not a framework: fork it and
delete what you do not use.

There is no coverage badge and no release badge. Neither job exists.

## Install

```bash
git clone https://gitlab.com/flap1/dotfiles.git ~/dotfiles
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

Files only this repository writes are symlinked. Files a CLI also writes
are composed into: a symlink there sends machine-local churn — and, for
Cursor, an email address and user id — into a public repository.

Git hooks for this repository are lefthook writing into `.git/hooks`. New
repositories get a one-line identity check via `init.templatedir`. There is
no `core.hooksPath`.

```bash
dotfiles status
dotfiles pull
dotfiles doctor
```

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
