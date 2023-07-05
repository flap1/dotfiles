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

# pyenv
if [ -x "$(command -v pyenv)" ]; then
eval "$(pyenv init -)"
fi

export PYENV_VIRTUALENV_DISABLE_PROMPT=0
export PYENV_ROOT=$HOME/.pyenv

# poetry
export PATH=${POETRY_HOME:-$HOME/.local/share/poetry}/bin:$PATH

# jenv
if [ -e "~/.jenv" ]; then
	eval "$(jenv init -)"
fi

# gradle
if [ -e "/opt/gradle/latest" ]; then
	eval "$(jenv init -)"
fi
export PATH=${GRADLE_HOME:-/opt/gradle/latest}/bin:$PATH

# node
export NVM_DIR=$HOME/.nvm
export MANPATH=$NVM_DIR/default/share/man:$MANPATH
export NODE_PATH=$NVM_DIR/default/lib/node_modules
export NODE_PATH=${NODE_PATH:A}

# if [ ! -x "$(command -v node )" ]; then
# 	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# 	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# fi

nvm() {
  unset -f nvm
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  nvm "$@"
}

# deno
export DENO_INSTALL=$HOME/.deno

# gh
if [ -x "$(command -v gh)" ]; then
eval "$(gh completion -s zsh)"
fi

# go
[ -f "$HOME/.goenv" ] && export GOENV_ROOT="$HOME/.goenv" && export PATH="$GOENV_ROOT/bin:$PATH" && eval "$(goenv init -)"  

# ros
[ -f "/opt/ros/humble/setup.zsh" ] && source "/opt/ros/humble/setup.zsh"
[ -d "$HOME/.tfenv" ] && export PATH=$HOME/.tfenv/bin:$PATH

# yre
[ -f "$HOME/.rye/env" ] && source "$HOME/.rye/env"

# aws
 [ -f "$HOME/.aws/config" ] && export AWS_VAULT_BACKEND=file
