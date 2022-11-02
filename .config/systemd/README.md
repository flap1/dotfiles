# Systemd


## google-drive-ocamlfuse

Google Driveのマウント

```bash
# Install
sudo add-apt-repository ppa:alessandro-strada/ppa
sudo apt-get update
sudo apt-get install google-drive-ocamlfuse

# 認証
google-drive-ocamlfuse
```

```bash
sudo cp ~/dotfiles/.config/systemd/system/google-drive-ocamlfuse.service /etc/systemd/system/google-drive-ocamlfuse.service
sudo systemctl daemon-reload
sudo systemctl enable google-drive-ocamlfuse.service
```

## xkeysnail (setup not completed)

```bash
sudo apt install python3-pip
sudo pip3 install xkeysnail
```

```bash
ln ~/dotfiles/.config/systemd/user/xkeysnail.service ~/.config/systemd/user/xkeysnail.service
systemctl daemon-reload
systemctl --user enable google-drive-ocamlfuse
```
