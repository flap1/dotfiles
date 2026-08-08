---
name: humanize-en
description: LLMっぽい英語を人の文章に直すチェックリストと書き換え手法。英語のピッチ・提案書・記事・スライドを書く/直すとき、日本語資料を英訳したとき、「AIが書いたみたい」と言われたとき、提出前の最終監査に使う。humanize-ja の英語版。英語固有のLLM癖と、和文英訳臭 (translationese) の両方を扱う。
---

# humanize-en — LLM英語を人の文章に直す

英語で出す前に必ずこのリストを通す。1項目でも引っかかったら直す。
目的は「短くする」ことではなく「機械が書いた痕跡を消す」こと。

日本語資料の英訳では、英語LLMの癖 (§1) と 和文英訳臭 (§2) の両方が出る。両方通す。

想定読者が米国ネイティブと非ネイティブ (欧州・アジアの投資家など) の混在なら、
イディオムとスポーツ比喩は捨て、構文は英語として自然なままにする。
"moving the goalposts" / "out of the park" / "table stakes" は通じない相手がいる。
"we simplify" は誰にでも通じる。難しいのは語彙ではなくリズムの方。

## 1. 英語LLMの兆候チェックリスト

### 語彙 — 出たら疑う

疑うのは動詞と形容詞。2024年の超過語 379 個は 66% が動詞・14% が形容詞で、COVID 期の
名詞中心とは逆だった。痕跡は話題ではなく言い回しに出る。実測の超過比は delves 28.0倍、
underscores 13.8倍、showcasing 10.7倍 (Kobak et al.)。名詞の珍しさは兆候にならない。

- [ ] **LLMシグネチャ語 (第1世代・2023〜2024)**: delve, intricate, underscore, tapestry, testament,
      pivotal, realm, meticulous, boast, garner, landscape (比喩), navigate (比喩),
      leverage (動詞), seamless(ly), robust, streamline, empower, unlock, harness, foster,
      crucial, vital, myriad, plethora, holistic, cutting-edge, state-of-the-art, game-changer
- [ ] **シグネチャ語 (第2世代・2025〜2026)**: align with, enhance, foster, showcase, highlight,
      emphasize。古い禁止リストだけ見ていると現行世代を見逃す。
      特に -ing の尾ひれ (下記) と組んで出る
- [ ] **分詞の尾ひれ**: 文末に ", highlighting the importance of ~" / ", emphasizing ~" /
      ", underscoring ~" を付けて深みを装う型。現行世代で最も出る。文ごと削るか、主張なら独立した文にする
- [ ] **be動詞の回避**: is/are を serves as / marks / functions as / features / maintains に
      置き換える癖。"X is a tool for Y" でいい場面で "X serves as a tool for Y" と書いていたら戻す
- [ ] **副詞の水増し**: significantly, dramatically, effectively, efficiently, truly, incredibly, remarkably。消して意味が変わらないなら消す
- [ ] **hedge の重ね掛け**: "may potentially help to somewhat improve" → "helps"
- [ ] **名詞化 (nominalization)**: "provide an improvement in" → "improves" / "the implementation of X" → "building X"
- [ ] **企業テンプレ語**: solution, offering, ecosystem, journey, at scale, best-in-class, mission-critical。製品名か動詞に置き換える

### 構文 — LLMの指紋
- [ ] **否定の対句**: "It's not just X — it's Y" / "This isn't X. It's Y." / "X rather than Y"。
      LLM最頻出の型。1文書に0回が理想
- [ ] **"Not only ... but also ..."** ほぼ常に2文に割れる
- [ ] **em-dash の連鎖**: 1段落に2本以上の "—" はLLM。ピリオドかカンマにする
- [ ] **rule of three の乱発**: "faster, cheaper, and more reliable" が3段落続く。1回まで
- [ ] **並列の対句**: "X does A. Y does B. Z does C." 同型3連。1つ崩す
- [ ] **分詞構文の頭出し**: "Leveraging X, we ..." / "Building on Y, the system ..." が段落頭に並ぶ
- [ ] **文長が均一**: 全部18〜25語。4語の文を混ぜる
- [ ] **段落が全部3文**: 1文だけの段落を作る
- [ ] **"In today's ~" / "As organizations increasingly ~"** で始まる導入。切って本題から始める
- [ ] **締めの説教段落**: "By doing X, teams can finally focus on what matters most." 削る

### 体裁 — 文章ではなく見た目に出る指紋

Anthropic が公開しているシステムプロンプトは、文書・説明は箇条書きと番号付きリストと
過剰な太字を使わず散文で書けと明示している。下は指示違反ではなく守り損ねの形。

- [ ] **見出しの Title Case**: "How We Built The Map" のように主要語を全部大文字にする癖。
      通常の英文記事は sentence case
- [ ] **太字の乱用**: 段落中のキーワードを機械的に太字にする。特に "Key takeaway:" 型
- [ ] **見出し+縦リストの入れ子**: 短い見出しに毎回 3〜4 個の箇条書きがぶら下がる均一な構造。
      散文で書ける部分は散文に戻す

### 内容
- [ ] **数字も固有名詞もない文**: (a) 数字を足す (b) 固有名詞を足す (c) 削る、のどれかにする
- [ ] **出典なしの引用**: "studies show" / "research suggests" → 調査名・年・n を書く
- [ ] **当事者性の欠如**: 誰の経験かわからない一般論。"We saw this at ..." を1〜2文入れる
- [ ] **主張の希釈**: "can help teams to potentially reduce" → "cuts". 弱めるなら数字で弱める
- [ ] **文脈の飛び**: 前の文と次の文の間で読者が推論を要求される

## 2. 和文英訳臭 (translationese) チェックリスト

日本語原文があるときだけ通す。英語ネイティブが読んで「訳文だ」と分かる兆候。

- [ ] **主語の取り違え**: 日本語の主語なし文を "It is ~" / "There is ~" で受けている。動作主を主語に立て直す
      「導入の手間を減らす」→ ✗ "It reduces the burden of introduction" → ✓ "Teams get running in a day"
- [ ] **過剰な丁寧さ**: "We would like to", "Please kindly", "We are pleased to". 投資家向け英語では弱く見える
- [ ] **和製英語・逆輸入カタカナ**: solution / merit / claim / cost performance / know-how / brush up / consensus building を日本語の意味で使っている
- [ ] **話題化の直訳**: 「〜については」→ "Regarding ~", "As for ~", "In terms of ~" の連発
- [ ] **「〜という」の残骸**: "the fact that", "the thing called", "so-called"
- [ ] **接続の直訳**: 「これにより」→ "Thereby" / "By this" / "Through this". 大半は不要か "so"
- [ ] **体言止めの直訳**: 日本語の名詞止め見出しを名詞句のまま訳して、動詞のない見出しが並ぶ
- [ ] **一文が長すぎる**: 日本語の読点で繋いだ長文をカンマで繋いだまま。ピリオドで割る
- [ ] **固有名詞の説明不足**: 日本の制度・組織 (SBIR, 中小機構, 宇宙戦略基金) を無説明で出す。初出に7語以内の説明を付ける
- [ ] **数字の単位**: 円をドル換算で勝手に書き換えない。"¥12M (about $80K)" のように併記するか、円のまま置く
- [ ] **日付形式**: 2026/08/07 → "August 2026" か "2026-08-07"。米欧で 08/07 の読みが割れる

## 3. 書き換えの手筋

| 癖 | 直し方 | 例 |
|---|---|---|
| LLMシグネチャ語 | 動詞を具体に | "leverage existing data" → "read the data you already have" |
| 名詞化 | 動詞に戻す | "the reduction of setup time" → "setup takes minutes" |
| "not just X, it's Y" | Yだけ書く | "It's not just a map — it's a shared model." → "It's a shared model." |
| rule of three | 2つに削るか1つを具体に | "faster, cheaper, safer" → "half the setup time" |
| 抽象 | 具体1例で置換 | "various tools" → "Slack and Google Drive" |
| hedge重ね | 1つに | "may potentially help" → "helps" |
| 対句3連 | 1つを疑問文か短文に | 3文目を "Nobody owns it." にする |
| translationese の "It is ~" | 動作主を主語に | "It is possible to ~" → "You can ~" |
| 過剰な丁寧さ | 平叙に | "We would like to propose" → "We propose" / 削る |

## 4. 音読テスト

書き終えたら声に出す。息継ぎの位置が全部同じ、または一度も息継ぎできない文があれば、
そこがLLMの文。LLMは平均文長に収束する。人間の文はばらつく。

スライドは特に: 1行が2秒で読めるか。読めない行は文でなく句にする。

## 5. 自己監査プロンプト（最終パス）

> Review the text below in two roles.
> 1) Target reader (a seed-stage VC partner, 90 seconds of attention): list every
>    claim without a number, a proper noun, or a source; list every logical jump.
> 2) AI-text detector: list every item from the checklist above, with the exact
>    span quoted. Count em-dashes and "not just X" constructions explicitly.
> Then rewrite. Do not invent facts or numbers — mark anything missing as [VERIFY].

## 6. 出典 (2026-08 確認)

- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
  — WikiProject AI Cleanup が実際の編集から継続更新している兆候カタログ。世代別の語彙、
  否定の対句、分詞の尾ひれ、be動詞の回避、体裁の癖はここが出所
- [Kobak et al., Delving into LLM-assisted writing in biomedical publications through excess
  vocabulary (Science Advances, 2025)](https://www.science.org/doi/10.1126/sciadv.adt3813)
  — PubMed の1500万件 (2010-2024) から、ChatGPT 公開後に頻度が跳ねた語を統計的に特定。
  2024年の抄録の少なくとも 13.5% が LLM を通っていると推定 (分野によっては 40%)
- [Claude のシステムプロンプト (Anthropic 公式)](https://platform.claude.com/docs/en/release-notes/system-prompts)
  — モデルごとに全文公開されている。文章の作法を明示的に指示していて、下の「散文で書く」
  「太字を減らす」はここが根拠。リークを漁る必要はない

シグネチャ語は世代で入れ替わる。半年ごとに上の3つを見直す。

## 7. 例外 — 直さなくてよいもの

- 図中のラベル・表の見出し・スライドのキーワードは名詞句でよい（図は文章ではない）
- 製品名・機能名の固有名詞（"Session", "Package"）はそのまま
- 法令・公募要領・契約書の引用は原文のまま
- 業界の定訳 (MBSE, RDM, ARR, NRR) は展開せずそのまま。ただし初出だけ7語以内で補足
- 技術文書の手順書は文長が揃っていてよい（リズムより走査性が優先）

関連: [[humanize-ja]] — 日本語版。日本語資料と英語版を並行で持つときは両方通す。
