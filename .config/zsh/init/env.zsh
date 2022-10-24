export MYVIMRC=$HOME/.config/nvim/init.lua
export PATH=$HOME/dotfiles/bin:$PATH

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --color=always --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi"

export DENO_INSTALL=$HOME/.deno
export PATH=$DENO_INSTALL/bin:$PATH

# export TODOIST_API_KEY="$(pass Todoist/API)"

export PYENV_VIRTUALENV_DISABLE_PROMPT=0

export NVM_DIR=$HOME/.nvm
MANPATH=$NVM_DIR/default/share/man:$MANPATH
export NODE_PATH=$NVM_DIR/default/lib/node_modules
NODE_PATH=${NODE_PATH:A}
export PATH=$HOME/.local/bin:$NVM_DIR/default/bin:$PATH

nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  nvm "$@"
}

