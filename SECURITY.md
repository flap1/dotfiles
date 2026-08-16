# Security

This repository is public. Treat every tracked file as already disclosed.

## Do not file a public issue for a secret

If a credential, token, private key, or internal hostname is in the tree
or in git history, open a [GitHub security advisory](https://github.com/flap1/dotfiles/security/advisories/new)
and say so in the title. Do not paste the secret in a public issue, a
pull request, or a comment.

Rotate the credential yourself if you can; a report here cannot revoke
someone else's token.

## What this tree is built not to carry

- Identities: git `user.name` / `user.email` live in untracked
  `~/.gitconfig.local`
- Agent write grants and Cursor `approvalMode` live in gitignored
  `settings.local.json` / `cli-config.local.json`
- Hostnames, employer paths, and machine-only bins stay out of tracked files

`scripts/policy.sh` and gitleaks are ratchets, not a promise that history
is clean.
