## =========================================================================
## Setup Plugins
## =========================================================================

# -------------------------------------------------------------------------
# Setup Zinit
# -------------------------------------------------------------------------
if [ -z "$ZPLG_HOME" ]; then
    ZPLG_HOME="$ZDATADIR/zinit"
fi

if ! test -d "$ZPLG_HOME"; then
    mkdir -p "$ZPLG_HOME"
    chmod g-rwX "$ZPLG_HOME"
    git clone --depth 10 https://github.com/zdharma-continuum/zinit.git "${ZPLG_HOME}/bin"
fi

typeset -gAH ZPLGM
ZPLGM[HOME_DIR]="${ZPLG_HOME}"
source "$ZPLG_HOME/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# -------------------------------------------------------------------------
# Zinit Extensions
# -------------------------------------------------------------------------
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-readurl \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# -------------------------------------------------------------------------
# Core Plugins (Turbo mode)
#
# Load order (within one `zinit for` block, the written order is the run order):
#   1. zsh-completions  blockf registers it in fpath correctly
#   2. enhancd          hooks cd and issues compdef _cd __enhancd::cd
#   3. fzf-tab          must come after compinit and before autosuggestions
#   4. fast-syntax-highlighting
#      atinit: zicompinit; zicdreplay
#        compinit runs with 1-3 already loaded, and enhancd's compdef replays
#      atload: register the gh and uv completions, where compdef is available
#   5. zsh-autosuggestions  started late from atload
# -------------------------------------------------------------------------
zinit wait lucid light-mode for \
    blockf \
        zsh-users/zsh-completions \
    b4b4r07/enhancd \
    Aloxaf/fzf-tab \
    atinit"zicompinit; zicdreplay" \
    atload"
        command -v gh  > /dev/null && eval \"\$(gh completion -s zsh)\"
        command -v uv  > /dev/null && eval \"\$(uv generate-shell-completion zsh 2>/dev/null)\"
    " \
        zdharma-continuum/fast-syntax-highlighting \
    atload"!_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    chrissicool/zsh-256color

# -------------------------------------------------------------------------
# Utility Plugins
# -------------------------------------------------------------------------
zinit wait lucid light-mode for \
    MichaelAquilina/zsh-you-should-use \
    hlissner/zsh-autopair \
    zdharma-continuum/history-search-multi-word

# -------------------------------------------------------------------------
# fzf
# -------------------------------------------------------------------------
zinit ice wait'0b' lucid \
    from"gh-r" as"program" \
    atload"source $ZHOMEDIR/sh/plugins/config/fzf_atload.zsh"
zinit light junegunn/fzf

# -------------------------------------------------------------------------
# Translation
# -------------------------------------------------------------------------
zinit ice wait'1' lucid
zinit light soimort/translate-shell
