## =========================================================================
## Completion
## =========================================================================

setopt prompt_subst          # let escape sequences through the prompt

# see http://zsh.sourceforge.net/Doc/Release/Completion-System.html

# :completion:function:completer:command:argument:tag

# show the description alongside each option
zstyle ':completion:*' verbose yes
# Completers, tried in this order.
## _oldlist     reuse the previous result
## _complete    the ordinary completer
## _ignored     include what was excluded, once nothing else matches
## _match       complete through globs
## _prefix      complete up to the cursor, ignoring the rest
## _approximate allow near misses
## _expand      expand globs and variables, with finer control than the shell's own
## _history     complete from history; used by _history_complete_word
## _correct     fix the spelling, then complete
zstyle ':completion:*' completer _oldlist _complete _ignored
zstyle ':completion:*:messages' format '%F{yellow}%d'
zstyle ':completion:*:warnings' format '%B%F{red}No matches for:''%F{white}%d%b'
zstyle ':completion:*:descriptions' format '%B%F{white}--- %d ---%f%b'
zstyle ':completion:*:corrections' format ' %F{green}%d (errors: %e) %f'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' keep-prefix
zstyle ':completion:*' recent-dirs-insert both
# colour the candidates, reusing the GNU ls definitions
zstyle ':completion:*' list-colors "${LS_COLORS}"
zstyle ':completion:*' special-dirs true
# case-insensitive, except that a typed capital stays a capital
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
# some completions are slow to expand: apt-get, dpkg, rpm, urpmi, perl -M,
# bogofilter, fink, mac_apps
zstyle ':completion:*' use-cache true
# pick candidates with the arrow keys
# zstyle show completion menu if 1 or more items to select
zstyle ':completion:*:default' menu select=1
# fall back to cdpath only when the current directory offers nothing
zstyle ':completion:*:cd:*' tag-order local-directories path-directories
# order of the candidate list
zstyle ':completion:*:cd:*' group-order local-directories path-directories
# complete ps
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'
# complete sudo
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
# complete array subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
# group man completions by section
zstyle ':completion:*:manuals' separate-sections true
# newest first
zstyle ':completion:*' file-sort 'modification'

# make completion is slow
zstyle ':completion:*:make:*:targets' call-command true
zstyle ':completion:*:make::' tag-order targets:
zstyle ':completion:*:*:*make:*:targets' command awk \''/^[a-zA-Z0-9][^\/\t=]+:/ {print $1}'\' \$file
#zstyle ':completion:*:*:make:*:targets' ignored-patterns '*.o'
#zstyle ':completion:*:*:*make:*:*' tag-order '!targets !functions !file-patterns'
#zstyle ':completion:*:*:*make:*:*' avoid-completer '_files'

