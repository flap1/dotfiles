#!/bin/bash

while test $# -gt 0; do
  case "$1" in
    --init)
      # Removing Nodejs and Npm
      sudo apt-get remove nodejs npm node
      sudo apt-get purge nodejs
      
      # Now remove .node and .npm folders from your system
      sudo rm -rf /usr/local/bin/npm 
      sudo rm -rf /usr/local/share/man/man1/node* 
      sudo rm -rf /usr/local/lib/dtrace/node.d 
      sudo rm -rf ~/.npm 
      sudo rm -rf ~/.node-gyp 
      sudo rm -rf /opt/local/bin/node 
      sudo rm -rf opt/local/include/node 
      sudo rm -rf /opt/local/lib/node_modules  
      sudo rm -rf /usr/local/lib/node*
      sudo rm -rf /usr/local/include/node*
      sudo rm -rf /usr/local/bin/node*
      shift
      ;;
    *)
      break
      ;;
  esac
done

# nvm
mkdir -p ~/.nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
nvm install --lts
nvm use --lts
nvm alias default --lts

