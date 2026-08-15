#!/usr/bin/env bash
# ci-cache-reap: delete the CI host's per-branch cargo target directories
# whose branch is gone from origin.
#
# Why this exists: .woodpecker.yml gives every branch its own
# CARGO_TARGET_DIR under /var/cache/woodpecker, in up to five lanes
# (target-, target-b-, target-c-, target-msrv-, target-fuzz-). The scoping
# is deliberate and correct — two branches sharing one path corrupted each
# other's fingerprints once already (the lane comment in .woodpecker.yml,
# PR #181, 2026-07-16). What was missing is the other half: nothing ever
# removed a branch's directories when the branch went away. Measured
# 2026-08-15: 219 directories, 712 GB, of which 174 directories and 577 GB
# belonged to branches that no longer exist on origin.
#
# Liveness is asked of the forge and of the kernel, never of a clock. A
# directory survives if its branch is still on origin, or if a build is
# holding cargo's `.cargo-build-lock` inside it — the lock the kernel
# releases whenever that build dies, however it dies. A branch deleted
# while its last pipeline is still running is the case the lock covers.
#
# This runs here rather than on the CI host because `git ls-remote` needs
# credentials for a private repository, and they live here.
#
# Usage:
#   ci-cache-reap.sh            # what would go
#   ci-cache-reap.sh --force    # go
set -euo pipefail

HOST=${CI_CACHE_HOST:-flap1@95.216.27.150}
ROOT=${CI_CACHE_ROOT:-/var/cache/woodpecker}
REPO=${CI_CACHE_REPO:-$HOME/ghq/github.com/syntopic/topic}
FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

# The branch names as the pipeline spells them on disk: every character
# outside [A-Za-z0-9._-] becomes `-`, matching `.woodpecker.yml`'s
# `tr -c 'A-Za-z0-9._-' '-'`.
live=$(/usr/bin/git -C "$REPO" ls-remote --heads origin |
    sed 's|.*refs/heads/||' | sed 's/[^A-Za-z0-9._-]/-/g' | sort -u)

# Refuse to run blind. An empty list means ls-remote failed — a network
# blip, an expired token — and every branch would then look deleted.
[ -n "$live" ] || {
    echo "git ls-remote returned nothing; refusing to reap." >&2
    exit 1
}

printf '%s\n' "$live" | ssh -o BatchMode=yes "$HOST" "
    set -euo pipefail
    cat >/tmp/ci-cache-live.\$\$
    cd '$ROOT' || exit 1
    n=0; total=0
    for d in target-*; do
        [ -d \"\$d\" ] || continue
        # Strip the lane prefix and the trailing dash that echo's newline
        # leaves behind in the pipeline's own tr expression.
        b=\$(printf '%s' \"\$d\" | sed -E 's/^target-(b-|c-|msrv-|fuzz-)?//; s/-\$//')
        grep -qxF \"\$b\" /tmp/ci-cache-live.\$\$ && continue

        # A build still holds this directory: the branch was deleted while
        # its last pipeline was running. The kernel frees the lock when
        # that build ends, so the next run collects it.
        busy=0
        for lock in \"\$d\"/*/.cargo-build-lock; do
            [ -f \"\$lock\" ] || continue
            flock -n \"\$lock\" true 2>/dev/null || busy=1
        done
        [ \$busy = 1 ] && { echo \"busy  \$d\"; continue; }

        sz=\$(du -sb \"\$d\" 2>/dev/null | cut -f1); sz=\${sz:-0}
        total=\$((total+sz)); n=\$((n+1))
        printf '%8s  %s\n' \"\$(numfmt --to=iec \$sz)\" \"\$d\"
        # CI writes as root inside its containers, so the artifacts are
        # root-owned. sudo is NOPASSWD for this account on the CI host.
        # The path is re-derived absolutely and re-checked rather than
        # interpolated, so a surprising \$d cannot escape the cache root.
        if [ '$FORCE' = 1 ]; then
            case \"\$d\" in
            target-*) sudo -n rm -rf -- \"$ROOT/\$d\" ;;
            *) echo \"refusing: \$d\" >&2 ;;
            esac
        fi
    done
    rm -f /tmp/ci-cache-live.\$\$
    echo
    if [ \$n -eq 0 ]; then echo 'no dead branch caches.'
    elif [ '$FORCE' = 1 ]; then echo \"reaped \$n directories, \$(numfmt --to=iec \$total).\"
    else echo \"\$n directories, \$(numfmt --to=iec \$total) — pass --force to reap.\"; fi
    df -h '$ROOT' | tail -1
"
