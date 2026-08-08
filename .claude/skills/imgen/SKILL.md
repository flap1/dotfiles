---
name: imgen
description: 画像を生成する。Codex CLI の組み込み image_gen (gpt-image-2) を ChatGPT subscription 枠で叩き、出た PNG を Read して確認する。「画像作って」「アイコン生成」「図版を出して」「バナー作って」「この画像を直して」と言われたら使う。プロンプト文面の原則は image-gen-prompts 側。
---

# imgen

Claude 自身は画像を生成できない。Codex CLI の組み込み `image_gen` に投げる。
API キー不要、ChatGPT subscription 枠で課金される (`~/.codex/auth.json` の
`auth_mode: chatgpt`)。

## 手順

### 1. プロンプトを組む

文面の原則は `image-gen-prompts` skill に従う。そのうえで Codex 側の
image-gen skill が使うラベル形式に整えて渡す。整えて渡さないと Codex 側が
自前で書き直しにかかって往復が増える。

埋めない行は落とす。全部埋める必要はない。

```text
Use case: <text-to-image | edit | compositing | sketch-to-render>
Asset type: <どこで使うか。スライド1枚 / favicon / OG画像 / README のヒーロー>
Primary request: <主題>
Subject: <被写体>
Scene/backdrop: <背景・環境>
Style/medium: <flat illustration / photo / 3D render / line art>
Composition/framing: <wide|close|top-down、被写体の配置>
Lighting/mood:
Color palette:
Text (verbatim): "<画像に入れる文字を一字一句>"
Constraints: <維持するもの>
Avoid: <入れてはいけないもの>
```

### 2. 投げる

```bash
mkdir -p /tmp/imgen && codex exec -C /tmp/imgen --skip-git-repo-check \
  -o /tmp/imgen/last.txt \
  "Use the image_gen tool to generate this image. Do not write code, do not
   read files, do not run shell commands. Just generate.

   <上のラベル形式のスペック>"
```

- `-C /tmp/imgen` が重要。プロジェクト内で走らせると AGENTS.md を読んで
  コードを探しに行き、トークンを無駄に食う
- 保存先は cwd ではなく `~/.codex/generated_images/<thread_id>/<call_id>.png` 固定
- 最終メッセージ (`/tmp/imgen/last.txt`) に絶対パスが出る

### 3. 見る

出た PNG を `Read` する。Claude Code は画像を表示できるので、自分で仕上がりを
確認してから次に進む。確認せずに「できました」と言わない。

### 4. 直す

```bash
codex exec -C /tmp/imgen resume --last "<変更点>"
```

同じ thread なら直近5枚まで元画像を参照して img2img になる。新規 exec だと
参照が切れて別物が出る。指示は「X だけ変えて Y は維持」の形にする。

### 5. 置く

使う場所に `cp` する。`~/.codex/generated_images/` 側の元ファイルは消さない
(Codex が次の edit 参照に使う)。

## 制約

- `size` / `quality` は `auto` ハードコードで指定できない。実測 1254x1254 が出た
- 1回あたり 3〜4万トークン食う。Codex 側の image-gen skill が丸ごとロードされる
  ため。subscription の週次枠を消費するので連射しない
- 非 OpenAI provider (`--oss` 等) では `image_gen` が無効になる
- 保存先は `CODEX_HOME` 配下 (既定 `~/.codex/generated_images/`)
- ChatGPT auth 専用。Free プランでは使えない

## subscription 枠を使わない場合

ドラフトを大量に回すなら API 直叩き。ただし安くはない (2026-08 時点、1024x1024):

| model | low / medium | high | batch |
|---|---|---|---|
| gpt-image-2 | $0.04 | $0.12 | 半額 ($0.02 / $0.06) |
| gpt-image-1.5 | $0.04 | $0.13 | 半額 |
| gpt-image-1-mini | $0.01 | $0.03 | 半額 ($0.005 / $0.015) |

ドラフト用の最安は `gpt-image-1-mini` の low。仕上げだけ `gpt-image-2` の high に回す。

```bash
curl -s https://api.openai.com/v1/images/generations \
  -H "Authorization: Bearer $OPENAI_API_KEY" -H 'Content-Type: application/json' \
  -d '{"model":"gpt-image-1-mini","prompt":"...","size":"1024x1024","quality":"low"}' \
  | jq -r '.data[0].b64_json' | base64 -d > out.png
```

文字入り・日本語混じりの図版は Gemini が強い。`gemini-3-pro-image` (Nano Banana Pro)
$0.134/枚 (1K/2K)、廉価版の `gemini-3.1-flash-image` (Nano Banana 2) $0.067/枚 (1K)。

## 出典

単価は動く。使う前に見る。

- [OpenAI API pricing](https://developers.openai.com/api/docs/pricing)
- [Gemini API pricing](https://ai.google.dev/gemini-api/docs/pricing)
