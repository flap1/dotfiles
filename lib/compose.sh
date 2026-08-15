#!/bin/bash
# Compose CLI config that must not be a symlink. Sourced from install.sh.
# Relies on: DOTFILES_DIR, ask (same shell).

compose_claude_settings() {
    local shared="$DOTFILES_DIR/.claude/settings.json"
    local target="$HOME/.claude/settings.json"

    [ -f "$shared" ] || {
        echo "Skipped [AI: Claude Code settings]: $shared missing."
        return
    }
    command -v node >/dev/null || {
        echo "Skipped [AI: Claude Code settings]: no node."
        return
    }

    ask claude-settings || return 0

    SHARED="$shared" \
        LINUX="$DOTFILES_DIR/.claude/settings.linux.json" \
        LOCAL="$DOTFILES_DIR/.claude/settings.local.json" \
        TARGET="$HOME/.claude/settings.json" node <<'NODE'
const fs = require('fs');
const path = require('path');

const read = (p) => {
  if (!p || !fs.existsSync(p)) return null;
  const o = JSON.parse(fs.readFileSync(p, 'utf8'));
  delete o['$comment'];
  return o;
};

const out = read(process.env.SHARED);
// A missing layer is normal rather than an error: settings.local.json is
// gitignored, so a fresh clone has none by definition.
const layers = [
  ['settings.linux.json', read(process.env.LINUX)],
  ['settings.local.json', read(process.env.LOCAL)],
];

for (const [name, layer] of layers) {
  if (!layer) continue;
  for (const [key, value] of Object.entries(layer)) {
    // permissions is the one key every layer has a stake in: the shared file
    // carries the baseline, the Linux layer adds rtk, and the local file
    // accumulates grants for this box. Letting the last layer win would
    // silently drop rtk, so union the rule lists instead. Order is preserved
    // and duplicates collapse, which keeps a rerun a no-op.
    if (key === 'permissions') {
      out.permissions = out.permissions || {};
      for (const kind of ['allow', 'deny', 'ask']) {
        if (!value[kind]) continue;
        out.permissions[kind] = [...new Set([...(out.permissions[kind] || []), ...value[kind]])];
      }
      continue;
    }
    // Everything else is top level only. A deep merge would let a layer
    // half-override a nested object, which is harder to reason about than
    // replacing the whole key and being able to see what you replaced.
    out[key] = value;
    console.log(`  overlaid ${key} from ${name}`);
  }
}

const target = process.env.TARGET;
// A symlink left by an older run has to go, or writeFileSync follows it and
// writes through to the repo -- the exact failure this function exists to end.
if (fs.existsSync(target) && fs.lstatSync(target).isSymbolicLink()) {
  fs.unlinkSync(target);
  console.log('  removed the old symlink into the repo');
}

const before = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : null;
const after = JSON.stringify(out, null, 2) + '\n';
if (after === before) { console.log('  already current'); process.exit(0); }
if (before !== null) {
  // Hand edits made through /config live only here, so keep a copy.
  const backup = target + '.' + new Date().toISOString().replace(/\D/g, '').slice(0, 14);
  fs.copyFileSync(target, backup);
  console.log('  backed up -> ' + backup);
}
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.writeFileSync(target, after);
console.log('  -> ' + target);
NODE
}

compose_cursor_settings() {
    local shared="$DOTFILES_DIR/.cursor/cli-config.json"
    local dir
    local -a targets

    [ -f "$shared" ] || {
        echo "Skipped [AI: Cursor settings]: $shared missing."
        return
    }
    command -v node >/dev/null || {
        echo "Skipped [AI: Cursor settings]: no node."
        return
    }

    if [ -n "${CURSOR_CONFIG_DIR:-}" ]; then
        dir="$CURSOR_CONFIG_DIR"
    elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
        dir="$XDG_CONFIG_HOME/cursor"
    else
        dir="$HOME/.cursor"
    fi

    targets=("$dir/cli-config.json")
    if [ "$dir" != "$HOME/.cursor" ]; then
        targets+=("$HOME/.cursor/cli-config.json")
    fi

    ask cursor-settings || return 0

    local target
    for target in "${targets[@]}"; do
        echo "  $target"
        SHARED="$shared" \
            LOCAL="$DOTFILES_DIR/.cursor/cli-config.local.json" \
            TARGET="$target" node <<'NODE'
const fs = require('fs');
const path = require('path');

const read = (p) => {
  if (!p || !fs.existsSync(p)) return null;
  const o = JSON.parse(fs.readFileSync(p, 'utf8'));
  delete o['$comment'];
  return o;
};

const target = process.env.TARGET;
// A symlink from an older run would make writeFileSync write through into the
// repository, which is the failure this function exists to prevent.
if (fs.existsSync(target) && fs.lstatSync(target).isSymbolicLink()) {
  fs.unlinkSync(target);
  console.log('  removed the old symlink into the repo');
}

// The live file is the base. On a machine that has never run the CLI there is
// no live file, and starting from {} is right: the CLI fills in its own keys
// on first launch.
const out = read(target) || {};

for (const [name, layer] of [
  ['cli-config.json', read(process.env.SHARED)],
  ['cli-config.local.json', read(process.env.LOCAL)],
]) {
  if (!layer) continue;
  for (const [key, value] of Object.entries(layer)) {
    // permissions is the one key both the repository and the machine have a
    // stake in, so the rule lists union instead of the last writer winning.
    // Same treatment as the Claude side, and for the same reason.
    if (key === 'permissions') {
      out.permissions = out.permissions || {};
      for (const kind of ['allow', 'deny']) {
        if (!value[kind]) continue;
        out.permissions[kind] = [...new Set([...(out.permissions[kind] || []), ...value[kind]])];
      }
      continue;
    }
    out[key] = value;
    console.log(`  overlaid ${key} from ${name}`);
  }
}

const before = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : null;
const after = JSON.stringify(out, null, 2) + '\n';
if (after === before) { console.log('  already current'); process.exit(0); }
if (before !== null) {
  const backup = target + '.' + new Date().toISOString().replace(/\D/g, '').slice(0, 14);
  fs.copyFileSync(target, backup);
  console.log('  backed up -> ' + backup);
}
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.writeFileSync(target, after);
console.log('  -> ' + target);
NODE
    done
}

compose_codex_settings() {
    local shared="$DOTFILES_DIR/.codex/config.toml"
    local target="${CODEX_HOME:-$HOME/.codex}/config.toml"

    [ -f "$shared" ] || {
        echo "Skipped [AI: Codex settings]: $shared missing."
        return
    }
    command -v node >/dev/null || {
        echo "Skipped [AI: Codex settings]: no node."
        return
    }

    ask codex-settings || return 0

    SHARED="$shared" TARGET="$target" node <<'NODE'
const fs = require('fs');
const path = require('path');

// Split a TOML document into a preamble (everything before the first table
// header) and an ordered list of [header, body] sections. A header is a line
// whose first character is '[' -- inside a multi-line array a continuation
// line can also start with '[', so only column zero counts, which is where
// TOML requires the header to be.
function split(text) {
  const pre = [];
  const sections = [];
  let cur = null;
  for (const line of text.split('\n')) {
    if (/^\[/.test(line)) {
      cur = { header: line.trim(), body: [] };
      sections.push(cur);
    } else if (cur) {
      cur.body.push(line);
    } else {
      pre.push(line);
    }
  }
  return { pre, sections };
}

const target = process.env.TARGET;
if (fs.existsSync(target) && fs.lstatSync(target).isSymbolicLink()) {
  fs.unlinkSync(target);
  console.log('  removed the old symlink into the repo');
}

const mine = split(fs.readFileSync(process.env.SHARED, 'utf8'));
const live = fs.existsSync(target)
  ? split(fs.readFileSync(target, 'utf8'))
  : { pre: [], sections: [] };

// The preamble is the bare top-level keys (model, model_reasoning_effort,
// approvals_reviewer). It is entirely mine, so it replaces the live one.
const owned = new Set(mine.sections.map((s) => s.header));
const merged = [
  ...mine.sections,
  ...live.sections.filter((s) => !owned.has(s.header)),
];

for (const s of mine.sections) {
  console.log(`  ${live.sections.some((l) => l.header === s.header) ? 'replaced' : 'added'} ${s.header}`);
}

const home = path.dirname(target);
let body = mine.pre.join('\n').replace(/\n+$/, '') + '\n\n' +
  merged.map((s) => s.header + '\n' + s.body.join('\n').replace(/\n+$/, '')).join('\n\n') + '\n';
body = body.replace(
  /^config_file = "agents\/([^"]+)"$/gm,
  (_, file) => `config_file = ${JSON.stringify(path.join(home, 'agents', file))}`,
);

const before = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : null;
if (body === before) { console.log('  already current'); process.exit(0); }
if (before !== null) {
  const backup = target + '.' + new Date().toISOString().replace(/\D/g, '').slice(0, 14);
  fs.copyFileSync(target, backup);
  console.log('  backed up -> ' + backup);
}
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.writeFileSync(target, body);
console.log('  -> ' + target);
NODE
}
