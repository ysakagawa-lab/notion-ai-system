#!/usr/bin/env bash
set -euo pipefail

# SportsPulse: ①初期おすすめデザイン構築スクリプト
# 対象: WordPress + JIN:R
# 使い方:
#   WP_PATH=/home/xxx/public_html/sportspulse.site \
#   WP="~/.local/bin/wp" \
#   bash scripts/sportspulse_phase1_design.sh

usage() {
  cat <<'USAGE'
Usage:
  WP_PATH=/path/to/wordpress WP=/path/to/wp bash scripts/sportspulse_phase1_design.sh

Options:
  -h, --help   このヘルプを表示

Example:
  WP_PATH=/home/c8178057/public_html/sportspulse.site \
  WP=$HOME/.local/bin/wp \
  bash scripts/sportspulse_phase1_design.sh
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

WP_PATH="${WP_PATH:-/home/c8178057/public_html/sportspulse.site}"
WP="${WP:-$HOME/.local/bin/wp}"

COLOR_MAIN="#1F4788"
COLOR_ACCENT="#FF6B35"
COLOR_BG="#FFFFFF"
COLOR_TEXT="#333333"
COLOR_SECONDARY="#D5E8F0"
COLOR_FOOTER_BG="#2E2E2E"
COLOR_FOOTER_TEXT="#FFFFFF"

log() {
  printf '[SportsPulse Phase1] %s\n' "$*"
}

run_wp() {
  "$WP" --path="$WP_PATH" "$@"
}

require_wp() {
  if [[ ! -x "$WP" ]] && ! command -v "$WP" >/dev/null 2>&1; then
    log "ERROR: WP-CLI が見つかりません: $WP"
    exit 1
  fi

  if ! "$WP" --path="$WP_PATH" core is-installed >/dev/null 2>&1; then
    log "ERROR: WordPress が見つかりません。WP_PATH を確認してください: $WP_PATH"
    exit 1
  fi
}

ensure_theme_active() {
  local theme_slug="jinr"
  local current_theme

  current_theme="$(run_wp option get stylesheet || true)"
  if [[ "$current_theme" != "$theme_slug" ]]; then
    log "JIN:R テーマを有効化します"
    run_wp theme activate "$theme_slug"
  else
    log "JIN:R はすでに有効です"
  fi
}

apply_site_basics() {
  log "サイト基本設定を適用します"
  run_wp option update blogname "SportsPulse - F1・サッカー・NBA 速報&解説"
  run_wp option update blogdescription "最新速報から深掘り解説まで、スポーツの鼓動をあなたに"
  run_wp option update timezone_string "Asia/Tokyo"
  run_wp option update show_on_front "posts"
  run_wp option update posts_per_page "10"
  run_wp option update default_comment_status "closed"
  run_wp rewrite structure '/%postname%/' --hard
}

apply_jinr_design() {
  log "JIN:R デザイン推奨値を theme_mods_jinr に適用します"

  run_wp eval "
    \$mods = get_option('theme_mods_jinr', []);
    if (!is_array(\$mods)) { \$mods = []; }

    \$mods['jinr_color_main'] = '$COLOR_MAIN';
    \$mods['jinr_color_accent'] = '$COLOR_ACCENT';
    \$mods['jinr_color_bg'] = '$COLOR_BG';
    \$mods['jinr_color_text'] = '$COLOR_TEXT';
    \$mods['jinr_color_sub_bg'] = '$COLOR_SECONDARY';
    \$mods['jinr_header_bg'] = '$COLOR_BG';
    \$mods['jinr_footer_bg'] = '$COLOR_FOOTER_BG';
    \$mods['jinr_footer_color'] = '$COLOR_FOOTER_TEXT';

    // 可読性と速報向けの推奨補助値
    \$mods['jinr_link_color'] = '$COLOR_MAIN';
    \$mods['jinr_link_hover_color'] = '$COLOR_ACCENT';
    \$mods['jinr_button_bg'] = '$COLOR_ACCENT';
    \$mods['jinr_button_color'] = '#FFFFFF';

    // ロゴ配置（センター）
    \$mods['jinr_header_logo_align'] = 'center';

    update_option('theme_mods_jinr', \$mods);
    echo 'theme_mods_jinr updated';
  "
}

print_next_actions() {
  cat <<TXT

=== Phase1 デザイン適用が完了しました ===

次に管理画面で確認してください:
1) 外観 > カスタマイズ > カラー
   - メイン: ${COLOR_MAIN}
   - アクセント: ${COLOR_ACCENT}
2) 外観 > カスタマイズ > ヘッダー
   - ロゴ配置: センター
3) 設定 > 表示設定
   - ホームページの表示: 最新の投稿

未実施（次フェーズ）:
- ロゴ / ファビコン / OGP画像
- ウィジェット（サイドバー / フッター）
- Ad枠・計測タグ導入
TXT
}

main() {
  log "開始: SportsPulse ①初期おすすめデザイン構築"
  require_wp
  ensure_theme_active
  apply_site_basics
  apply_jinr_design
  print_next_actions
  log "完了"
}

main "$@"
