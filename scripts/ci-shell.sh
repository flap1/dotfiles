#!/usr/bin/env bash
# Policy, shellcheck, shfmt, actionlint, and a zshenv smoke test. No network.
# Run from the repository root.

set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"

bash scripts/policy.sh
bash scripts/ci-pr-title.sh --self-test

# One list for both tools. Directory walks skip different files (shfmt
# ignores unknown extensions; a glob misses extensionless bins).
mapfile -t files < <(
    git ls-files -z |
        while IFS= read -r -d '' f; do
            [ -f "$f" ] || continue
            head -1 "$f" | grep -qE '^#!.*(sh|bash)$' && echo "$f"
        done
)
printf '%s\n' "${files[@]}"
shellcheck -x "${files[@]}"
shfmt -i 4 -ci -s -d "${files[@]}"

tmp=$(mktemp -d)
mkdir -p "$tmp/.config"
cp .zshenv "$tmp/.zshenv"
cp -a .config/zsh "$tmp/.config/zsh"
out=$(HOME="$tmp" zsh -f -c "source $tmp/.zshenv; echo ok" 2>&1)
echo "$out"
if echo "$out" | grep -q 'no such file or directory'; then
    echo "zshenv sourced a missing file"
    exit 1
fi
echo "$out" | grep -qx 'ok'

actionlint
