FROM ubuntu:22.04

RUN apt-get update -y \
  && apt-get install -y \
  curl zsh tmux git language-pack-ja-base language-pack-ja neovim \
  python3-dev python3-pip
  # apt-get install -y software-properties-common && \
  # apt-add-repository -y ppa:neovim-ppa/stable && \
  # apt-get update -y && \
  # apt-get install -y \

# neovim
RUN pip3 install --upgrade neovim \
  && update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60 \
  && update-alternatives --config vi \
  && update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60 \
  && update-alternatives --config vim \
  && update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60 \
  && update-alternatives --config editor

# cargo
#ENV RUST_VERSION stable
#RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain ${RUST_VERSION}
#ENV PATH $PATH:$HOME/.cargo/bin

# alacritty
#RUN git clone https://github.com/alacritty/alacritty.git \ 
#  && cd alacritty \
#  && rustup override set stable \
#  && rustup update stable \
#  && apt-get install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3 -y \
#  && cargo build --release \
#  && infocmp alacritty \
#  && tic -xe alacritty,alacritty-direct extra/alacritty.info \
#  && cp target/release/alacritty /usr/local/bin \
#  && cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg \
#  && desktop-file-install extra/linux/Alacritty.desktop \
#  && update-desktop-database \
#  && mkdir -p /usr/local/share/man/man1 \
#  && gzip -c extra/alacritty.man | tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null \
#  && cd $HOME 

RUN git clone https://gitlab.com/flap1/dotfiles.git 

# other
RUN  apt-get install ripgrep fzf fd-find peco \
  && ln -s $(which fdfind) /usr/bin \
  && zinit ice lucid wait"0a" from"gh-r" as"program" atload'eval "$(mcfly init zsh)"' \
  && zinit light cantino/mcfly
  # && cargo install lsd \ 

RUN cd dotfiles && bash setup.sh && cd $HOME

CMD ["zsh"]
