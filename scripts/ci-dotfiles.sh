#!/usr/bin/env bash
# bin/dotfiles check and update against a local origin. No network.
# Seeds from the working tree so an uncommitted bin/dotfiles is what is tested.

set -euo pipefail

root=$(git rev-parse --show-toplevel)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/src"
git -C "$root" ls-files -z | while IFS= read -r -d '' f; do
    [ -e "$root/$f" ] || [ -L "$root/$f" ] || continue
    mkdir -p "$tmp/src/$(dirname "$f")"
    cp -a "$root/$f" "$tmp/src/$f"
done

git -C "$tmp/src" init --quiet -b main
git -C "$tmp/src" config user.email ci@example.com
git -C "$tmp/src" config user.name ci
git -C "$tmp/src" add -A
git -C "$tmp/src" commit --quiet -m seed

git clone --quiet --bare "$tmp/src" "$tmp/origin.git"
git clone --quiet "$tmp/origin.git" "$tmp/dotfiles"

export DOTFILES_DIR="$tmp/dotfiles"
export XDG_STATE_HOME="$tmp/state"
mkdir -p "$XDG_STATE_HOME/dotfiles"
dot="$tmp/dotfiles/bin/dotfiles"

out=$("$dot" update)
echo "$out" | grep -q 'already up to date'

git -C "$tmp/dotfiles" remote set-url origin "$tmp/missing.git"
rm -f "$XDG_STATE_HOME/dotfiles/last-update-check"
"$dot" check
[ ! -f "$XDG_STATE_HOME/dotfiles/last-update-check" ]
git -C "$tmp/dotfiles" remote set-url origin "$tmp/origin.git"

git clone --quiet "$tmp/origin.git" "$tmp/push"
git -C "$tmp/push" config user.email ci@example.com
git -C "$tmp/push" config user.name ci
echo extra >>"$tmp/push/README.md"
git -C "$tmp/push" add README.md
git -C "$tmp/push" commit --quiet -m 'ci: origin ahead'
git -C "$tmp/push" push --quiet origin HEAD:main

rm -f "$XDG_STATE_HOME/dotfiles/last-update-check"
msg=$("$dot" check)
echo "$msg" | grep -q 'dotfiles update'

out=$("$dot" update)
echo "$out" | grep -q 'pulled 1 commit'
echo "$out" | grep -qv 'installed files changed'

echo "$tmp/no-such-link" >"$XDG_STATE_HOME/dotfiles/manifest"
if "$dot" doctor >/tmp/doctor.out; then
    echo "doctor exited 0 with a missing link"
    cat /tmp/doctor.out
    exit 1
fi
grep -q missing /tmp/doctor.out
