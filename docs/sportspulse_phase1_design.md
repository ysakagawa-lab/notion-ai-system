# SportsPulse ①初期おすすめデザイン構築（実行パッケージ）

このドキュメントは、SportsPulse サイトの**初期デザインを最短で再現**するための手順です。  
対象環境は WordPress + JIN:R です。

## 0. これをどうやって実行する？（最短版）

```bash
cd /workspace/notion-ai-system
WP_PATH=/home/c8178057/public_html/sportspulse.site \
WP=$HOME/.local/bin/wp \
bash scripts/sportspulse_phase1_design.sh
```

> これで①の初期デザイン設定が一括反映されます。

ヘルプを見たい場合:

```bash
bash scripts/sportspulse_phase1_design.sh --help
```

## 1. 目的

- SportsPulse のブランドトーン（信頼感 + エネルギー）を統一。
- WP-CLI で初期デザイン設定を一括適用。
- 以降の運用（②記事案だけで投稿/装飾/広告管理）へ接続しやすい状態を作る。

## 2. 実行前チェック

- WordPress がインストール済みであること
- `WP_PATH` が WordPress ルートディレクトリを指していること
- `WP` が実行可能な wp-cli バイナリを指していること

確認コマンド例:

```bash
$HOME/.local/bin/wp --info
$HOME/.local/bin/wp --path=/home/c8178057/public_html/sportspulse.site core is-installed
```

## 3. 適用内容（①で実施）

`scripts/sportspulse_phase1_design.sh` で、以下を自動反映します。

- サイト基本値
  - タイトル / キャッチフレーズ
  - タイムゾーン（Asia/Tokyo）
  - 投稿表示（最新投稿）
  - 1ページ表示件数（10）
  - コメント無効
  - パーマリンク `/%postname%/`
- テーマ有効化確認
  - `jinr` が未有効なら自動で有効化
- JIN:R の初期カラー・UI推奨値
  - メイン `#1F4788`
  - アクセント `#FF6B35`
  - 背景 `#FFFFFF`
  - テキスト `#333333`
  - セカンダリ `#D5E8F0`
  - フッター背景 `#2E2E2E`
  - フッターテキスト `#FFFFFF`
  - リンク / ボタン / ホバー色
  - ヘッダーロゴ配置（center）

## 4. 実行後チェックリスト（管理画面）

- 外観 → カスタマイズ → カラー
- 外観 → カスタマイズ → ヘッダー（ロゴ配置: center）
- 設定 → 表示設定（ホーム: 最新の投稿）

## 5. 次フェーズ（②に向けた準備）

①完了後に、以下をテンプレート化すると運用自動化が容易です。

- 記事案入力フォーマット（タイトル/要点/CTA/カテゴリ）
- 投稿時自動処理（アイキャッチ・内部リンク・広告挿入）
- 公開前チェック（NGワード、重複、SEO最小要件）
- 公開後配信（SNS/ニュースレター）

