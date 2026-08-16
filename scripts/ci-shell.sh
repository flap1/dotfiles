#!/usr/bin/env bash
# Policy, shellcheck, shfmt, and a zshenv smoke test. No network.
# Run from the repository root.

set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"

bash scripts/policy.sh
bash scripts/ci-pr-title.sh --self-test

mapfile -t files < <(
    git ls-files '*.sh' 'bin/*' 'packages/*' 'lib/*' 'scripts/*' '.git_template/hooks/*' |
        while read -r f; do
            head -c 2 "$f" | grep -q '#!' && head -1 "$f" | grep -qE 'sh$|bash' && echo "$f"
        done
)
printf '%s\n' "${files[@]}"
shellcheck -x "${files[@]}"

shfmt -i 4 -ci -s -d \
    bootstrap.sh \
    bin \
    packages \
    lib \
    scripts \
    .git_template/hooks

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
