# Contributing

This is personal configuration, published so it can be cloned and so the
install path stays honest. It is not a distribution and not a plugin
framework.

`main` accepts pull requests only. Direct pushes are refused by a
repository ruleset. A merge waits for `secrets`, `shell`, `install`,
`pr-title`, and `pwsh`. Issues go through the forms under
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

A pull request uses `.github/pull_request_template.md`. The title is the
squash commit, checked by `scripts/ci-pr-title.sh`:

```
<type>: <Uppercase description>
```

Types (and PR labels): `feat`, `fix`, `imprv`, `refactor`, `docs`,
`test`, `chore`. No scope, no trailing period, English. Example:
`feat: Add issue and pull request templates`.

Dependabot opens weekly PRs for GitHub Actions pins. Retitle those to
this format before merge (`chore: Bump actions/checkout to …`); the
title check does not special-case the bot.

Issue labels stay `bug`, `enhancement`, `documentation` — those name
the report, not the commit.

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
