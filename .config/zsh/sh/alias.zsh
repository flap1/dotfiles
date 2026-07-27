## =========================================================================
## Alias
## =========================================================================

# common
alias rm='trash put'
alias del='command rm -rf'
alias cp='cp -ivr'
alias mv='mv -i'
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias rez='exec zsh'
alias cl='clear'
alias quit='exit'
alias fd='fd -E gdrive'
alias diff='delta'
alias mkdir='mkdir -p'
alias cat='bat'
alias less='bat'
alias ls='eza --group-directories-first'
alias la='eza -A --group-directories-first'
alias l='eza -Ahl --total-size --group-directories-first'
alias ll='eza -Ahl --total-size --group-directories-first'
alias lt='eza -Ahl --total-size --tree --group-directories-first'
alias l.='eza -A -d .[a-zA-Z]*'
alias tree='eza -A --tree --group-directories-first'
alias du="dust"
alias df="duf"
alias su="su -l"
alias ps='procs --tree'
alias top='btm'

# history
alias history-mem='fc -rl'
alias history-import='fc -RI'

# gnome restart
alias gnome-restart="killall -3 gnome-shell"

# chmod
alias 644='chmod 644'
alias 755='chmod 755'
alias 777='chmod 777'

# grep
# alias grep='rg -S'
alias gre='grep -H -n -I --color=auto' #  ファイル名表示, 行数表示, バイナリファイルは処理しない

# vi/vim
alias vi="$EDITOR"
alias vim="$EDITOR"
alias sv="sudo $EDITOR"

# ── tailnet exposure ──────────────────────────────────────────────────
# This box is on a tailnet, so any port bound to its tailscale address is
# reachable from any tailnet device as http://<this-host>:PORT with no
# per-port configuration, forever. That is the whole point: prefer binding
# the server correctly over forwarding ports one at a time.
#
# TSIP is that address. Start dev servers on it:
#   vite --host $TSIP        next dev -H $TSIP        python3 -m http.server -b $TSIP
# Binding 0.0.0.0 also works but additionally exposes the service to the LAN.
export TSIP="$(tailscale ip -4 2>/dev/null)"

# tsx PORT — expose an already-running 127.0.0.1 service on the tailnet
# without restarting it. For the case where you forgot the --host flag.
# Runs in the foreground; Ctrl-C to stop.
tsx() {
  [ -z "$1" ] && { echo "usage: tsx PORT [LOCAL_PORT]" >&2; return 1; }
  local ts_port="$1" local_port="${2:-$1}"
  echo "http://$(hostname -s):${ts_port}  ->  127.0.0.1:${local_port}   (Ctrl-C to stop)"
  socat "TCP-LISTEN:${ts_port},bind=${TSIP},fork,reuseaddr" "TCP:127.0.0.1:${local_port}"
}

# No nvim wrapper. It used to force `--listen /tmp/nvim` for an MCP
# neovim-server that no longer exists, and a fixed socket path means only one
# nvim can run at a time — the second one dies with "address already in use".
# That is fatal with parallel worktrees.
#
# nvim already listens without being asked: v:servername is
# $XDG_RUNTIME_DIR/nvim.<pid>.0, and child processes see it in $NVIM.
# If something ever needs a deterministic path again, key it per pane
# (e.g. --listen "$XDG_RUNTIME_DIR/nvim-${TMUX_PANE#%}"), never a global one.

# git
alias lg='lazygit'
alias ga='git add -A'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias glr='git pull --rebase origin develop'
alias gpo='git push -u origin HEAD'
alias glom='git pull origin main'
alias gloms='git pull origin main && git submodule update --init --recursive'
alias gll='git log --oneline --graph --decorate -n 10'
# pull.rebase=true + rebase.autoStash=true (global git config) 有効化済み
# -> 未コミット変更があっても checkout/pull で自動 stash/restore されるため
#    stash 手動操作(git stash && checkout && pull && stash apply)は不要
alias gcd='git checkout develop && git pull'
alias gcm='git checkout main && git pull'

# docker
alias lzd='lazydocker'
alias di="docker images"
alias dr="docker run --rm"
alias ds='docker stop $(docker ps -q)'
alias dcb="docker compose build"
alias dcu="docker compose up"
alias dcd="docker compose down"
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"'
alias drm="docker system prune"

# python
alias python='python3'
alias pip='pip3'

# c
JOBS=$[$(grep cpu.cores /proc/cpuinfo | sort -u | sed 's/[^0-9]//g') + 1]
alias make='make -j${JOBS}'


# -------------------------------------------------------------------------
# Global Alias
# -------------------------------------------------------------------------
alias -g L='| bat --style=plain'
alias -g T='| tail'
alias -g H='| head'
alias -g G='| rg -S' # fast ripgrep
alias -g A='| awk'
if [ "$WAYLAND_DISPLAY" != "" ]; then
	if builtin command -v wl-copy > /dev/null 2>&1; then
		alias -g C='| tee >(wl-copy)'
	fi
else
	if builtin command -v xsel > /dev/null 2>&1; then
		alias -g C='| tee >(xsel -i -b)'
	elif builtin command -v xclip > /dev/null 2>&1; then
		alias -g C='| tee >(xclip -i -selection clipboard)'
	elif builtin command -v pbcopy > /dev/null 2>&1; then
		alias -g C='| tee >(pbcopy)'
	fi
fi
alias -g X='| xargs'
alias -g W='| wc'
if [ "$WAYLAND_DISPLAY" != "" ]; then
	if builtin command -v wl-copy > /dev/null 2>&1; then
		alias -g Y='| wl-copy'
	fi
else
	if builtin command -v xsel > /dev/null 2>&1; then
		alias -g Y='| xsel -i -b'
	elif builtin command -v xclip > /dev/null 2>&1; then
		alias -g Y='| xclip -i -selection clipboard'
	fi
fi


# -------------------------------------------------------------------------
# Suffix
# -------------------------------------------------------------------------

alias -s {md,markdown,txt}="$EDITOR"
alias -s {html,gif,mp4}='x-www-browser'
alias -s py='python'
alias -s {jpg,jpeg,png,bmp}='feh'
alias -s mp3='mplayer'
function extract() {
	case $1 in
		*.tar.gz|*.tgz) tar xzvf "$1" ;;
		*.tar.xz) tar Jxvf "$1" ;;
		*.zip) unzip "$1" ;;
		*.lzh) lha e "$1" ;;
		*.tar.bz2|*.tbz) tar xjvf "$1" ;;
		*.tar.Z) tar zxvf "$1" ;;
		*.gz) gzip -d "$1" ;;
		*.bz2) bzip2 -dc "$1" ;;
		*.Z) uncompress "$1" ;;
		*.tar) tar xvf "$1" ;;
		*.arj) unarj "$1" ;;
	esac
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract


# -------------------------------------------------------------------------
# App
# -------------------------------------------------------------------------

# web-server
alias web-server='python3 -m http.server 8000'

# generate password
alias generate-passowrd='openssl rand -base64 20'

# translate
alias transj='trans ja:'
alias tj='trans ja:'
alias te='trans :ja'

# tealdeer (tldr)
alias help='tldr'

# http
alias http='xh'

# yazi - cd on quit
function yy() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
