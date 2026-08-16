#!/usr/bin/env bash
# Staged-only half of scripts/ci-shell.sh: same shebang list, same flags.

set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"

mapfile -t files < <(bash scripts/shell-files.sh --staged)
if [ "${#files[@]}" -eq 0 ]; then
    exit 0
fi
shellcheck -x "${files[@]}"
shfmt -i 4 -ci -s -d "${files[@]}"
