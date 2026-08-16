#!/usr/bin/env bash
# Print tracked (or staged) files whose shebang is sh or bash, one path per line.
# usage: scripts/shell-files.sh [--staged]

set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"

is_bourne() {
    local f=$1
    [ -f "$f" ] || return 1
    head -1 "$f" | grep -qE '^#!.*(sh|bash)$'
}

if [ "${1-}" = --staged ]; then
    git diff --cached --name-only --diff-filter=ACMR -z
else
    git ls-files -z
fi |
    while IFS= read -r -d '' f; do
        is_bourne "$f" && printf '%s\n' "$f"
    done
