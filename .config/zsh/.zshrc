# Interactive shells. Order is load-bearing: completion styles before
# sheldon/compinit, functions and aliases before post_load.

[ -n "$ZSHRC_PROFILE" ] && zmodload zsh/zprof

source-safe() { [ -f "$1" ] && source "$1" }

source "$ZSHDIR/base.zsh"
source "$ZSHDIR/mappings.zsh"
source "$ZSHDIR/options.zsh"
source "$ZSHDIR/completion.zsh"
source "$ZSHDIR/function.zsh"
source "$ZSHDIR/alias.zsh"
source "$ZSHDIR/plugins/init.zsh"
source "$ZSHDIR/post_load.zsh"

source-safe "$ZHOMEDIR/.zshrc.local"

[ -n "$ZSHRC_PROFILE" ] && zprof
