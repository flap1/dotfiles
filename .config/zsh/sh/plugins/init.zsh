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
# ロード順序（同一 zinit for ブロック内では記述順に実行される）:
#   1. zsh-completions  blockf で fpath に正しく登録
#   2. enhancd          cd をフック & compdef _cd __enhancd::cd を発行
#   3. fzf-tab          compinit 後・autosuggestions 前が必須
#   4. fast-syntax-highlighting
#      atinit: zicompinit; zicdreplay
#        → 1-3 がロード済みの状態で compinit が走る
#        → enhancd の compdef もここでリプレイされる
#      atload: gh/uv completion を登録（compdef が使えるのでここで）
#   5. zsh-autosuggestions  atload で遅延起動
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
