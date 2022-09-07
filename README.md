# dotfiles

* zsh
    * Zinit
    * Powerlevel10k
* WezTerm 
* Neovim

## Keymaps

C: Ctrl, S: Shift, A: Alt, L: Space, K: Comma

### Vim

#### Normal Mode 

* [count]{motion}
* [count]{operator}{motion}
* {operator}{text-objects}
* {visual-operation}{motion|text-objects}

keymap | exp | 分類
- | - | -
:e path | pathを開く
:cd path | pathに移動
:w/q/qa/! | write/quit/quit all/force
L-w/q | 保存/終了
L-h/l | buffer移動
C-x, C-q, L-x | buffer
i/a | insert/append
I/A | Insert(行頭)/Append(行末)
o/O | open line(下)/Open line(上)
gi | 最後に入力された場所にinsert, g+insert
0 | 最初の文字へ, 最初の文字にいる場合は行の最初へ
$ | 最後の文字へ
g0,g$: それぞれのスクリーン行バージョン(折り返し考慮)
gm | g+middle, スクリーン行の幅の真ん中に移動
f/F{char} | 右/左に現れる{char}の上に移動, f/Fで移動
t/T{char} | till,右/左に現れる{char}の前/後に移動, t/Tで移動
gg/GG | go/Go, [count]行目の最初の非空白文字に移動, カウントがなければ最初/最後の行
{count}% | ファイルの{count}%の位置に移動
C-o | Older cursur position, ジャンプリストの中の[count]だけ古いカーソル位置に移動
C-i | iはoの左, ジャンプリストの中の[count]だけ新しいカーソル位置に移動
g;/g, | 変更リスト中の [count] 個前/後の位置に移動
^/& | 変更リスト中の [count] 個前/後の位置に移動してカーソルを画面中央に
% | %=o/oのイメージ. 対応する([{}])にジャンプ. 括弧内でない場合は右側の右括弧にジャンプ.
gH/gL | Home(high,top)/Last(low) of window. スクリーン最上行/再下行から[count]行目に移動, デフォルト{vim.o.scrolloff}+1行目
gM, M | Middle line of window. スクリーン中央に移動
[{,[(,]},]) | マッチしない{,(,},)に移動
h,l,k,j | カーソル1移動 | motion
H,L,K,J | カーソル5移動 | motion
w | word, [count] word前方に移動 | motion
W | Word, [count] WORD(非空白文字の連続)前方(空白の後)に移動 | motion
e | end of word, [count] word前方の単語の終わりに移動 | motion
E | End of WORD, [count] WORD前方の単語の終わり(空白の前)に移動 | motion
b | backward, [count] words前方に移動 | motion
B | Backward, [count] WORDS前方(空白の後)に移動 | motion
c | change, insertモードへ | operator
d | delete | operator
y | yank | operator
gU | g+Uppercase, 大文字にする | operator
gu | gUの逆, 小文字にする | operator
>/< | 右/左にインデントをシフト | operator
C | Change, 行末まで変更
D | Delete, 行末まで削除
dd | 行を削除
s | substitute, カーソル下を削除してinsertモードに
S | Substitude, 行を削除してinsertモードに
x | x(バツ), カーソル下を削除
X | xの逆, カーソル前を削除
r | replace,カーソル下の文字を置き換える
R | Replace,置換モードに入る
Y, yy | Yank, 行をコピー
p | put(paste), テキストをレジスタからカーソルの後に貼り付け
P | pの逆, カーソルの前に貼り付け
gJ | Join, 行を連結する
:s///: substitute, 置換コマンド
C-a | add, カーソル下の数を加える
C-s | subtract, カーソル下の数を減じる
aw,iw | a(around) word, inner word, wordを選択. aは周りのホワイトスペースを含む | text-objects
aW,iW | a(around) WORD, inner WORD, WORDを選択. | text-objects
as,is | sentence(文)を選択 | text-objects
ap,ip | paragraph(段落)を選択 | text-objects
ab,a(,a),ib,i(,i) | a(around)/inner braces block,()ブロック,またはその内部を選択 | text-objects 
aB,a{,a},iB,i{,i} | Brackets block,{}ブロック,またはその内部を選択 | text-objects
a[,a],i[,i] | []ブロック,またはその内部を選択 | text-objects
a<,a>,i<,i> | <>ブロック,またはその内部を選択 | text-objects
a",a',a`,i",i',i` | 前の引用符から次の引用符まで,またはその内部を選択 | text-objects
gn | 最後に使われた検索パターンを前方/後方検索してマッチを選択 | text-objects
dl/dh | delete l/h, 1文字削除 | {operation}{motion/text-objects}
diw | delete inner word | {operation}{motion/text-objects}
daw | delete a(around) word | {operation}{motion/text-objects}
dgn | 次に検索パターンにマッチするものを削除 | {operation}{motion/text-objects}
dis | inner sentenceを削除 | {operation}{motion/text-objects}
dib | delete inner braces block | {operation}{motion/text-objects}
diB | delete inner Brackets block | {operation}{motion/text-objects}
/ | 前方検索
?(S-/) | 後方検索
n | next, 最後の/か?を [count]回繰り返す
N | nの逆, 最後の/か?を逆方向に[count]回繰り返す
C-e | Extra lines, 下へ[count]行ウィンドウをスクロール
C-y | 上へ[count]行ウィンドウをスクロール
C-f | Scroll forward. ページ前方(下方)にスクロール
C-b | Scroll backwards. ページ後方(上方)にスクロール
zt | z+top of window, [count]行(省略時はカーソルのある行)をウィンドウの上から{vim.o.scrolloff}+1行目にして再描画
zz | [count]行(省略時はカーソルのある行)をウィンドウの中央にして再描画
zb | z+bottom of window, [count]行(省略時はカーソルのある行)をウィンドウ下から{vim.o.scrolloff}+1行目にして再描画
u | undo, [count]個の変更を元に戻す
C-r | redo, undoされた変更を[count]個やり直す
v | visual, 文字単位のVisualモードへ
V | 行単位のVisualモードへ
C-v | 矩形Visualモードへ
. | 繰り返し

#### Insert Mode

keymap | exp
- | -
jk, Escape, C-c | Normalモードへ

### Terminal

keymap | exp
- | -
C-r | コマンド履歴検索(mcfly)
C-@, C-Space | 履歴からディレクトリ検索

### WezTerm

#### Normal Mode

keymap | exp
- | -
A-Enter | フルスクリーン
C-= | フォントサイズリセット
C--/+ | フォントサイズ小/大
A-1..9 | タブ選択
A-h/l | タブ移動
C-Tab/CS-Tab | タブ移動
AC-h/l | タブ自体の移動
A-t, C-t | タブ新規作成(C-tはドメイン維持)
C-w | タブ削除
A-- | Pane下に分割
A-\\ | Pane右に分割
A-h,l,k,j | Pane移動
A-r->h,l,k,j | Paneサイズ変更(Escapeで抜ける)
A-s->1..9 | Pane選択
A-f/b | Pane時計/反時計回りに移動
C-C | クリップボードにコピー
C-V | クリップボードからペースト
A-c, CS-x, CS-Enter | コピーモードに入る
A-q, A-x, C-d | 現在のPaneを閉じる
C-LeftClick(url) | リンクを開く
RightClick(when selected) | クリップボードにコピー

#### Copy Mode

keymap | exp
- | -
q, Escape | コピーモードから抜ける
h,l,j,k | 移動
A-f/b, Tab/S-Tab, w/b | 次/前の単語へ移動
e | 次の単語の前へ移動
0  | 行の最初へ移動
^/$, C-a/C-e  | 行の最初/最後の文字へ移動
Space, v | 選択モードへ
S-v | 行を選択して選択モードへ
y | クリップボードにコピー
Y | 行の最後までコピー
g/G | 最初/最後の行へ
H/M/L | 画面上/中央/下へ
C-f/b | ページ下/上へ
o, O | 選択時に最初/最後へ
Enter | 選択時に選択解除
/ | 検索モードへ
n/N | 次/前のマッチへ

#### Search Mode

keymap | exp
- | -
C-u | 入力をクリア
C-r | 検索タイプを変更
C-n/N | 次/前のマッチへ
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

