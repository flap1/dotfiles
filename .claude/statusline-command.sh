#!/bin/sh
input=$(cat)

# The statusline payload is the only place the rate limits are exposed, and only
# a live session receives it. Leave the latest copy where claude-ls can read it.
printf '%s' "$input" |
  jq -c '{five_hour: .rate_limits.five_hour, seven_day: .rate_limits.seven_day}' \
  > "$HOME/.cache/claude-rate-limits.json" 2>/dev/null || true

# directory (truncate to last 5 segments, ~ for home)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
short_path=""
if [ -n "$cwd" ]; then
  short_path="${cwd#$HOME}"
  [ "$short_path" != "$cwd" ] && short_path="~$short_path"
  seg_count=$(printf '%s' "$short_path" | tr -cd '/' | wc -c)
  if [ "$seg_count" -gt 3 ]; then
    short_path=$(printf '%s' "$short_path" | rev | cut -d'/' -f1-3 | rev)
    short_path="...$short_path"
  fi
fi

# git branch & status
git_part=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    modified=$(git -C "$cwd" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    untracked=$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    staged=$(git -C "$cwd" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    ahead=$(git -C "$cwd" rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
    behind=$(git -C "$cwd" rev-list --count HEAD..@{u} 2>/dev/null || echo 0)

    st=""
    [ "$staged" -gt 0 ]    && st="${st}+${staged}"
    [ "$modified" -gt 0 ]  && st="${st}!${modified}"
    [ "$untracked" -gt 0 ] && st="${st}?${untracked}"
    if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
      st="${st}⇕⇡${ahead}⇣${behind}"
    elif [ "$ahead" -gt 0 ]; then
      st="${st}⇡${ahead}"
    elif [ "$behind" -gt 0 ]; then
      st="${st}⇣${behind}"
    fi

    [ -n "$st" ] && git_part="$branch $st" || git_part="$branch"
  fi
fi

# model, shortened.
#
# display_name is "Opus 5 (1M context)" for opus[1m]: 19 columns for something
# that changes maybe twice a day. The parenthetical goes because the window
# size is already visible as the ctx meter -- a 1M session simply sits at a
# lower percentage. Dropping the space keeps it one token to the eye.
#   "Opus 5 (1M context)" -> Opus5    "Haiku 4.5" -> Haiku4.5    "Opus" -> Opus
model=$(echo "$input" | jq -r '.model.display_name // empty' | sed 's/ *(.*)//; s/ //g')

# context used %
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# cost
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
cost_str=""
if [ -n "$cost_usd" ]; then
  cost_str=$(printf '$%.2f' "$cost_usd")
fi

# lines edited this session
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
lines_str=""
if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
  lines_str="+${lines_added}/-${lines_removed}L"
fi

# Rate limit windows.
#
# Only five_hour and seven_day exist in this payload. There is no per-model
# window, so the Fable weekly allowance cannot be shown here; /usage is the
# only place it is broken out.

# Time left, as the two largest units that are actually non-zero. A window is
# only ever interesting at the resolution it is about to expire at: "2d" is
# enough a week out, but on the last day the hours are the whole question, and
# in the last hour so are the minutes. Both windows share this so the weekly
# one degrades to hours and then minutes on its own, with nothing to remember.
fmt_left() { # $1 = seconds remaining
  _s=$1
  _d=$(( _s / 86400 )); _h=$(( (_s % 86400) / 3600 )); _m=$(( (_s % 3600) / 60 ))
  if   [ "$_d" -gt 0 ]; then printf '%dd%dh' "$_d" "$_h"
  elif [ "$_h" -gt 0 ]; then printf '%dh%dm' "$_h" "$_m"
  elif [ "$_m" -gt 0 ]; then printf '%dm' "$_m"
  else                       printf 'now'
  fi
}

rate_5h=""
resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
pct_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
pct_5h_int=""
if [ -n "$resets_at" ]; then
  now=$(date +%s)
  diff=$((resets_at - now))
  [ -n "$pct_5h" ] && pct_5h_int=$(printf "%.0f" "$pct_5h")
  if [ "$diff" -gt 0 ]; then
    rate_5h="${pct_5h_int}%($(fmt_left "$diff"))"
  else
    rate_5h="limit!"; pct_5h_int=100
  fi
fi

rate_7d=""
resets_at_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
pct_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
pct_7d_int=""
if [ -n "$resets_at_7d" ]; then
  now=$(date +%s)
  diff7=$((resets_at_7d - now))
  [ -n "$pct_7d" ] && pct_7d_int=$(printf "%.0f" "$pct_7d")
  if [ "$diff7" -gt 0 ]; then
    rate_7d="${pct_7d_int}%($(fmt_left "$diff7"))"
  else
    rate_7d="limit!"; pct_7d_int=100
  fi
fi

# assemble
#
# Three levels only, matching the tmux status bar:
#   green  = where you are now (the one thing you are looking at)
#   amber  = wants attention
#   slate  = context, read only when you go looking for it
# Colouring every segment differently, as this did before, means none of them
# reads as more important than the others.
#
# Claude Code prints its permission-mode hint on its own line underneath and
# gives no way to suppress it (anthropics/claude-code#53268, #56956), and the
# mode is not in this script's input either. That line is a fixed cost, so this
# one stays short enough not to wrap and add a third. Cost, lines changed and
# the 7d window were dropped for that reason; /cost still reports them.
G='\033[38;2;5;150;105m'    # primary   #059669
A='\033[38;2;245;158;11m'   # active    #f59e0b
R='\033[38;2;239;68;68m'    # error, lifted #ef4444 — #dc2626 measures 3.70:1
                            # against #0f172a, under AA. Same lift as nvim/lazygit.
M='\033[38;2;148;163;184m'  # muted     #94a3b8
S='\033[38;2;100;116;139m'  # subtle    #64748b
X='\033[0m'

out=""
[ -n "$short_path" ] && out="${out}${G}${short_path}${X}"

if [ -n "$git_part" ]; then
  branch_name=$(printf '%s' "$git_part" | cut -d' ' -f1)
  st_part=$(printf '%s' "$git_part" | cut -d' ' -f2-)
  out="${out} ${M} ${branch_name}${X}"
  [ "$branch_name" != "$st_part" ] && out="${out} ${A}${st_part}${X}"
fi

[ -n "$model" ] && out="${out} ${S}${model}${X}"

# The number is always shown; the colour only changes once it is worth acting on.
#
# The block glyph carries the same signal as the colour, in shape. Colour alone
# is the standard failure here: roughly 8% of men have some colour blindness and
# most of it is red-green, which is exactly the amber-to-red step below. It also
# survives a monochrome terminal, a screenshot, and being seen out of the corner
# of an eye, where a hue change registers late and a rising bar does not.
#
# Thresholds stay at 70/90 rather than the more common 50/75. A bar that starts
# shouting at half full is one you stop reading, and nothing useful happens at
# 50% anyway: 70 is roughly where it is worth deciding whether to /clear, and 90
# is where compaction is imminent.
# One gauge renderer for all three meters. They answer the same question --
# how much of a budget is gone -- so they get the same encoding; three
# hand-rolled if-chains would be three chances to drift apart.
#
# The block glyph is not evenly spaced. Its steps sit exactly where the colour
# steps, at 70 and 90, so the shape changes at the one boundary that matters.
# An even eighth-split put 89 and 90 both on ▇ and said nothing there.
gauge() { # $1 = label, $2 = integer percent, $3 = text after the number
  _p=$2
  if   [ "$_p" -ge 90 ]; then _c="$R"; _b="█"
  elif [ "$_p" -ge 80 ]; then _c="$A"; _b="▇"
  elif [ "$_p" -ge 70 ]; then _c="$A"; _b="▆"
  elif [ "$_p" -ge 56 ]; then _c="$S"; _b="▅"
  elif [ "$_p" -ge 42 ]; then _c="$S"; _b="▄"
  elif [ "$_p" -ge 28 ]; then _c="$S"; _b="▃"
  elif [ "$_p" -ge 14 ]; then _c="$S"; _b="▂"
  else                        _c="$S"; _b="▁"
  fi
  printf ' %b%s%s%s%b' "$_c" "$1" "$_b" "$3" "$X"
}

[ -n "$used_pct" ] && out="${out}$(gauge ctx "$(printf "%.0f" "$used_pct")" "$(printf "%.0f" "$used_pct")%")"
[ -n "$pct_5h_int" ] && out="${out}$(gauge 5h "$pct_5h_int" "$rate_5h")"
[ -n "$pct_7d_int" ] && out="${out}$(gauge 7d "$pct_7d_int" "$rate_7d")"

printf '%b' "$out"
