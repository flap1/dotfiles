# dotfiles

Public repository. Anything pushed here is world-readable permanently.

Origin is GitHub: `https://github.com/flap1/dotfiles`. `bootstrap.sh` is the
entry point on a bare machine. `install.sh` alone is enough once a machine is
set up -- it only links and composes, never installs software.

- **symlink** — files only this repository writes. Each link is appended to
  `$XDG_STATE_HOME/dotfiles/manifest`.
- **compose** — files a CLI also writes (`lib/compose-*.js`, called from both
  `install.sh` and `install.ps1`). A symlink there sends machine-local churn,
  and in Cursor's case an email address and user id, into this repository.

A new interactive shell runs `dotfiles check` in the background at most once
a day. `dotfiles update` fast-forwards and applies; it never runs
`bootstrap.sh` (sudo).

A skill under `.claude/skills/` that an upstream owns is gitignored and listed
in `.claude/skills/VENDOR`. `npx skills update -g` installs them. Cursor Agent
does not read Claude plugins; `install.sh` mirrors those trees into
`~/.cursor/skills` and writes `/memo-ja` `/humanize-ja` aliases when
`natural-japanese` is installed.

Machine-wide Claude session files are gitignored (`.claude/CLAUDE.md`,
`.claude/RTK.md`). This file is the agent brief for work *on this repository*.

## Rules

- Shell passes `shellcheck` and `shfmt -i 4 -ci -s`.
- `install.sh` stays idempotent. CI asserts it.
- Comments say why, not what.
- Code and comments are in English. CJK is limited to the approved Japanese-language skills and Neovim IME mappings enforced by `scripts/policy.sh`.
- A path that stops being used is deleted.
- Agent write permissions (`git push`, Cursor `approvalMode`) live in the
  gitignored `settings.local.json` / `cli-config.local.json`, never here.
- Host addresses and employer units are not in this repository.
