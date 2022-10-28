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
	git clone --depth 10 https://github.com/zdharma-continuum/zinit.git ${ZPLG_HOME}/bin
fi

if [[ -r "${ZCACHEDIR}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${ZCACHEDIR}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -gAH ZPLGM
ZPLGM[HOME_DIR]="${ZPLG_HOME}"
source "$ZPLG_HOME/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# -------------------------------------------------------------------------
# Zinit Extension
# -------------------------------------------------------------------------
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-readurl \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# -------------------------------------------------------------------------
# Basic Plugins
# -------------------------------------------------------------------------
zinit ice wait lucid # waitで遅延ロードし、lucidでロードした時にコンソールに情報が出力されるのを省略
zinit light zsh-users/zsh-completions # 補完
zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions # 補完
zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting
zinit ice wait lucid
zinit light zdharma/fast-syntax-highlighting # コマンドに色を付けて強調
zinit ice wait lucid
zinit light chrissicool/zsh-256color
zinit ice wait lucid
zinit light b4b4r07/enhancd
zinit ice depth=1 atload"source $ZHOMEDIR/sh/plugins/config/powerlevel10k_atload.zsh"
zinit light romkatv/powerlevel10k 


#--------------------------------#
# completion
#--------------------------------#
# zinit wait'0b' lucid \
# 	atload"source $ZHOMEDIR/sh/plugins/config/zsh-autosuggestions_atload.zsh" \
# 	light-mode for @zsh-users/zsh-autosuggestions

# zinit wait'0a' lucid \
# 	atinit"source $ZHOMEDIR/sh/plugins/config/zsh-autocomplete_atinit.zsh" \
# 	atload"source $ZHOMEDIR/sh/plugins/config/zsh-autocomplete_atload.zsh" \
# 	light-mode for @marlonrichert/zsh-autocomplete

# -------------------------------------------------------------------------
# Prompt
# -------------------------------------------------------------------------
# zinit wait'0a' lucid \
# 	if"(( ${ZSH_VERSION%%.*} > 4.4))" \
# 	atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
# 	light-mode for @zdharma-continuum/fast-syntax-highlighting

# PROMPT="%~"$'\n'"> "
# zinit wait'!0b' lucid depth=1 \
# 	atload"source $ZHOMEDIR/sh/plugins/config/powerlevel10k_atload.zsh" \
# 	light-mode for @romkatv/powerlevel10k


# -------------------------------------------------------------------------
# History
# -------------------------------------------------------------------------
# zinit wait'1' lucid \
# 	if"(( ${ZSH_VERSION%%.*} > 4.4))" \
# 	light-mode for @zsh-users/zsh-history-substring-search

# zinit wait'2' lucid \
# 	atinit"source $ZHOMEDIR/sh/plugins/config/per-directory-history_atinit.zsh" \
# 	atload"_per-directory-history-set-global-history" \
# 	light-mode for @CyberShadow/per-directory-history
# https://github.com/jimhester/per-directory-history/issues/21
# https://github.com/jimhester/per-directory-history/issues/27
#  @jimhester/per-directory-history

#--------------------------------#
# improve cd
#--------------------------------#
# zinit wait'1' lucid \
# 	from"gh-r" as"program" pick"zoxide-*/zoxide" \
# 	atload"source $ZHOMEDIR/rc/pluginconfig/zoxide_atload.zsh" \
# 	light-mode for @ajeetdsouza/zoxide

# zinit wait'1' lucid \
# 	light-mode for @mollifier/cd-gitroot

# zinit wait'1' lucid \
# 	light-mode for @peterhurford/up.zsh

# zinit wait'1' lucid \
# 	light-mode for @Tarrasch/zsh-bd

# zinit wait'1' lucid \
# 	atinit"source $ZHOMEDIR/rc/pluginconfig/zshmarks_atinit.zsh" \
# 	light-mode for @jocelynmallon/zshmarks


#--------------------------------#
# git
#--------------------------------#
# zinit wait'2' lucid \
# 	light-mode for @caarlos0/zsh-git-sync


#--------------------------------#
# fzf
#--------------------------------#
# zinit wait'0b' lucid \
# 	from"gh-r" as"program" \
# 	atload"source $ZHOMEDIR/sh/plugins/config/fzf_atload.zsh" \
# 	for @junegunn/fzf
# zinit ice wait'0a' lucid
# zinit snippet https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh
# zinit ice wait'1a' lucid atload"source $ZHOMEDIR/rc/pluginconfig/fzf_completion.zsh_atload.zsh"
# zinit snippet https://github.com/junegunn/fzf/blob/master/shell/completion.zsh
# zinit ice wait'0a' lucid as"program"
# zinit snippet https://github.com/junegunn/fzf/blob/master/bin/fzf-tmux

# zinit wait'1' lucid \
# 	pick"fzf-extras.zsh" \
# 	atload"source $ZHOMEDIR/rc/pluginconfig/fzf-extras_atload.zsh" \
# 	light-mode for @atweiden/fzf-extras # fzf

# zinit wait'0c' lucid \
# 	pick"fzf-finder.plugin.zsh" \
# 	atinit"source $ZHOMEDIR/rc/pluginconfig/zsh-plugin-fzf-finder_atinit.zsh" \
# 	light-mode for @leophys/zsh-plugin-fzf-finder

# zinit wait'0c' lucid \
# 	atinit"source $ZHOMEDIR/rc/pluginconfig/fzf-mark_atinit.zsh" \
# 	light-mode for @urbainvaes/fzf-marks

# zinit wait'1c' lucid \
# 	atinit"source $ZHOMEDIR/rc/pluginconfig/fzf-zsh-completions_atinit.zsh" \
# 	light-mode for @chitoku-k/fzf-zsh-completions

# zinit wait'2' lucid \
# 	atinit"source $ZHOMEDIR/rc/pluginconfig/zsh-fzf-widgets_atinit.zsh" \
# 	light-mode for @amaya382/zsh-fzf-widgets

# zinit wait'2' lucid silent blockf depth"1" \
# 	atclone'deno cache --no-check ./src/cli.ts' \
# 	atpull'%atclone' \
# 	atinit"source $ZHOMEDIR/rc/pluginconfig/zeno_atinit.zsh" \
# 	atload"source $ZHOMEDIR/rc/pluginconfig/zeno_atload.zsh" \
# 	for @yuki-yano/zeno.zsh


#--------------------------------#
# extension
#--------------------------------#
# if [[ -z "$SSH_CONNECTION" ]]; then
# 	zinit wait'0' lucid \
# 		atload"source $ZHOMEDIR/rc/pluginconfig/zsh-auto-notify_atload.zsh" \
# 		light-mode for @MichaelAquilina/zsh-auto-notify
# fi

# zinit wait'0' lucid \
# 	light-mode for @mafredri/zsh-async

# zinit wait'0' lucid \
# 	atinit"source $ZHOMEDIR/rc/pluginconfig/zsh-completion-generator_atinit.zsh" \
# 	light-mode for @RobSis/zsh-completion-generator

# zinit wait'2' lucid \
# 	light-mode for @hlissner/zsh-autopair

#--------------------------------#
# enhancive command
#--------------------------------#
# zinit wait'1' lucid \
# 	from"gh-r" as"program" pick"bin/exa" \
# 	atload"source $ZHOMEDIR/rc/pluginconfig/exa_atload.zsh" \
# 	light-mode for @ogham/exa

# zinit wait'1' lucid blockf nocompletions \
# 	from"gh-r" as'program' pick'ripgrep*/rg' \
# 	cp"ripgrep-*/complete/_rg -> _rg" \
# 	atclone'chown -R $(id -nu):$(id -ng) .; zinit creinstall -q BurntSushi/ripgrep' \
# 	atpull'%atclone' \
# 	light-mode for @BurntSushi/ripgrep

# zinit wait'1' lucid blockf nocompletions \
# 	from"gh-r" as'program' cp"fd-*/autocomplete/_fd -> _fd" pick'fd*/fd' \
# 	atclone'chown -R $(id -nu):$(id -ng) .; zinit creinstall -q sharkdp/fd' \
# 	atpull'%atclone' \
# 	light-mode for @sharkdp/fd

# zinit wait'1' lucid \
# 	from"gh-r" as"program" cp"bat/autocomplete/bat.zsh -> _bat" pick"bat*/bat" \
# 	atload"export BAT_THEME='Nord'; alias cat=bat" \
# 	light-mode for @sharkdp/bat

# zinit wait'1' lucid \
# 	from"gh-r" as"program" \
# 	atload"alias rt='trash put'" \
# 	light-mode for @oberblastmeister/trashy

# zinit wait'1' lucid \
# 	from"gh-r" as"program" pick"tldr" \
# 	light-mode for @dbrgn/tealdeer
# zinit ice wait'1' lucid as"completion" mv'zsh_tealdeer -> _tldr'
# zinit snippet https://github.com/dbrgn/tealdeer/blob/main/completion/zsh_tealdeer

# zinit wait'1' lucid \
# 	from"gh-r" as"program" bpick'*linux*' \
# 	light-mode for @dalance/procs

# zinit wait'1' lucid \
# 	from"gh-r" as"program" pick"delta*/delta" \
# 	atload"compdef _gnu_generic delta" \
# 	light-mode for @dandavison/delta

# zinit wait'1' lucid \
# 	from"gh-r" as"program" pick"mmv*/mmv" \
# 	light-mode for @itchyny/mmv


#--------------------------------#
# program
#--------------------------------#

# neovim
# zinit wait'0' lucid nocompletions \
# 	from'gh-r' ver'nightly' as'program' bpick'*tar.gz' \
# 	atclone"command cp -rf nvim*/* $ZPFX; echo "" > ._zinit/is_release" \
# 	atpull'%atclone' \
# 	run-atpull \
# 	atload"source $ZHOMEDIR/sh/plugins/config/neovim_atload.zsh" \
# 	light-mode for @neovim/neovim

# wezterm
# zinit wait'2' lucid nocompletions \
# 	from"gh-r" ver"nightly"  as"program" bpick"*22.04.tar.xz" \
# 	atclone"command cp -rf wezterm/usr/* $ZPFX; ln -snf $ZPFX/bin/wezterm ~/.local/bin/x-terminal-emulator; echo "" > ._zinit/is_release" \
# 	atpull'%atclone' \
# 	run-atpull \
# 	light-mode for @wez/wezterm

# node (for coc.nvim)
# zinit wait'0' lucid id-as=node as='readurl|command' \
	#   nocompletions nocompile extract \
	#   pick'node*/bin/*' \
	#   dlink='node-v%VERSION%-linux-x64.tar.gz' \
	#   for https://nodejs.org/download/release/latest/

## tmux
#if ldconfig -p | grep -q 'libevent-' && ldconfig -p | grep -q 'libncurses'; then
#  zinit wait'0' lucid \
	#    from"gh-r" as"program" bpick"tmux-*.tar.gz" pick"*/tmux" \
	#    atclone"cd tmux*/; ./configure; make" \
	#    atpull"%atclone" \
	#    light-mode for @tmux/tmux
#elif builtin command -v tmux > /dev/null 2>&1 && test $(echo "$(tmux -V | cut -d' ' -f2) <= "2.5"" | tr -d '[:alpha:]' | bc) -eq 1; then
#  zinit wait'0' lucid \
	#    from'gh-r' as'program' bpick'*AppImage*' mv'tmux* -> tmux' pick'tmux' \
	#    light-mode for @tmux/tmux
#fi

# translation #
zinit wait'1' lucid \
	light-mode for @soimort/translate-shell

# if builtin command -v pip > /dev/null 2>&1; then
# 	zinit wait'1' lucid \
# 		as"null" \
# 		atclone"PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring pip install -U deep-translator" \
# 		atpull'%atclone' \
# 		light-mode for @nidhaloff/deep-translator
# fi

# zinit wait'1' lucid \
# 	from"gh-r" as"program" \
# 	mv'mocword* -> mocword' \
# 	atload"source $ZHOMEDIR/rc/pluginconfig/mocword_atload.zsh" \
# 	light-mode for @high-moctane/mocword

# env #
# zinit wait'1' lucid \
# 	from"gh-r" as"program" pick"direnv" \
# 	atclone'./direnv hook zsh > zhook.zsh' \
# 	atpull'%atclone' \
# 	light-mode for @direnv/direnv

# zinit wait'1' lucid \
# 	atinit"source $ZHOMEDIR/rc/pluginconfig/asdf_atinit.zsh" \
# 	atload"source $ZHOMEDIR/rc/pluginconfig/asdf_atload.zsh" \
# 	pick"asdf.sh" \
# 	light-mode for @asdf-vm/asdf

# GitHub #
# zinit wait'1' lucid \
# 	from"gh-r" as"program" pick"ghq*/ghq" \
# 	atload"source $ZHOMEDIR/rc/pluginconfig/ghq_atload.zsh" \
# 	light-mode for @x-motemen/ghq

# zinit wait'1' lucid \
# 	from"gh-r" as"program" pick"ghg*/ghg" \
# 	light-mode for @Songmu/ghg

# zinit wait'1' lucid \
# 	from"gh-r" as'program' bpick'*linux_*.tar.gz' pick'gh*/**/gh' \
# 	atload"source $ZHOMEDIR/rc/pluginconfig/gh_atload.zsh" \
# 	light-mode for @cli/cli

# zinit wait'1' lucid \
# 	from"gh-r" as"program" cp"hub-*/etc/hub.zsh_completion -> _hub" pick"hub-*/bin/hub" \
# 	atload"source $ZHOMEDIR/rc/pluginconfig/hub_atload.zsh" \
# 	for @github/hub


