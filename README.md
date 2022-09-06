# dotfiles

* zsh
    * Zinit
    * Powerlevel10k
* WezTerm 
* Neovim

## Keymaps

C: Ctrl, S: Shift, A: Alt

### Terminal

keymap | exp
- | -
C-r | コマンド履歴検索(mcfly)
C-@ | 履歴からディレクトリ検索

### WezTerm Normal Mode

keymap | exp
- | -
A-Enter | フルスクリーン
C-= | フォントサイズリセット
C-+ | フォントサイズ大
C-- | フォントサイズ小
A-1..9 | タブ選択
A-h, A-l | タブ移動
C-Tab, CS-Tab | タブ移動
AC-h, AC-l | タブ自体の移動
A-t, C-t | タブ新規作成(C-tはドメイン維持)
A-t, C-t | タブ削除
A-- | Pane下に分割
A-\\ | Pane右に分割
A-h,l,k,j | Pane移動
A-r->h,l,k,j | Paneサイズ変更(Escapeで抜ける)
A-s->1..9 | Pane選択
A-f | Pane時計回りに移動
A-b | Pane反時計回りに移動
C-C | クリップボードにコピー
C-V | クリップボードからペースト
A-c, CS-x, CS-Enter | コピーモードに入る
A-q, A-x, C-d | 現在のPaneを閉じる
C-LeftClick(url) | リンクを開く
RightClick(when selected) | クリップボードにコピー

### WezTerm Copy Mode

keymap | exp
- | -
q, Escape | コピーモードから抜ける
h, l, j, k | 移動
A-f, Tab, w | 次の単語へ移動
A-b, S-Tab, b | 前の単語へ移動
e | 次の単語の前へ移動
0 | 行の最初へ移動
$, C-e  | 行の最後へ移動
^, C-a | 行の最初の文字へ移動
Space, v | 選択モードへ
S-v | 行を選択して選択モードへ
y | クリップボードにコピー
Y | 行の最後までコピー
G | 最後の行へ
g | 最初の行へ
H, M, L | 画面上, 中央, 下へ
C-b | ページ上へ
C-f | ページ下へ
o, O | 選択時に最初/最後へ
Enter | 選択時に選択解除
/ | 検索モードへ
n | 次のマッチへ
N | 前のマッチへ

### WezTerm Search Mode

keymap | exp
- | -
C-u | 入力をクリア
C-r | 検索タイプを変更
C-n | 次のマッチへ
C-N | 前のマッチへ
Enter | コピーモードへ
Escape | 検索モードから抜ける




## Command

command | alias元/exp
- | -
xxx L | xxx &#124; bat --style=plain
xxx H | xxx &#124; head
xxx G | xxx &#124; rg -S
xxx A | xxx &#124; awk
xxx C | xxx &#124; tee >(pbcopy)
xxx X | xxx &#124; xargs
 .. | cd ..
.2 | cd ../..
.3 | cd ../../..
.4 | cd ../../../..
.5 | cd ../../../../..
mkdir | mkdir -p
cat/less | bat
ls | lsd -A --group-dirs=last
l | lsd -Ahl --total-size --group-dirs=last
ll | lsd -Ahl --total-size --group-dirs=last
lt | lsd -Ahl --total-size --tree --group-dirs=last
tree | lsd -A --tree --group-dirs=last
du | dust, ディレクトリサイズ
df | df -h, ディスクの空き容量
ps | procs --tree
grep | rg -S
find | fd
fd | fd -E gdrive, ファイル検索
diff | delta
rm/mv/cp | rm/mv/cp -i
vim/v | nvim
python/pip | python3/pip3
ga | git add -A
gc | git commit -m
gp | git push
gl | git pull
gpo | git push -u origin HEAD
glom | git pull origin main
gloms | git pull origin master && git submodule update --init --recursive
gll | git log --oneline
di | docker images
dr | docker run --rm
ds | docker stop $(docker ps -q)
dcb | docker-compose build
dcu | docker-compose up
dcd | docker-compose down
dps | docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"
drm | docker system prune
zmv | ex) zmv -w 'from' 'to'
dir_name | カレント/親/ホームディレクトリ内のディレクトリ名で移動, コマンド名と被る場合は./dir_name
cb | chromeのブックマークを検索
ch | chromeの履歴を検索
mkcd | ディレクトリを作成して移動
gitfix | checkoutせずにcommitした場合の修正
update | 更新(Ubuntu)
pdf_unlock | pdfの鍵解除

## Fonts

* [UDEV Gothic 35NFLG](https://github.com/yuru7/udev-gothic)
* [NERD FONTS](https://www.nerdfonts.com/)

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
```

