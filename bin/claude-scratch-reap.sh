#!/usr/bin/env bash
# claude-scratch-reap: delete the scratch directories of Claude Code
# sessions that are over.
#
# Why this exists: Claude Code injects a system prompt telling every session
# to write ALL temporary files to /tmp/claude-<uid>/<project>/<session>/
# scratchpad. That directory is documented nowhere — not on any docs page,
# not in the changelog — and the only contract stated for it promises that
# it is session-specific and isolated. It never promises deletion, and
# `cleanupPeriodDays` cannot reach it: that sweep's documented domain is
# ~/.claude/ and the scratchpad lives under the system temp root. So this
# is not a bug against a contract, it is the absence of one. On this machine
# 161 dead sessions had left 119 GB there, cargo target directories
# included, while the disk hit 100% four times.
#
# Liveness comes from Claude Code's own registry, not from a clock and not
# from guessing. ~/.claude/sessions/<pid>.json holds {pid, sessionId,
# procStart, ...} for each running session; the docs say each file is
# removed when its session exits and that crash leftovers are cleared on the
# next launch. `procStart` is the process's start time from /proc, so a
# recycled pid cannot masquerade as a live session — which is the one hole a
# pid-only check would leave.
#
# A scratch directory survives iff its session id is in that registry and
# that session's process is still the one the registry named.
#
# Usage:
#   claude-scratch-reap.sh            # what would go
#   claude-scratch-reap.sh --force    # go
set -uo pipefail

FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

ROOT="${CLAUDE_SCRATCH_ROOT:-/tmp/claude-$(id -u)}"
REG="$HOME/.claude/sessions"
[ -d "$ROOT" ] || exit 0

# Session ids whose registered process is still running, and still the same
# process. Field 22 of /proc/<pid>/stat is starttime in clock ticks, which
# is what the registry records.
live=$(
    for f in "$REG"/*.json; do
        [ -f "$f" ] || continue
        read -r pid sid start < <(
            python3 - "$f" 2>/dev/null <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
    print(d.get("pid", ""), d.get("sessionId", ""), d.get("procStart", ""))
except Exception:
    pass
PY
        ) || continue
        if [ -z "${sid:-}" ] || [ -z "${pid:-}" ]; then
            continue
        fi
        [ -r "/proc/$pid/stat" ] || continue
        now=$(awk '{print $22}' "/proc/$pid/stat" 2>/dev/null)
        # An empty procStart in the registry means we cannot rule out pid
        # reuse; treat the session as live rather than risk deleting it.
        [ -z "$start" ] || [ "$start" = "$now" ] || continue
        printf '%s\n' "$sid"
    done | sort -u
)

# `grep -c` prints 0 and exits 1 on no match, so `|| echo 0` would append a
# second line and make every later integer test a syntax error — which is
# exactly how a guard against reaping everything ends up not guarding.
count=$(grep -c . <<<"$live") || count=0
printf 'live sessions: %s\n' "$count"

# Refuse to run blind. An empty registry on a machine that has scratch
# directories means the scan broke — an unreadable ~/.claude/sessions, a
# python3 that is not there, a changed file format — and every session would
# then look finished. Reaping on that reading is how a cleaner becomes the
# outage. A genuinely idle machine has nothing to reap either way.
if [ "$count" -eq 0 ] && [ -n "$(find "$ROOT" -mindepth 2 -maxdepth 2 -type d -print -quit 2>/dev/null)" ]; then
    echo "no live sessions found but scratch directories exist — refusing to reap." >&2
    exit 1
fi

total=0
n=0
for dir in "$ROOT"/*/*/; do
    dir=${dir%/}
    sid=$(basename "$dir")
    [[ $sid =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]] || continue
    grep -qxF "$sid" <<<"$live" && continue

    bytes=$(du -sB1 "$dir" 2>/dev/null | cut -f1) || continue
    total=$((total + ${bytes:-0}))
    n=$((n + 1))
    printf '%8s  %s\n' "$(numfmt --to=iec "${bytes:-0}")" "$dir"
    [ "$FORCE" = 1 ] && rm -rf -- "$dir"
done

# `~/.claude/jobs/<id>/` is the other half of the same leak: a `/batch` job
# keeps its working tree under `tmp/`, cargo target directories included,
# and appears in neither of the two tables the docs publish — not "cleaned
# up automatically", not "kept until you delete them". Measured 2026-08-15:
# 6.6 GB, of which two finished jobs held 4.4 GB.
#
# Only a job that reached a terminal state and whose session is gone is
# reaped. `blocked` is left alone because it may be resumable, and a job
# with no state.json is left alone because it is probably still starting.
JOBS="$HOME/.claude/jobs"
if [ -d "$JOBS" ]; then
    for dir in "$JOBS"/*/; do
        dir=${dir%/}
        [ -f "$dir/state.json" ] || continue
        read -r state sid < <(
            python3 - "$dir/state.json" <<'PY' 2>/dev/null || true
import json, sys
try:
    d = json.load(open(sys.argv[1]))
    print(d.get("state", "?"), d.get("sessionId", "-"))
except Exception:
    print("?", "-")
PY
        )
        case "$state" in
            done | failed | stopped) ;;
            *) continue ;;
        esac
        [ "$sid" != "-" ] && grep -qxF "$sid" <<<"$live" && continue

        bytes=$(du -sB1 "$dir" 2>/dev/null | cut -f1) || continue
        total=$((total + ${bytes:-0}))
        n=$((n + 1))
        printf '%8s  %s (%s)\n' "$(numfmt --to=iec "${bytes:-0}")" "$dir" "$state"
        [ "$FORCE" = 1 ] && rm -rf -- "$dir"
    done
fi

if [ "$n" -eq 0 ]; then
    echo "no finished sessions left anything behind."
elif [ "$FORCE" = 1 ]; then
    echo "reaped $n scratch directories, $(numfmt --to=iec "$total")."
else
    echo "$n scratch directories, $(numfmt --to=iec "$total") — pass --force to reap."
fi
