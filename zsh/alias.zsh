# global alias
alias -g L='| less'
alias -g H='| head'
alias -g G='| grep'
alias -g GI='| grep -ri'

# basics
alias l='ls'
alias ls='ls -GXh --color=auto'
alias ll='ls -Alh --show-control-chars --color=auto'
alias lt='ls -tAlh --color=auto'
alias la='ls -CAh --color=auto'

alias du="du -Th"
alias df="df -Th"
alias su="su -l"
alias ps='ps --sort=start_time'

alias ..='cd ..'
alias mkdir="mkdir -p"

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

alias vim='nvim'
alias v='nvim'

# c
alias make='make -j16'

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

