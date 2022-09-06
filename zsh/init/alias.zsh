# global alias
alias -g L='| less'
alias -g H='| head'
alias -g G='| grep'
alias -g GI='| grep -ri'

# basics
alias cat='bat'
alias ls='lsd'
alias l='ls -l'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
#alias l='ls'
#alias ls='ls -GXh --color=auto'
#alias ll='ls -Alh --show-control-chars --color=auto'
#alias lt='ls -tAlh --color=auto'
#alias la='ls -CAh --color=auto'

alias du="du -sh"
alias df="df -sh"
alias su="su -l"
alias ps='ps --sort=start_time'

alias ..='cd ..'
alias mkdir='mkdir -p'

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

alias vim='nvim'
alias v='nvim'

alias fd='fd -E gdrive'

# c
JOBS=$[$(grep cpu.cores /proc/cpuinfo | sort -u | sed 's/[^0-9]//g') + 1]
alias make='make -j${JOBS}'

# python
alias python='python3'
alias pip='pip3'

# git
alias ga='git add -A'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gpo='git push -u origin HEAD'
alias glom='git pull origin master'
alias gloms='git pull origin master && git submodule update --init --recursive'
alias gll='git log --oneline'

# docker
alias di="docker images"
alias dr="docker run --rm"
alias ds='docker stop $(docker ps -q)'
alias dcb="docker-compose build"
alias dcu="docker-compose up"
alias dcd="docker-compose down"
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"'
## 停止コンテナ、タグ無しイメージ、未使用ボリューム、未使用ネットワーク一括削除
alias drm="docker system prune"
