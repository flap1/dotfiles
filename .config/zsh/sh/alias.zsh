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

# MCP neovim-server: always expose a socket so Claude Code can connect
function nvim() { command nvim --listen /tmp/nvim "$@"; }

# git
alias lg='lazygit'
alias ga='git add -A'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gpo='git push -u origin HEAD'
alias glom='git pull origin main'
alias gloms='git pull origin main && git submodule update --init --recursive'
alias gll='git log --oneline --graph --decorate -n 10'

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
