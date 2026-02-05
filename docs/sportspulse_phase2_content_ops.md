# SportsPulse ② テキスト記事案から投稿・デザイン・Adを一括処理

この手順では、記事案テキストを1ファイル用意するだけで、以下をまとめて実行します。

- 投稿作成（draft / publish）
- カテゴリ・タグ付与（なければ自動作成）
- 本文末尾へのAdショートコード挿入
- CTAボタン挿入

実行スクリプト: `scripts/sportspulse_phase2_content_ops.sh`

---

## 1. まず最短で試す（dry-run）

```bash
cd ~/sportspulse
WP_PATH=/home/c8178057/public_html/sportspulse.site \
WP=$HOME/.local/bin/wp \
bash scripts/sportspulse_phase2_content_ops.sh \
  --input templates/article_idea_sample.txt \
  --dry-run
```

`--dry-run` は投稿を作らず、読み取った内容だけ表示します。

---

## 2. 下書き投稿を作る

```bash
cd ~/sportspulse
WP_PATH=/home/c8178057/public_html/sportspulse.site \
WP=$HOME/.local/bin/wp \
bash scripts/sportspulse_phase2_content_ops.sh \
  --input templates/article_idea_sample.txt
```

---

## 3. そのまま公開する

```bash
cd ~/sportspulse
WP_PATH=/home/c8178057/public_html/sportspulse.site \
WP=$HOME/.local/bin/wp \
bash scripts/sportspulse_phase2_content_ops.sh \
  --input templates/article_idea_sample.txt \
  --publish
```

---

## 4. 入力ファイルフォーマット

`templates/article_idea_sample.txt` をコピーして使ってください。

```txt
TITLE: 記事タイトル
SLUG: post-slug
CATEGORY: 速報,F1解説
TAGS: F1,分析
CTA_TEXT: メールで速報を受け取る
CTA_URL: /newsletter
AD_SLOT: in_article_1
EXCERPT: 抜粋テキスト
---BODY---
本文（Markdown可）
```

### 必須
- `TITLE`
- `---BODY---` 以降の本文

### 任意
- `SLUG`
- `CATEGORY`（カンマ区切り）
- `TAGS`（カンマ区切り）
- `CTA_TEXT` + `CTA_URL`
- `AD_SLOT`
- `EXCERPT`

---

## 5. 補足

- `AD_SLOT` は `[ad_slot id="..."]` で挿入されます。広告プラグイン側のショートコード仕様に合わせて、必要ならスクリプト内の書式を変更してください。
- まずは `--dry-run` で構文確認 → 問題なければ draft 生成 → 最後に `--publish` が安全です。

