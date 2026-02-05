# SportsPulse デザイン自動アップデート（公開前おすすめ）

公開前に、サイト全体の見た目を崩れにくく・見やすくするための自動適用手順です。

対象スクリプト: `scripts/sportspulse_design_refresh.sh`

## 何が変わるか

- JIN:R のカラーを SportsPulse 推奨値へ再適用
- ヘッダー/ナビの崩れ（縦並び・折返し崩壊）を防ぐ追加CSSを適用
- 投稿カードの視認性（角丸・影）を改善
- 見出し・フッターのコントラストを改善

## 1) まず確認だけ（dry-run）

```bash
cd ~/sportspulse
WP_PATH=/home/c8178057/public_html/sportspulse.site \
WP=$HOME/.local/bin/wp \
bash scripts/sportspulse_design_refresh.sh --dry-run
```

## 2) 実際に適用

```bash
cd ~/sportspulse
WP_PATH=/home/c8178057/public_html/sportspulse.site \
WP=$HOME/.local/bin/wp \
bash scripts/sportspulse_design_refresh.sh
```

## 3) 適用後チェック（管理画面）

- 外観 → カスタマイズ → 追加CSS
- 外観 → カスタマイズ → カラー設定
- トップページでナビの折返しや縦表示が改善しているか確認

## 補足

- すでに同じ値が設定済みの場合、見た目の変化が小さいことがあります。
- 反映されない場合はキャッシュ削除（スーパーリロード）を実施してください。

