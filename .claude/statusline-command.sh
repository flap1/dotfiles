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

# model
model=$(echo "$input" | jq -r '.model.display_name // empty')

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

# 5h rate limit
rate_5h=""
resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
pct_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$resets_at" ]; then
  now=$(date +%s)
  diff=$((resets_at - now))
  pct_5h_int=""
  [ -n "$pct_5h" ] && pct_5h_int=$(printf "%.0f" "$pct_5h")
  if [ "$diff" -gt 0 ]; then
    rate_5h="5h:${pct_5h_int}%($(( diff / 3600 ))h$(( (diff % 3600) / 60 ))m)"
  else
    rate_5h="5h:limit!"
  fi
fi

# 7d rate limit
rate_7d=""
resets_at_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
pct_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$resets_at_7d" ]; then
  now=$(date +%s)
  diff7=$((resets_at_7d - now))
  pct_7d_int=""
  [ -n "$pct_7d" ] && pct_7d_int=$(printf "%.0f" "$pct_7d")
  if [ "$diff7" -gt 0 ]; then
    days=$(( diff7 / 86400 ))
    hours=$(( (diff7 % 86400) / 3600 ))
    rate_7d="7d:${pct_7d_int}%(${days}d${hours}h)"
  else
    rate_7d="7d:limit!"
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
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  ctx_c="$S"
  [ "$used_int" -ge 70 ] && ctx_c="$A"
  [ "$used_int" -ge 90 ] && ctx_c="$R"
  # The steps are not evenly spaced: they are placed so the glyph changes at
  # exactly the same points the colour does, at 70 and at 90. An even split put
  # 89 and 90 both on ▇, so at the one boundary that matters the shape said
  # nothing and the redundancy was lost precisely where it was needed.
  if   [ "$used_int" -ge 90 ]; then ctx_bar="█"
  elif [ "$used_int" -ge 80 ]; then ctx_bar="▇"
  elif [ "$used_int" -ge 70 ]; then ctx_bar="▆"
  elif [ "$used_int" -ge 56 ]; then ctx_bar="▅"
  elif [ "$used_int" -ge 42 ]; then ctx_bar="▄"
  elif [ "$used_int" -ge 28 ]; then ctx_bar="▃"
  elif [ "$used_int" -ge 14 ]; then ctx_bar="▂"
  else                              ctx_bar="▁"
  fi
  out="${out} ${ctx_c}${ctx_bar}${used_int}%ctx${X}"
fi

if [ -n "$rate_5h" ]; then
  case "$rate_5h" in *limit!*) out="${out} ${R}${rate_5h}${X}" ;; *) out="${out} ${S}${rate_5h}${X}" ;; esac
fi

printf '%b' "$out"
