#!/usr/bin/env bash
# Kill test-runner process trees that have outrun any plausible test time.
#
# Liveness is asked of the kernel's own elapsed-time accounting, never of
# which tool started the process. cargo-nextest bounds a single test at
# 120s via .config/nextest.toml's slow-timeout, but a bare `cargo test`
# (workers bypass nextest routinely) has no such net and a hung test can
# spin for hours, sharing this 32-core box with everyone else's builds.
# Full local suites finish in well under 5 minutes even cold; a threshold
# of 20 gives headroom without protecting a real hang.
#
# Usage:
#   hung-test-reap.sh            # what would die
#   hung-test-reap.sh --force    # kill it

set -euo pipefail

THRESHOLD_MIN=${HUNG_TEST_REAP_MINUTES:-20}
FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

# etime is [[DD-]HH:]MM:SS; convert to minutes. Targets bare `cargo test`
# only — cargo-nextest already bounds each test at 120s via
# .config/nextest.toml's slow-timeout, so a hung *nextest* run is nextest's
# own job to kill, and reaping it here would just collateral-damage a
# legitimate suite that is merely slow under host contention. It is the
# unsupervised bare-`cargo test` driver, and the test binaries it spawns
# directly, that have no such net.
pgrep -f '(^|/)cargo test( |$)' |
    while read -r pid; do
        ps -o pid=,etime=,cmd= -p "$pid" 2>/dev/null
    done |
    grep -v 'cargo-nextest' |
    awk '{print $1, $2, substr($0, index($0,$3))}' |
    while read -r pid etime rest; do
        mins=0
        if [[ $etime =~ ^([0-9]+)-([0-9]+):([0-9]+):([0-9]+)$ ]]; then
            mins=$((BASH_REMATCH[1] * 1440 + BASH_REMATCH[2] * 60 + BASH_REMATCH[3]))
        elif [[ $etime =~ ^([0-9]+):([0-9]+):([0-9]+)$ ]]; then
            mins=$((BASH_REMATCH[1] * 60 + BASH_REMATCH[2]))
        elif [[ $etime =~ ^([0-9]+):([0-9]+)$ ]]; then
            mins=${BASH_REMATCH[1]}
        fi
        if [ "$mins" -ge "$THRESHOLD_MIN" ]; then
            if [ "$FORCE" = 1 ]; then
                echo "kill pid=$pid etime=$etime $rest"
                pkill -TERM -P "$pid" 2>/dev/null || true
                kill -TERM "$pid" 2>/dev/null || true
            else
                echo "would kill pid=$pid etime=$etime $rest"
            fi
        fi
    done
