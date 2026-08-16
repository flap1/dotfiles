# dotfiles

Public repository. Anything pushed here is world-readable permanently.

`bootstrap.sh` is the entry point on a bare machine. `install.sh` alone is
enough once a machine is set up -- it only links and composes, never installs
software.

- **symlink** — files only this repository writes. Each link is appended to
  `$XDG_STATE_HOME/dotfiles/manifest`.
- **compose** — files a CLI also writes (`compose_claude_settings`,
  `compose_cursor_settings`, `compose_codex_settings`). A symlink there sends
  machine-local churn, and in Cursor's case an email address and user id,
  into this repository.

Claude rebuilds the target from the repository. Cursor takes the live file as
its base and layers the repository on top (`cli-config.json` holds `authInfo`).
Codex is spliced by `[table]` header; `[projects."/abs/path"]` keys break a
hand-rolled TOML writer.

A skill under `.claude/skills/` that an upstream owns is gitignored and listed
in `.claude/skills/VENDOR`. `npx skills update -g` installs them.

Machine-wide Claude session files are gitignored (`.claude/CLAUDE.md`,
`.claude/RTK.md`). This file is the agent brief for work *on this repository*.
Compose of Claude / Cursor / Codex settings is `lib/compose-*.js`, called
from both `install.sh` and `install.ps1`.

## Rules

- Shell passes `shellcheck` and `shfmt -i 4 -ci -s`.
- `install.sh` stays idempotent. CI asserts it.
- Comments say why, not what.
- Code and comments in English. Tracked files carry no CJK.
- A path that stops being used is deleted.
- Agent write permissions (`git push`, Cursor `approvalMode`) live in the
  gitignored `settings.local.json` / `cli-config.local.json`, never here.
- Host addresses and employer units are not in this repository. `ci-cache-reap`
  reads `CI_CACHE_HOST`, `CI_CACHE_ROOT`, and `CI_CACHE_REPO` from the
  environment.
