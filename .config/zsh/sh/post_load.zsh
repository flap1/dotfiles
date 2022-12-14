## =========================================================================
## Post Execution
## =========================================================================

if ! builtin command -v zinit > /dev/null 2>&1; then
	if ! builtin command -v compinit > /dev/null 2>&1; then
		autoload -Uz compinit
		if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
			compinit
		else
			compinit -C
		fi
	fi
fi

<<<<<<< HEAD
# pyenv
||||||| parent of e3344e9 (update dotfiles)
=======
# pyenv
if [ -x "$(command -v pyenv)" ]; then
>>>>>>> e3344e9 (update dotfiles)
eval "$(pyenv init -)"
fi
export PYENV_VIRTUALENV_DISABLE_PROMPT=0
export PYENV_ROOT=$HOME/.pyenv

<<<<<<< HEAD
# deno
export DENO_INSTALL=$HOME/.deno
||||||| parent of e3344e9 (update dotfiles)
export DENO_INSTALL=$HOME/.deno
=======
# jenv
if [ -e "~/.jenv" ]; then
	eval "$(jenv init -)"
fi
>>>>>>> e3344e9 (update dotfiles)

<<<<<<< HEAD
# node
||||||| parent of e3344e9 (update dotfiles)
=======
# gradle
if [ -e "/opt/gradle/latest" ]; then
	eval "$(jenv init -)"
fi
export PATH=${GRADLE_HOME:-/opt/gradle/latest}/bin:$PATH

# node
>>>>>>> e3344e9 (update dotfiles)
export NVM_DIR=$HOME/.nvm
MANPATH=$NVM_DIR/default/share/man:$MANPATH
export NODE_PATH=$NVM_DIR/default/lib/node_modules
NODE_PATH=${NODE_PATH:A}

nvm() {
  unset -f nvm
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  nvm "$@"
}

# deno
export DENO_INSTALL=$HOME/.deno

