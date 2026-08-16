<!--
  main accepts pull requests only. Description shape follows Google's
  eng-practices (why, what, how you tested) plus Kubernetes' user-facing
  note. There is no release-note block: this tree is applied with git.
-->

## Why

<!-- The problem this PR exists to close. Link the issue if there is one. -->

## What

<!-- What a reviewer should look at. Files and behaviour, not a commit list. -->

## How you tested

- [ ] `bash scripts/policy.sh`
- [ ] `bash scripts/ci-shell.sh`
- [ ] `bash scripts/ci-install.sh` (needs `node` and `jq`; writes under `/tmp`)
- [ ] `bash scripts/ci-compose.sh`
- [ ] `bash scripts/ci-dotfiles.sh`
- [ ] `bash scripts/ci-pwsh.sh` (needs `pwsh`)
- [ ] <!-- the actual command you ran that is not the list above -->

## User-facing

<!-- What a clone does differently after merge. "None" is a valid answer. -->

## Notes

<!-- Risk, follow-ups, what was cut. Delete this section if empty. -->
