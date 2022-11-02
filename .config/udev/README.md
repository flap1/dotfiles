# Remap Keymap for Wayland

他の人が自身のパソコンを少し使うことを考え, 半角全角キーはそのままにしている

* At Udev
    * CapsLock -> Ctrl
    * Right Alt -> 全角半角キー
    * 変換キー -> Backspace
    * 無変換キー -> Escape
* At Mozc Setting
    * カタカナキー -> IME無効化
    * ひらがなキー -> IMU無効化


## 設定

`.hwdb`ファイルは`/etc/udev/hwdb.d/` or `/lib/udev/hwdb.d/`に配置する

```bash
# 書式
変更したいハードウェア情報
 変更したいキー(複数指定可能)

# ハードウェア情報
## 全てのAT キーボードにマッチ
evdev:atkbd:dmi:bvn*:bvr*:bd*:svn*:pn*:pvr

## 特定のキーボードのみにマッチ
evdev:input:b<bus_id>v<vender_id>p<product_id>*
# bus_id, vender_id, product_id: cat /proc/bus/input/devices の該当デバイスの I: Bus=<bus_id> Vendor=<vendor_id> Product=<product_id>

# 変更したいキー
 KEYBOARD_KEY_<value>=<key_code>
# sudo evtest (sudo apt install -y evtest) の該当デバイス選択後, キーをタイプ
# 例: 半角全角キーをタイプしたとき
## Event: time 1667316215.073370, -------------- SYN_REPORT ------------
## Event: time 1667316216.634132, type 4 (EV_MSC), code 4 (MSC_SCAN), value 29
## Event: time 1667316216.634132, type 1 (EV_KEY), code 41 (KEY_GRAVE), value 1
# このときvalue: 29, key_code: grave
# Escに割当てる際にはkey_code: escとなればいいので, KEYBOARD_KEY_29=grave とするばよい
```

設定を反映させる

```bash
sudo systemd-hwdb update && sudo udevadm trigger
```

反映の確認

```bash
udevadm info /dev/input/by-path/* | grep KEYBOARD_KEY
```

