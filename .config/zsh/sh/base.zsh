## =========================================================================
## Base Configuration
## =========================================================================

HOSTNAME="$HOST"
HISTFILE="${ZDATADIR}/zsh_history" # history file
HISTSIZE=10000                    # lines kept in memory
SAVEHIST=100000                   # lines kept on disk
HISTORY_IGNORE="(ls|cd|pwd|zsh|exit|cd ..)"
LISTMAX=1000                      # ask before listing this many (1 = never ask, 0 = ask when it overflows)
KEYTIMEOUT=1

# C-w deletes one path segment at a time:
# default  : ls /usr/local → ls /usr/ → ls /usr → ls /
#   ls /usr/local/etc -> ls /usr/local -> ls /usr
WORDCHARS='*?_-[]~&;!#$%^(){}<>|'

# where cd looks when the current directory has no such subdirectory
cdpath=("$HOME" .. $HOME/*)

# define in post execution. because compinit is slow and plugin manager automatic load compinit.
# autoload -Uz compinit && compinit -u
# autoload -Uz is-at-least
