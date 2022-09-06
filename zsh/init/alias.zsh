# global alias
alias -g L='| bat --style=plain'
alias -g H='| head'
alias -g G='| rg -S'
alias -g A='| awk'
alias -g C='| tee >(pbcopy)'
alias -g X='| xargs'

# basics
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias mkdir='mkdir -p'
alias cat='bat'
alias less='bat'
alias ls='lsd -A --group-dirs=last'
alias l='lsd -Ahl --total-size --group-dirs=last'
alias ll='lsd -Ahl --total-size --group-dirs=last'
alias lt='lsd -Ahl --total-size --tree --group-dirs=last'
alias tree='lsd -A --tree --group-dirs=last'
alias du="dust" # alias du="du -sh"
alias df="df -h"
alias su="su -l"
alias ps='procs --tree'
alias grep='rg -S'
alias find='fd'
alias fd='fd -E gdrive'
alias diff='delta'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias vim='nvim'
alias v='nvim'

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
alias glom='git pull origin main'
alias gloms='git pull origin main && git submodule update --init --recursive'
alias gll='git log --oneline'

# docker
alias di="docker images"
alias dr="docker run --rm"
alias ds='docker stop $(docker ps -q)'
alias dcb="docker-compose build"
alias dcu="docker-compose up"
alias dcd="docker-compose down"
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"'
alias drm="docker system prune"
