# Security

This repository is public. Treat every tracked file as already disclosed.

## Do not file a public issue for a secret

If a credential, token, private key, or internal hostname is in the tree
or in git history, open a **confidential** GitLab issue on
[flap1/dotfiles](https://gitlab.com/flap1/dotfiles/-/issues/new)
and say so in the title. Do not paste the secret in a public issue, a
merge request, or a comment.

Rotate the credential yourself if you can; a report here cannot revoke
someone else's token.

## What this tree is built not to carry

- Identities: git `user.name` / `user.email` live in untracked
  `~/.gitconfig.local`
- Agent write grants and Cursor `approvalMode` live in gitignored
  `settings.local.json` / `cli-config.local.json`
- Hostnames and employer paths stay out of tracked files; `ci-cache-reap`
  reads `CI_CACHE_HOST`, `CI_CACHE_ROOT`, and `CI_CACHE_REPO` from the
  environment

`scripts/policy.sh` and gitleaks are ratchets, not a promise that history
is clean.
