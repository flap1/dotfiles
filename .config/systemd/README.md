# Systemd

すべて **user unit**。system unit にすると `User=`/`Group=` と `/home/<user>` を
直書きすることになり、別アカウントでは壊れる。user unit なら `%h` で済む。

インストール手順は共通:

```bash
mkdir -p ~/.config/systemd/user
cp ~/dotfiles/.config/systemd/user/<unit> ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now <unit>
```

ログイン前・ログアウト後も動かすなら linger を有効にする（マウント系や常駐は必須）:

```bash
loginctl enable-linger "$USER"
```

## google-drive-ocamlfuse

Google Drive を `~/gdrive/m` にマウント。

```bash
sudo add-apt-repository ppa:alessandro-strada/ppa
sudo apt-get update
sudo apt-get install google-drive-ocamlfuse

# 認証 (ブラウザが開く。unit を enable する前に一度手で通す)
google-drive-ocamlfuse
```

```bash
systemctl --user enable --now google-drive-ocamlfuse
```

## mcp-cloudwatch@

テンプレート unit。インスタンスごとに
`~/.config/mcp/env/cloudwatch-<instance>.env` を読む。

```bash
systemctl --user enable --now mcp-cloudwatch@<instance>
```

## xkeysnail (setup not completed)

```bash
sudo apt install python3-pip
sudo pip3 install xkeysnail
```

```bash
systemctl --user enable --now xkeysnail
```
