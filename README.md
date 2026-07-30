# flap1's dotfiles

## Env

- Windows Terminal over ssh + tmux
- zsh (Zinit, Starship)
- Neovim

## 特殊な変更

### cheatsheet.nvim

registerを設定できるように. PR出してない

```diff
# ~/.local/share/nvim/site/pack/packer/opt/cheatsheet.nvim/lua/cheatsheet/config.lua
+    register = "0",

# ~/.local/share/nvim/site/pack/packer/opt/cheatsheet.nvim/lua/cheatsheet/telescope/actions.lua
-    vim.fn.setreg("0", cheatcode)
+    local register = require('cheatsheet.config').options.register
+    vim.fn.setreg(register, cheatcode)
```

### neo-tree.nvim

システムの`rm`ではなく, aliasの`rm`を呼ぶ. PR出すべきでない.

```diff
# ~/.local/share/nvim/site/pack/packer/opt/neo-tree.nvim/lua/neo-tree/sources/filesystem/lib/fs_actions.lua
- local success = loop.fs_unlink(path)
+ vim.api.nvim_command(string.format("silent !rm '%s'", path))
+ local success = true

- local result = vim.fn.system({ "rm", "-Rf", path }) # NOTE: changed
+ vim.api.nvim_command(string.format("silent !rm '%s'", path))
+ local result = true

- local success = loop.fs_unlink(child_path)
+ local success = true
```

## Other

`:checkhealth`: debug

## Command

| command    | alias元/exp                                                                              |
| ---------- | ---------------------------------------------------------------------------------------- |
| xxx L      | xxx \| bat --style=plain                                                                 |
| xxx H      | xxx \| head                                                                              |
| xxx G      | xxx \| rg -S                                                                             |
| xxx A      | xxx \| awk                                                                               |
| xxx C      | xxx \| tee >(pbcopy)                                                                     |
| xxx X      | xxx \| xargs READMREADME                                                                 |
| ..         | cd ..                                                                                    |
| .2         | cd ../..                                                                                 |
| .3         | cd ../../..                                                                              |
| .4         | cd ../../../..                                                                           |
| .5         | cd ../../../../..                                                                        |
| mkdir      | mkdir -p                                                                                 |
| cat/less   | bat                                                                                      |
| ls         | lsd -A --group-dirs=last                                                                 |
| l          | lsd -Ahl --total-size --group-dirs=last                                                  |
| ll         | lsd -Ahl --total-size --group-dirs=last                                                  |
| lt         | lsd -Ahl --total-size --tree --group-dirs=last                                           |
| tree       | lsd -A --tree --group-dirs=last                                                          |
| du         | dust, ディレクトリサイズ                                                                 |
| df         | df -h, ディスクの空き容量                                                                |
| ps         | procs --tree                                                                             |
| grep       | rg -S                                                                                    |
| fd         | fd -E gdrive, ファイル検索                                                               |
| diff       | delta                                                                                    |
| rm/mv/cp   | rm/mv/cp -i                                                                              |
| vim/v      | nvim                                                                                     |
| python/pip | python3/pip3                                                                             |
| ga         | git add -A                                                                               |
| gc         | git commit -m                                                                            |
| gp         | git push                                                                                 |
| gl         | git pull                                                                                 |
| gpo        | git push -u origin HEAD                                                                  |
| glom       | git pull origin main                                                                     |
| gloms      | git pull origin master && git submodule update --init --recursive                        |
| gll        | git log --oneline                                                                        |
| di         | docker images                                                                            |
| dr         | docker run --rm                                                                          |
| ds         | docker stop $(docker ps -q)                                                              |
| dcb        | docker-compose build                                                                     |
| dcu        | docker-compose up                                                                        |
| dcd        | docker-compose down                                                                      |
| dps        | docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"               |
| drm        | docker system prune                                                                      |
| zmv        | ex) zmv -w 'from' 'to'                                                                   |
| dir_name   | カレント/親/ホームディレクトリ内のディレクトリ名で移動, コマンド名と被る場合は./dir_name |
| cb         | chromeのブックマークを検索                                                               |
| ch         | chromeの履歴を検索                                                                       |
| mkcd       | ディレクトリを作成して移動                                                               |
| gitfix     | checkoutせずにcommitした場合の修正                                                       |
| update     | 更新(Ubuntu)                                                                             |
| pdf_unlock | pdfの鍵解除                                                                              |

## Fonts

- [UDEV Gothic 35NFLG](https://github.com/yuru7/udev-gothic)
- [NERD FONTS](https://www.nerdfonts.com/)
- `~/.local/share/fonts`におく

## Preparation

```bash
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

# other
sudo apt install feh # image viewer
sudo apt install translate-shell # trans
sudo apt install xcape # xcape
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

@rem install c
scoop install gcc

git clone https://gitlab.com/flap1/dotfiles ~
```

```powershell
powershell -File %UserProfile%\dotfiles\setup_windows.ps1
```

昇格は不要。ディレクトリは symlink ではなく junction で張る (`mklink /d` は
elevation か Developer Mode を要求するが junction は要求しない)。hardlink は
使わない。git や Windows Terminal は保存時にファイルを置き換えるので、その瞬間に
link が外れて古い設定が残り続ける。

やること:

- `.config/nvim` → `~/.config/nvim` に junction (このマシンは `XDG_CONFIG_HOME`
  が `~/.config` なので Windows native の `~/AppData/Local/nvim` ではない)
- `.config/windows-terminal/LocalState` → Terminal の LocalState に junction。
  **Terminal を全部閉じてから実行する必要がある**（起動中は settings.json を
  掴んでいてディレクトリを rename できないので、スクリプトが検出して中断する）
- `git core.sshCommand` を Windows OpenSSH に固定
- `-Gitconfig` を付けた時だけ `.config/git/.gitconfig` を `~/.gitconfig` に
  include で取り込む。既定で off なのは共有 gitconfig が `core.pager = delta` と
  `core.editor = nvim` を設定するため。未インストールの環境では git が壊れる
  (`scoop install delta neovim` 後に有効化する)。include は先頭に入れるので、
  `~/.gitconfig` にある機械固有の設定 (git-lfs, credential helper) が勝つ

### なぜ settings.json 単体ではなく LocalState ごと張るのか

settings.json だけを link するのは既知の罠。Terminal は GUI 保存時にファイルを
**置き換える**ので link が外れ、エディタで直接編集しても hot-reload が効かなくなる。
LocalState ごと junction すれば両方回避でき、しかも双方向になる（GUI で変えた分が
そのまま repo の差分として出る。取り込みコマンドは不要）。runtime state は
`LocalState/.gitignore` で除外している。

### なぜ ssh を Windows OpenSSH に固定するのか

Git for Windows は MSYS ビルドの ssh を同梱し、Git Bash では PATH の先頭に来る。
この2実装は挙動が違う: MSYS 側は `~/.ssh/config` の `C:\...` を literal な文字列
として扱って include を黙って無視し、鍵も別の agent に持つ。PowerShell では通る
ホストが Git Bash では通らない、しかも何も報告されない。git を Windows のバイナリに
固定して ssh を1つにする。

Shift+Enter は `sendInput` で ESC + CR を送るバインドにしてある。Claude Code が
alt+enter として解釈して改行になる (`/terminal-setup` は iTerm2 と VSCode 用で
Windows Terminal は対象外)。


### Fonts

- JetBriansMono Nerd Font
- [UDEVGothic Releases](https://github.com/yuru7/udev-gothic/releases)からUDEVGothic_NF_vx.x.x.zipをダウンロードして展開
- 個人用設定>フォント>ttfファイルをドラッグアンドドロップ

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

## Keybindings

There is no keymap document here. Both tools list their own bindings at
runtime, and a checked-in copy silently disagrees with the config the moment
either changes:

| | |
|---|---|
| nvim | `<Leader>fk` (telescope), or which-key after any prefix |
| tmux | `prefix ?` |
| lazygit | `?` |

The rules the nvim keymaps follow are stated at the top of
`.config/nvim/lua/core/keymaps.lua`.
