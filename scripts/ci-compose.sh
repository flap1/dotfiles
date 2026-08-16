#!/usr/bin/env bash
# Compose scripts: union, idempotence, no leftover symlink. No network.

set -euo pipefail

root=$(git rev-parse --show-toplevel)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

shared="$tmp/shared.json"
localf="$tmp/local.json"
target="$tmp/out/settings.json"
mkdir -p "$tmp/out"
ln -s "$shared" "$target"

cat >"$shared" <<'JSON'
{"permissions":{"allow":["Read(**)"]},"model":"opus"}
JSON
cat >"$localf" <<'JSON'
{"permissions":{"allow":["WebSearch"]},"effortLevel":"medium"}
JSON

SHARED="$shared" LOCAL="$localf" TARGET="$target" node "$root/lib/compose-claude.js" >/tmp/compose1.log
[ ! -L "$target" ]
allow=$(jq -r '.permissions.allow | sort | join(",")' "$target")
[ "$allow" = "Read(**),WebSearch" ]
[ "$(jq -r .model "$target")" = opus ]
[ "$(jq -r .effortLevel "$target")" = medium ]

SHARED="$shared" LOCAL="$localf" TARGET="$target" node "$root/lib/compose-claude.js" >/tmp/compose2.log
grep -q 'already current' /tmp/compose2.log

# Cursor: live is the base; shared overlays; authInfo on live survives.
live="$tmp/cursor.json"
cat >"$live" <<'JSON'
{"authInfo":{"email":"keep@example.com"},"approvalMode":"unrestricted"}
JSON
cat >"$shared" <<'JSON'
{"vimMode":true,"approvalMode":"allowlist"}
JSON
SHARED="$shared" LOCAL="" TARGET="$live" node "$root/lib/compose-cursor.js" >/dev/null
[ "$(jq -r .authInfo.email "$live")" = "keep@example.com" ]
[ "$(jq -r .approvalMode "$live")" = allowlist ]
[ "$(jq -r .vimMode "$live")" = true ]

# Codex: shared tables replace; a live-only table stays.
cat >"$tmp/shared.toml" <<'TOML'
model = "gpt-5"
model_reasoning_effort = "medium"

[table.a]
x = 1
TOML
cat >"$tmp/live.toml" <<'TOML'
model = "old"

[table.a]
x = 0

[projects."/abs/path"]
trust = true
TOML
SHARED="$tmp/shared.toml" TARGET="$tmp/live.toml" node "$root/lib/compose-codex.js" >/dev/null
grep -q 'model = "gpt-5"' "$tmp/live.toml"
grep -q 'x = 1' "$tmp/live.toml"
grep -q 'projects."/abs/path"' "$tmp/live.toml"
