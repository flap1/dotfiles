#!/bin/sh
# One fork per status refresh, printing "<cpu>% <mem>%".
#
# CPU needs a delta between two /proc/stat samples, so the previous sample is
# cached next to the socket rather than sleeping inside the status bar. The
# first call after boot has nothing to diff against and prints --.
#
# Memory deliberately uses MemAvailable, not "free -g" used: the latter counts
# page cache, which reported 120GB on an idle machine.
cache="${TMPDIR:-/tmp}/.tmux-cpu-sample.$(id -u)"

read -r _ u n s i rest < /proc/stat
busy=$((u + n + s))
total=$((busy + i))

cpu="--"
if [ -r "$cache" ]; then
  read -r pbusy ptotal < "$cache" 2>/dev/null || true
  if [ -n "$ptotal" ] && [ "$total" -gt "$ptotal" ]; then
    cpu=$(( (busy - pbusy) * 100 / (total - ptotal) ))
  fi
fi
printf '%s %s\n' "$busy" "$total" > "$cache"

# MemTotal/MemFree/MemAvailable are the first three lines, so this stays inside
# the shell instead of forking awk, which was most of the runtime.
{
  read -r _ memtotal _
  read -r _ _ _
  read -r _ memavail _
} < /proc/meminfo
mem=$(( (memtotal - memavail) * 100 / memtotal ))

# Labels, not icons: the Nerd Font CPU and RAM glyphs are both a chip outline,
# so at status-bar size they were indistinguishable. Two letters carry the
# distinction that the pictures could not, and drop the font dependency.
printf 'CPU %s%%  MEM %s%%' "$cpu" "$mem"
