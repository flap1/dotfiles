<!--
  main accepts pull requests only. Headings match the local harness
  (`## Summary`, `## Test plan`). The Summary is Google's why+what;
  Test plan is the checks in CONTRIBUTING.md. There is no release-note
  block: this tree is applied with git.
-->

## Summary

<!-- Why this exists, then what a reviewer should look at. Link the issue if there is one. -->

## Test plan

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
