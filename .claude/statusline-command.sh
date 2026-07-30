#!/bin/sh
input=$(cat)

# The statusline payload is the only place the rate limits are exposed, and only
# a live session receives it. Leave the latest copy where claude-ls can read it.
printf '%s' "$input" |
  jq -c '{five_hour: .rate_limits.five_hour, seven_day: .rate_limits.seven_day}' \
  > "$HOME/.cache/claude-rate-limits.json" 2>/dev/null || true

# directory (truncate to last 5 segments, ~ for home)
# printf, not echo, everywhere $input is piped. Under Git Bash /bin/sh is bash
# in POSIX mode, where echo expands backslash escapes -- so a Windows path in
# the JSON reached jq with C:\Users turned into C:Users and \t turned into a
# tab, and jq then failed to parse it. bash on Linux does not do this, which is
# why it only ever broke on one platform.
cwd=$(printf "%s" "$input" | jq -r '.workspace.current_dir // .cwd // empty')
short_path=""
if [ -n "$cwd" ]; then
  # Windows reports current_dir as C:\Users\name\... -- backslashes, and a drive
  # letter. $HOME under Git Bash is /c/Users/name, so the prefix never matches
  # and every path renders in full. Normalise the separators, then compare
  # against both spellings of home: cygpath -m gives C:/Users/name, and on Linux
  # cygpath does not exist so this collapses back to $HOME alone.
  # '\134' rather than a literal backslash in the SET: GNU tr warns that an
  # unescaped trailing backslash is not portable, and the octal escape says the
  # same thing without depending on how the shell quoted it.
  cwd=$(printf '%s' "$cwd" | tr '\134' '/')
  home_win=$(cygpath -m "$HOME" 2>/dev/null) || home_win="$HOME"
  short_path="${cwd#$HOME}"
  [ "$short_path" = "$cwd" ] && short_path="${cwd#$home_win}"
  [ "$short_path" != "$cwd" ] && short_path="~$short_path"
  # awk, not rev | cut | rev. Git Bash ships no rev, so on Windows the old
  # idiom failed with "command not found" and left the path blank. It is also
  # one process instead of three, on a script that runs on every render.
  short_path=$(printf '%s' "$short_path" | awk -F/ '
    NF > 4 { printf "...%s/%s/%s", $(NF-2), $(NF-1), $NF; next }
            { printf "%s", $0 }')
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
model=$(printf "%s" "$input" | jq -r '.model.display_name // empty' | sed 's/ *(.*)//; s/ //g')

# reasoning effort, hung off the model as one token
#
# .effort.level is the live session value, so a mid-session /effort shows up
# here; it is absent entirely on models that take no effort parameter, and
# ultracode reports as xhigh rather than a level of its own. Two letters
# because it sits next to the model name and the first letter is ambiguous
# between low and… nothing, but "lo" and "hi" are not.
effort=$(printf "%s" "$input" | jq -r '.effort.level // empty')
case "$effort" in
  low)    effort=lo  ;;
  medium) effort=md  ;;
  high)   effort=hi  ;;
  xhigh)  effort=xh  ;;
  max)    effort=max ;;
  *)      effort=""  ;;
esac
[ -n "$model" ] && [ -n "$effort" ] && model="${model}·${effort}"

# which account is paying for this session
#
# Not in the payload -- Claude Code does not report it -- so it comes from
# ~/.claude.json, where the CLI keeps the login. Worth the extra read: with a
# personal Max account and a company Team account reachable from the same
# machine, which one a session is spending is otherwise invisible until /usage,
# and by then it has already spent it.
#
# Rendered as who@plan, both shortened. "@" because it reads as an address;
# "·" is already the model/effort qualifier. The local part of the address is enough
# to tell two accounts apart, and the tier is what actually differs between
# them: default_claude_max_20x -> max20x, and a Team seat falls back to the
# organisation type.
account=""
if [ -f "$HOME/.claude.json" ]; then
  account=$(jq -r '
    .oauthAccount // {} | . as $a
    | (($a.emailAddress // "") | split("@")[0]) as $who
    | (($a.organizationRateLimitTier // $a.organizationType // "")
        | sub("^default_claude_"; "") | sub("^claude_"; "") | sub("_"; "")) as $plan
    | if   $who == ""  then empty
      elif $plan == "" then $who
      else $who + "@" + $plan end
  ' "$HOME/.claude.json" 2>/dev/null)
fi

# context used %
used_pct=$(printf "%s" "$input" | jq -r '.context_window.used_percentage // empty')

# cost
cost_usd=$(printf "%s" "$input" | jq -r '.cost.total_cost_usd // empty')
cost_str=""
if [ -n "$cost_usd" ]; then
  cost_str=$(printf '$%.2f' "$cost_usd")
fi

# lines edited this session
lines_added=$(printf "%s" "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(printf "%s" "$input" | jq -r '.cost.total_lines_removed // 0')
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
resets_at=$(printf "%s" "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
pct_5h=$(printf "%s" "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
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
resets_at_7d=$(printf "%s" "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
pct_7d=$(printf "%s" "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
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
# Real escape characters, not the two-character string \033, so the line can be
# emitted with printf '%s' at the end. %b would expand backslashes in the data
# as well as in these constants, and a Windows path is full of them: C:\Users
# put \U through %b and killed the whole line with "missing unicode digit".
E=$(printf '\033')
G="${E}[38;2;5;150;105m"    # primary   #059669
A="${E}[38;2;245;158;11m"   # active    #f59e0b
R="${E}[38;2;239;68;68m"    # error, lifted #ef4444 — #dc2626 measures 3.70:1
                            # against #0f172a, under AA. Same lift as nvim/lazygit.
M="${E}[38;2;148;163;184m"  # muted     #94a3b8
S="${E}[38;2;100;116;139m"  # subtle    #64748b
X="${E}[0m"

out=""
[ -n "$short_path" ] && out="${out}${G}${short_path}${X}"

if [ -n "$git_part" ]; then
  branch_name=$(printf '%s' "$git_part" | cut -d' ' -f1)
  st_part=$(printf '%s' "$git_part" | cut -d' ' -f2-)
  out="${out} ${M} ${branch_name}${X}"
  [ "$branch_name" != "$st_part" ] && out="${out} ${A}${st_part}${X}"
fi

[ -n "$model" ] && out="${out} ${S}${model}${X}"
[ -n "$account" ] && out="${out} ${S}${account}${X}"

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
  printf ' %s%s%s%s%s' "$_c" "$1" "$_b" "$3" "$X"
}

[ -n "$used_pct" ] && out="${out}$(gauge ctx "$(printf "%.0f" "$used_pct")" "$(printf "%.0f" "$used_pct")%")"
[ -n "$pct_5h_int" ] && out="${out}$(gauge 5h "$pct_5h_int" "$rate_5h")"
[ -n "$pct_7d_int" ] && out="${out}$(gauge 7d "$pct_7d_int" "$rate_7d")"

# %s, not %b. $out carries data -- a Windows path, a branch name -- and %b would
# treat any backslash in it as an escape: C:\Users\flap1 came out C:Users\flap1
# with the \f rendered as a form feed. The colours are real ESC bytes now, so
# nothing here needs expanding.
printf '%s' "$out"
