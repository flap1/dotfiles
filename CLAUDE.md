# dotfiles

Public repository. Anything pushed here is world-readable permanently: treat a
leaked value as compromised rather than removable.

## Layout

`bootstrap.sh` is the entry point on a bare machine: packages/system.sh, then
`mise install`, then `install.sh`. `install.sh` alone is enough once a machine
is set up -- it only links and composes, never installs software.

What `install.sh` does takes one of two shapes, and picking the wrong one is
the recurring mistake here:

- **symlink** — `link_category` -> `create_symlink`, for files only this
  repository writes. Each link is appended to
  `$XDG_STATE_HOME/dotfiles/manifest`, which is what `dotfiles doctor` reads.
- **compose** — `install_claude_settings`, `install_cursor_settings`,
  `install_codex_settings`, for files a CLI also writes. A symlink there sends
  machine-local churn, and in Cursor's case an email address and user id,
  straight into this repository.

The two JSON composers run in opposite directions on purpose. Claude rebuilds
the target from the repository. Cursor takes the live file as its base and
layers the repository on top, because `cli-config.json` holds `authInfo` and
rebuilding it forces a re-login; the cost is that Cursor's side cannot
propagate a deletion. Codex is spliced by `[table]` header rather than by
value, because `[projects."/abs/path"]` keys break a hand-rolled TOML writer.

A third kind of file lives here that `install.sh` never writes: a skill under
`.claude/skills/` that an upstream owns. `~/.claude/skills` is a symlink to this
repository, so `npx skills add --copy` lands a foreign tree inside it and the
next `npx skills update -g` replaces that tree wholesale. An edit made in place
is lost without warning; extend one by writing a separate skill beside it that
references it. `.claude/skills/VENDOR` is the list, and `dotfiles doctor` reads
it.

`.claude/CLAUDE.md` is not this file. It is symlinked to `~/.claude/CLAUDE.md`
and loads into every session on this machine, so repository-specific guidance
belongs here at the root and nowhere else.

## Commands

```bash
./bootstrap.sh          # bare machine: packages, tools, links
./install.sh -y         # links only, no prompts
dotfiles status         # dirty / unpushed / unpulled
dotfiles doctor         # manifest links, composed-file drift, gates
gitleaks git --redact   # what CI runs
npx skills update -g    # vendored third-party skills under .claude/skills
shellcheck bin/dotfiles && shfmt -i 4 -ci -s -d bin/dotfiles
```

## Rules

- Shell passes `shellcheck` and `shfmt -i 4 -ci -s`. A `disable=` needs a
  reason on the line above it.
- `install.sh` stays idempotent: a second run changes no file. CI asserts it.
- Comments say why, not what. No process history, no restating the code.
- Code and comments in English.
- A path that stops being used gets deleted, not commented out. Git keeps it.
- Prefer a mechanism the tool already has over new plumbing: `-p` profiles,
  lefthook, XDG variables. Check before writing a script.
