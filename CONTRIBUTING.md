# Contributing

This is personal configuration, published so it can be cloned and so the
install path stays honest. It is not a distribution and not a plugin
framework.

`main` accepts pull requests only. Direct pushes are refused by a
repository ruleset. Issues go through the forms under
`.github/ISSUE_TEMPLATE/` — blank issues are off.

## What to send

Welcome:

- Bugs in `bootstrap.sh`, `install.sh`, `bootstrap.ps1`, `install.ps1`, `bin/dotfiles`, `bin/dotfiles.ps1`, or compose
- False positives or missed cases in `scripts/policy.sh`
- Documentation that is wrong or missing for a stranger cloning the repo

Not useful:

- Your aliases, theme, or editor plugins
- A request to make the tree a framework (chezmoi, stow profiles, Nix)

Fork, delete what you do not use, keep what you do.

A pull request uses `.github/PULL_REQUEST_TEMPLATE.md`. Conventional
Commits, English. The title is the merge commit.

## Checks

From the repository root, the same commands CI runs:

```bash
bash scripts/policy.sh
bash scripts/ci-shell.sh
bash scripts/ci-install.sh
bash scripts/ci-compose.sh
bash scripts/ci-dotfiles.sh
bash scripts/ci-pwsh.sh
```

`ci-install.sh` needs `node` and `jq`. It writes under `/tmp` and does not
touch your home directory. `ci-pwsh.sh` needs `pwsh`.

Secrets: `gitleaks detect --source . --verbose --redact` (full history).
Lefthook runs `gitleaks git --staged` on commit.

Origin is GitHub. CI is `.github/workflows/ci.yml` (pull requests, and
pushes to `main` after merge).

## Language

Tracked files are English. `scripts/policy.sh` rejects CJK except the nvim
IME maps.
