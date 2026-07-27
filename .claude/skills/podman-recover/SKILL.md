---
name: podman-recover
description: >
  rootless podman + docker compose (make up 等) が SIGSEGV・デッドロック・
  devpts マウント失敗などで詰まった時の診断と復旧手順。
  「make up が失敗する」「podman.sock EOF」「error during connect」
  「container create でハングする」「crun mount devpts」と言われたら使う。
---

## 前提となる既知の障害パターン

このマシンは複数ユーザーが rootless podman を同時稼働させる共有環境。
`docker compose up` で多数サービス (数十コンテナ) を一括 create/start すると、
Podman API service (`podman.service`, user systemd unit) の内部で
rootless keep-id userns 設定処理が競合し、以下のいずれかが起きる:

1. **SIGSEGV** — cgo 経由の `libsubid` 呼び出し (`_Cfunc_subid_get_uid_ranges`)
   でクラッシュ。`journalctl --user -u podman.service` に
   `SIGSEGV: segmentation violation` と Go の goroutine dump が出る。
   既知 issue: containers/podman #20107 系統。
2. **デッドロック** — `podman ps` / `podman info` などの一覧系 API が応答せず
   ハング。`systemctl --user restart podman.service` を送っても SIGTERM に
   応答せずタイムアウトで SIGKILL される
   (`journalctl` に `State 'stop-sigterm' timed out. Killing.`)。
   既知 issue: containers/podman #27949 系統。
3. **壊れた IDマッピングを持つコンテナが残留** — 上記クラッシュ発生時に
   ちょうど create 処理中だったコンテナが、不完全な userns マッピング
   (`UidMap:["1001:0:1"]` のように 1 レンジしかない — 正常なコンテナは
   `["0:1:N","1001:0:1","1002:1002:M"]` のような 3 レンジ) のまま
   storage DB に保存されてしまう。このコンテナは `create` はできても
   `start` 時に `crun: mount devpts to dev/pts: Invalid argument` で
   必ず失敗する。再試行しても直らない (壊れているのはコンテナの永続状態)。

いずれも Podman 自体のバグ (goroutine 競合) が根本原因で、
アプリ側の設定ミスではない。`GOMAXPROCS` 環境変数で内部並列度
(`Setting parallel job count to N` のログに出る値) を下げる対策は
**効果が確認できなかった** (ログの値が変化しない) 上に、
`podman.service` の再起動自体が稼働中の全コンテナを `Created` 状態に
落とす副作用があるため割に合わない。試さないこと。

## 診断手順

1. `systemctl --user status podman.socket podman.service` — Active か確認
2. `journalctl --user -u podman.service --since "<失敗時刻>" | grep -v "GET\|HEAD\|POST"`
   で `SIGSEGV` / `Main process exited` / `Failed with result` / `timed out` を探す
3. `timeout 10 podman ps -a --filter name=<project-prefix>` で
   `Exited (137)` (SIGKILL跡) や `Created` のまま止まっているコンテナ、
   同名衝突で自動リネームされた重複コンテナ (`<hash>_<name>` 形式) を探す
4. 個別に怪しいコンテナがあれば
   `podman inspect <name> --format '{{json .HostConfig.IDMappings}}'` で
   レンジ数を比較する。他の正常なコンテナと比べてレンジ数が少なければ破損確定

## 復旧手順

壊れたコンテナが特定できていて被害が限定的なら、そのコンテナだけ削除して
compose に再作成させてもよい (`podman rm -f <name>`)。

ただし複数コンテナが `Exited (137)` や重複リネームで混乱している場合は
中途半端な削除は事態を悪化させる。プロジェクトの `make down` 相当
(`docker compose down --remove-orphans` 等、volume は消さないもの) で
一括クリーンにしてから `make up` 相当を再実行するのが最も確実。

```
make down   # または該当プロジェクトの compose down --remove-orphans
make up     # 再実行。多くの場合これで揃う
```

`make down` 後に `podman ps -a --filter name=<prefix>` で残留 0 件を
確認してから起動し直すこと。中途半端な状態のまま再試行を重ねると、
古いコンテナと新しいコンテナが名前衝突してさらに散らかる
(`<hash>_<name>` の重複コンテナが増殖する)。
