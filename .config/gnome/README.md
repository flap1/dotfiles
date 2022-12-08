# Gnome

## Extensions Sync

* Install from  <https://extensions.gnome.org/extension/1486/extensions-sync/>
* open gnome-extension and set "Local" and "~/.config/gnome/extensions-sync.json"

```bash
busctl --user call org.gnome.Shell /io/elhan/ExtensionsSync io.elhan.ExtensionsSync save # uploads to server
busctl --user call org.gnome.Shell /io/elhan/ExtensionsSync io.elhan.ExtensionsSync read # downloads to pc
```


## Keybind

### dash-to-dock

基本BrowserとEditorにいるのでそれぞれホームポジションにマッピング

* dconf Editor > `/org/gnome/shell/extensions/dash-to-dock/app-hotkey-1`: ['<Super>1', '<Super>f']
* dconf Editor > `/org/gnome/shell/extensions/dash-to-dock/app-hotkey-4`: ['<Super>1', '<Super>j']

アプリ Browser, Filer, Slack, Editor の順に配置している

