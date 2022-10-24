# flap1's dotfiles

```txt
         ▄▄▒▒▀▀░░░▀▀▀▀▓▄▄
      ▄▓▀░▄▄▓▓▓▓▓▓▓▓▄▄▄▒█▓▄▄
    ▄▀▄▓███████████████▀░░░ ▀▄
   █▄████████████▀▀████░▄▀▓░▌▓▌
 ▓░█████▀▀█████▌   ▄▐██▄▌     █
▓░░███▌  ▄ ▀██▀  ▀   ▀█▀▄    ▄
▐░░███▌         ▄▄▄▄▄        ▐
 █▀   ▀▄       █              ▄
 ▌             ▀▄             ▌
 ▀▄              ▀            ▌
   ▓                         ▐
   █                        ▄▀
    ▀ ▄    ▄       ▄▄▄▄   ▄
         ▀▀▀▀▀     ▀▀▀▀
```

## Env

* zsh
  * Zinit
  * Powerlevel10k
* WezTerm
* Neovim

## Other

`:checkhealth`: debug

## Command

| command     | alias元/exp                                                                 |
| ----------- | -------------------------------------------------------------------------- |
| xxx L       | xxx \| bat --style=plain                                                   |
| xxx H       | xxx \| head                                                                |
| xxx G       | xxx \| rg -S                                                               |
| xxx A       | xxx \| awk                                                                 |
| xxx C       | xxx \| tee >(pbcopy)                                                       |
| xxx X       | xxx \| xargs                                                               |
| ..          | cd ..                                                                      |
| .2          | cd ../..                                                                   |
| .3          | cd ../../..                                                                |
| .4          | cd ../../../..                                                             |
| .5          | cd ../../../../..                                                          |
| mkdir       | mkdir -p                                                                   |
| cat/less    | bat                                                                        |
| ls          | lsd -A --group-dirs=last                                                   |
| l           | lsd -Ahl --total-size --group-dirs=last                                    |
| ll          | lsd -Ahl --total-size --group-dirs=last                                    |
| lt          | lsd -Ahl --total-size --tree --group-dirs=last                             |
| tree        | lsd -A --tree --group-dirs=last                                            |
| du          | dust, ディレクトリサイズ                                                            |
| df          | df -h, ディスクの空き容量                                                           |
| ps          | procs --tree                                                               |
| grep        | rg -S                                                                      |
| fd          | fd -E gdrive, ファイル検索                                                       |
| diff        | delta                                                                      |
| rm/mv/cp    | rm/mv/cp -i                                                                |
| vim/v       | nvim                                                                       |
| python/pip  | python3/pip3                                                               |
| ga          | git add -A                                                                 |
| gc          | git commit -m                                                              |
| gp          | git push                                                                   |
| gl          | git pull                                                                   |
| gpo         | git push -u origin HEAD                                                    |
| glom        | git pull origin main                                                       |
| gloms       | git pull origin master && git submodule update --init --recursive          |
| gll         | git log --oneline                                                          |
| di          | docker images                                                              |
| dr          | docker run --rm                                                            |
| ds          | docker stop $(docker ps -q)                                                |
| dcb         | docker-compose build                                                       |
| dcu         | docker-compose up                                                          |
| dcd         | docker-compose down                                                        |
| dps         | docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}" |
| drm         | docker system prune                                                        |
| zmv         | ex) zmv -w 'from' 'to'                                                     |
| dir\_name   | カレント/親/ホームディレクトリ内のディレクトリ名で移動, コマンド名と被る場合は./dir\_name                       |
| cb          | chromeのブックマークを検索                                                           |
| ch          | chromeの履歴を検索                                                               |
| mkcd        | ディレクトリを作成して移動                                                              |
| gitfix      | checkoutせずにcommitした場合の修正                                                   |
| update      | 更新(Ubuntu)                                                                 |
| pdf\_unlock | pdfの鍵解除                                                                    |

## Fonts

* [UDEV Gothic 35NFLG](https://github.com/yuru7/udev-gothic)
* [NERD FONTS](https://www.nerdfonts.com/)
* `~/.local/share/fonts`におく

## Preparation

```bash
### Install WezTerm
# https://wezfurlong.org/wezterm/install/linux.html

### Set WezTerm as default terminal
# x-terminal-emulator alacritty priority to 60
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/wezterm 50

# Confirmation of setting status
# if it is larger than other terminals, ok
sudo update-alternatives --display x-terminal-emulator

# When you want to change priorities on the CLI
sudo update-alternatives --config x-terminal-emulator

# Revert settings
sudo update-alternatives --remove "x-terminal-emulator" "/usr/bin/wezterm"

### Set dotfiles
bash setup.sh

### Install packages
# peco
# github: https://github.com/peco/peco/releases

# fzf, https://github.com/junegunn/fzf
sudo apt install fzf

# bat, https://github.com/sharkdp/bat
sudo apt install bat
ln -s /usr/bin/batcat ~/dotfiles/bin/bat

# lsd, https://github.com/Peltoche/lsd
cargo install lsd

# delta, https://github.com/dandavison/delta
cargo install git-delta

# ripgrep, https://github.com/BurntSushi/ripgrep
sudo apt install ripgrep # rg

# dust, https://github.com/bootandy/dust
cargo install du-dust

# procs, https://github.com/dalance/procs
cargo install procs

### Optional packages
# pastel, https://github.com/sharkdp/pastel
cargo install pastel

# grex, https://github.com/pemistahl/grex
cargo install grex

# silicon, https://github.com/Aloxaf/silicon
sudo apt install expat
sudo apt install libxml2-dev
sudo apt install pkg-config libasound2-dev libssl-dev cmake libfreetype6-dev libexpat1-dev libxcb-composite0-dev
cargo install silicon

cargo install navi

# setting
# install: https://github.com/neovim/neovim/wiki/Installing-Neovim#linux
rm -rf ~/.local/share/zinit
sudo apt install zsh pass
bash setup.sh
```

## setup windows

@cmd.exe

```dos
@rem install Powershell7
winget install --id Microsoft.Powershell --source winget
winget install --id Microsoft.Powershell.Preview --source winget

@rem install scoop
Set-ExecutionPolicy RemoteSigned -scope CurrentUser -force
iwr -useb get.scoop.sh | iex

@rem basics
scoop install aria2
scoop install jq ccat wget sed vim
scoop install 7zip sudo git unzip openssl

@rem install neovim
scoop install neovim

@rem install oh-my-posh
scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json

@rem install c
scoop install gcc

git clone https://gitlab.com/flap1/dotfiles ~
```

```powershell
sudo cmd /c %UserProfile%\dotfiles\setup_windows.bat
```

* [install wezterm](https://wezfurlong.org/wezterm/install/windows.html)

### Fonts

* JetBriansMono Nerd Font
* [UDEVGothic Releases](https://github.com/yuru7/udev-gothic/releases)からUDEVGothic_NF_vx.x.x.zipをダウンロードして展開
* 個人用設定>フォント>ttfファイルをドラッグアンドドロップ

### コマンド

```powershell
shutdown /s /t 0 # shutdown now
shutdown /r /t 0 # reboot
Get-ChildItem env: # 環境変数取得
```

### neovim setup

```powershell
git clone https://github.com/wbthomason/packer.nvim "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"
```
