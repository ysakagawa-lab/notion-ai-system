#!/usr/bin/env bash
set -euo pipefail

# SportsPulse: 公開前デザイン自動アップデート（推奨プリセット）

usage() {
  cat <<'USAGE'
Usage:
  WP_PATH=/path/to/wp-root WP=/path/to/wp \
  bash scripts/sportspulse_design_refresh.sh [--dry-run]

Options:
  --dry-run   変更内容のみ表示（実際の更新を行わない）
  -h, --help  ヘルプ表示
USAGE
}

WP_PATH="${WP_PATH:-/home/c8178057/public_html/sportspulse.site}"
WP="${WP:-$HOME/.local/bin/wp}"
DRY_RUN="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

log() {
  printf '[DesignRefresh] %s\n' "$*"
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

preview_plan() {
  cat <<TXT
=== SportsPulse Design Refresh Plan ===
1) JIN:R 推奨カラーを再適用
2) ヘッダー/ナビを横並びで崩れにくくする追加CSSを適用
3) 投稿カード・フッター・見出しの視認性を改善
TXT
}

apply_theme_mods() {
  log "JIN:R の theme_mods を更新します"
  run_wp eval '
    $mods = get_option("theme_mods_jinr", []);
    if (!is_array($mods)) { $mods = []; }

    $mods["jinr_color_main"] = "#1F4788";
    $mods["jinr_color_accent"] = "#FF6B35";
    $mods["jinr_color_bg"] = "#FFFFFF";
    $mods["jinr_color_text"] = "#333333";
    $mods["jinr_color_sub_bg"] = "#D5E8F0";
    $mods["jinr_header_bg"] = "#FFFFFF";
    $mods["jinr_footer_bg"] = "#1F2E5F";
    $mods["jinr_footer_color"] = "#FFFFFF";
    $mods["jinr_link_color"] = "#1F4788";
    $mods["jinr_link_hover_color"] = "#FF6B35";
    $mods["jinr_button_bg"] = "#FF6B35";
    $mods["jinr_button_color"] = "#FFFFFF";
    $mods["jinr_header_logo_align"] = "center";

    update_option("theme_mods_jinr", $mods);
    echo "theme_mods_jinr updated\n";
  '
}

apply_custom_css() {
  log "追加CSS（ナビ崩れ防止 + 視認性改善）を適用します"

  run_wp eval <<'PHP'
$css = <<<'CSS'
/* SportsPulse auto design refresh */
.p-header, .l-header { box-shadow: 0 2px 12px rgba(31,71,136,0.08); }

/* ナビ崩れ防止 */
.p-globalnavi__list,
.cps-post-main .p-globalnavi__list,
.p-global-nav ul {
  display: flex !important;
  flex-wrap: wrap;
  gap: 4px 14px;
}
.p-globalnavi__list > li,
.p-global-nav ul > li {
  white-space: nowrap;
}
.p-globalnavi__list > li > a,
.p-global-nav ul > li > a {
  font-weight: 700;
  letter-spacing: .02em;
}

/* カード可読性 */
.cps-post,
.p-archive-card,
.c-entry-card {
  border-radius: 12px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.06);
  overflow: hidden;
}

/* 見出しアクセント */
.entry-content h2,
.c-entry__content h2 {
  border-left: 5px solid #FF6B35;
  padding-left: 10px;
}

/* フッター */
.p-footer,
.l-footer {
  background: #1F2E5F !important;
  color: #fff !important;
}
CSS;

if (function_exists('wp_update_custom_css_post')) {
  $result = wp_update_custom_css_post($css);
  if (is_wp_error($result)) {
    echo 'custom_css update failed: ' . $result->get_error_message() . "\n";
    exit(1);
  }
  echo "custom_css updated\n";
} else {
  echo "wp_update_custom_css_post is unavailable\n";
}
PHP
}

main() {
  require_wp
  preview_plan

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY-RUN: 実更新は行っていません"
    exit 0
  fi

  apply_theme_mods
  apply_custom_css
  log "完了: 外観 > カスタマイズ > 追加CSS / カラー設定 を確認してください"
}

main
