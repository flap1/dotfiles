HOSTNAME="$HOST"
HISTFILE="${ZDATADIR}/zsh_history"
HISTSIZE=10000
SAVEHIST=100000
HISTORY_IGNORE="(ls|cd|pwd|zsh|exit|cd ..)"
LISTMAX=1000
KEYTIMEOUT=1

WORDCHARS='*?_-[]~&;!#$%^(){}<>|'

# $HOME/* is not listed: a large home makes every `cd foo` walk every child.
cdpath=("$HOME" ..)
