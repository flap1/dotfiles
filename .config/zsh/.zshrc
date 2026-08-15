# Interactive shells. zsh reads this file itself, so it cannot be removed, and
# nothing under sh/ is discovered on its own -- hence the list.
#
# Order is load-bearing: completion.zsh must be configured before
# plugins/init.zsh runs compinit, and post_load.zsh uses the functions and
# aliases defined above it.
#
# Environment and PATH belong in .zshenv, not here. Installers append PATH
# lines to this file; every one so far was already covered by the path=()
# block in .zshenv, so the fix is to delete them, not to move them.

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

# Machine-local and gitignored. Secrets live here and nowhere tracked.
source-safe "$ZHOMEDIR/.zshrc.local"

[ -n "$ZSHRC_PROFILE" ] && zprof
