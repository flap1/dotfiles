---
name: humanize-en
description: LLMっぽい英語を人の文章に直すチェックリストと書き換え手法。英語のピッチ・提案書・記事・スライドを書く/直すとき、日本語資料を英訳したとき、「AIが書いたみたい」と言われたとき、提出前の最終監査に使う。humanize-ja の英語版。英語固有のLLM癖と、和文英訳臭 (translationese) の両方を扱う。
---

# humanize-en — LLM英語を人の文章に直す

英語で出す前に必ずこのリストを通す。1項目でも引っかかったら直す。
目的は「短くする」ことではなく「機械が書いた痕跡を消す」こと。

日本語資料の英訳では、**英語LLMの癖 (§1)** と **和文英訳臭 (§2)** の両方が出る。両方通す。

想定読者が米国ネイティブと非ネイティブ (欧州・アジアの投資家など) の混在なら、
**イディオムとスポーツ比喩は捨て、構文は英語として自然なまま**にする。
"moving the goalposts" / "out of the park" / "table stakes" は通じない相手がいる。
"we simplify" は誰にでも通じる。難しいのは語彙ではなくリズムの方。

## 1. 英語LLMの兆候チェックリスト

### 語彙 — 出たら疑う
- [ ] **LLMシグネチャ語**: delve, leverage (動詞), seamless(ly), robust, streamline, empower, unlock, harness, foster, navigate (比喩), landscape (比喩), realm, tapestry, testament, pivotal, crucial, vital, myriad, plethora, holistic, cutting-edge, state-of-the-art, game-changer, paradigm shift
- [ ] **副詞の水増し**: significantly, dramatically, effectively, efficiently, truly, incredibly, remarkably。消して意味が変わらないなら消す
- [ ] **hedge の重ね掛け**: "may potentially help to somewhat improve" → "helps"
- [ ] **名詞化 (nominalization)**: "provide an improvement in" → "improves" / "the implementation of X" → "building X"
- [ ] **企業テンプレ語**: solution, offering, ecosystem, journey, at scale, best-in-class, mission-critical。製品名か動詞に置き換える

### 構文 — LLMの指紋
- [ ] **"It's not just X — it's Y" / "This isn't X. It's Y."** LLM最頻出の型。1文書に0回が理想
- [ ] **"Not only ... but also ..."** ほぼ常に2文に割れる
- [ ] **em-dash の連鎖**: 1段落に2本以上の "—" はLLM。ピリオドかカンマにする
- [ ] **rule of three の乱発**: "faster, cheaper, and more reliable" が3段落続く。1回まで
- [ ] **並列の対句**: "X does A. Y does B. Z does C." 同型3連。1つ崩す
- [ ] **分詞構文の頭出し**: "Leveraging X, we ..." / "Building on Y, the system ..." が段落頭に並ぶ
- [ ] **文長が均一**: 全部18〜25語。4語の文を混ぜる
- [ ] **段落が全部3文**: 1文だけの段落を作る
- [ ] **"In today's ~" / "As organizations increasingly ~"** で始まる導入。切って本題から始める
- [ ] **締めの説教段落**: "By doing X, teams can finally focus on what matters most." 削る

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
そこがLLMの文。**LLMは平均文長に収束する。人間の文はばらつく。**

スライドは特に: 1行が2秒で読めるか。読めない行は文でなく句にする。

## 5. 自己監査プロンプト（最終パス）

> Review the text below in two roles.
> 1) Target reader (a seed-stage VC partner, 90 seconds of attention): list every
>    claim without a number, a proper noun, or a source; list every logical jump.
> 2) AI-text detector: list every item from the checklist above, with the exact
>    span quoted. Count em-dashes and "not just X" constructions explicitly.
> Then rewrite. Do not invent facts or numbers — mark anything missing as [VERIFY].

## 6. 例外 — 直さなくてよいもの

- 図中のラベル・表の見出し・スライドのキーワードは名詞句でよい（図は文章ではない）
- 製品名・機能名の固有名詞（"Session", "Package"）はそのまま
- 法令・公募要領・契約書の引用は原文のまま
- 業界の定訳 (MBSE, RDM, ARR, NRR) は展開せずそのまま。ただし初出だけ7語以内で補足
- 技術文書の手順書は文長が揃っていてよい（リズムより走査性が優先）

関連: [[humanize-ja]] — 日本語版。日本語資料と英語版を並行で持つときは両方通す。
