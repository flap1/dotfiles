#!/bin/sh
# One fork per status refresh, printing "<cpu>% <mem>%" plus, when any Claude
# session is waiting on the human, "ASK n" / "WAIT n".
#
# CPU needs a delta between two /proc/stat samples, so the previous sample is
# cached next to the socket rather than sleeping inside the status bar. The
# first call after boot has nothing to diff against and prints --.
#
# Memory deliberately uses MemAvailable, not "free -g" used: the latter counts
# page cache, which reported 120GB on an idle machine.
cache="${TMPDIR:-/tmp}/.tmux-cpu-sample.$(id -u)"

read -r _ u n s i rest </proc/stat
busy=$((u + n + s))
total=$((busy + i))

cpu="--"
if [ -r "$cache" ]; then
    read -r pbusy ptotal <"$cache" 2>/dev/null || true
    if [ -n "$ptotal" ] && [ "$total" -gt "$ptotal" ]; then
        cpu=$(((busy - pbusy) * 100 / (total - ptotal)))
    fi
fi
printf '%s %s\n' "$busy" "$total" >"$cache"

# MemTotal/MemFree/MemAvailable are the first three lines, so this stays inside
# the shell instead of forking awk, which was most of the runtime.
{
    read -r _ memtotal _
    read -r _ _ _
    read -r _ memavail _
} </proc/meminfo
mem=$(((memtotal - memavail) * 100 / memtotal))

# Labels, not icons: the Nerd Font CPU and RAM glyphs are both a chip outline,
# so at status-bar size they were indistinguishable. Two letters carry the
# distinction that the pictures could not, and drop the font dependency.
printf 'CPU %s%%  MEM %s%%' "$cpu" "$mem"

# -- Claude sessions that want something -----------------------------------
#
# Only ASK? and WAIT? are shown: busy and done are answered by prefix+a when
# you think to ask, and a number that is always on the bar stops being read.
# Nothing is printed when nothing is waiting, so the bar is quiet by default.
#
# `claude-ls --counts` costs ~0.45s (a jq digest per transcript), far too much to
# run inside a status refresh, so the counts come from a cache file and this
# script only kicks a refresh when the cache has aged past the status interval.
# The refresh is detached with its output closed: tmux reads #() until EOF, and
# a background child holding the pipe open would stall the whole bar.
attn="${TMPDIR:-/tmp}/.tmux-claude-attn.$(id -u)"
attn_max_age=15

[ -r "$attn" ] && cat "$attn"

now=$(date +%s)
mtime=$(stat -c %Y "$attn" 2>/dev/null || echo 0)
if [ $((now - mtime)) -ge "$attn_max_age" ]; then
    # Claim the slot before forking, or every attached client kicks its own
    # refresh during the ~0.45s the first one is still running.
    touch "$attn" 2>/dev/null
    {
        "$HOME/bin/claude-ls" --counts 2>/dev/null |
            awk '
        $1 == "ASK?"  { a = $2 }
        $1 == "WAIT?" { w = $2 }
        END { if (a) printf "  #[fg=#facc15,bold]ASK %d#[default]", a
              if (w) printf "  #[fg=#e879f9]WAIT %d#[default]", w }' \
                >"$attn.new" && mv "$attn.new" "$attn"
    } >/dev/null 2>&1 &
fi
