<!-- main accepts pull requests only. No release-note block: this tree is applied with git. -->

## Summary

Why this pull request exists. Link the issue if there is one.

## Changes

Files and behaviour a reviewer should look at. Not a commit list.

## Test plan

- [ ] `bash scripts/policy.sh`
- [ ] `bash scripts/ci-shell.sh`
- [ ] `bash scripts/ci-install.sh` (needs `node` and `jq`; writes under `/tmp`)
- [ ] `bash scripts/ci-compose.sh`
- [ ] `bash scripts/ci-dotfiles.sh`
- [ ] `bash scripts/ci-pwsh.sh` (needs `pwsh`)

## User-facing

What a clone does differently after merge. Write "None" if nothing.
