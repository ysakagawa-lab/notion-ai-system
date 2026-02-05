#!/usr/bin/env bash
set -euo pipefail

# SportsPulse: ②記事案テキスト投入→投稿/デザイン/Ad 一括処理

usage() {
  cat <<'USAGE'
Usage:
  WP_PATH=/path/to/wp-root WP=/path/to/wp \
  bash scripts/sportspulse_phase2_content_ops.sh --input templates/article_idea_sample.txt [--publish] [--dry-run]

Options:
  --input <file>   記事案テキストファイル（必須）
  --publish        公開状態で投稿（デフォルト: draft）
  --dry-run        投稿作成はせず、解釈結果だけ表示
  -h, --help       ヘルプ表示
USAGE
}

WP_PATH="${WP_PATH:-/home/c8178057/public_html/sportspulse.site}"
WP="${WP:-$HOME/.local/bin/wp}"
INPUT_FILE=""
POST_STATUS="draft"
DRY_RUN="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      INPUT_FILE="${2:-}"
      shift 2
      ;;
    --publish)
      POST_STATUS="publish"
      shift
      ;;
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

if [[ -z "$INPUT_FILE" ]]; then
  echo "ERROR: --input は必須です" >&2
  usage
  exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "ERROR: 入力ファイルが見つかりません: $INPUT_FILE" >&2
  exit 1
fi

run_wp() {
  "$WP" --path="$WP_PATH" "$@"
}

require_wp() {
  if [[ ! -x "$WP" ]] && ! command -v "$WP" >/dev/null 2>&1; then
    echo "ERROR: WP-CLI が見つかりません: $WP" >&2
    exit 1
  fi
  if ! "$WP" --path="$WP_PATH" core is-installed >/dev/null 2>&1; then
    echo "ERROR: WordPress が見つかりません。WP_PATH を確認してください: $WP_PATH" >&2
    exit 1
  fi
}

trim() {
  local s="$*"
  s="${s#${s%%[![:space:]]*}}"
  s="${s%${s##*[![:space:]]}}"
  printf '%s' "$s"
}

TITLE=""
SLUG=""
CATEGORY_CSV=""
TAGS_CSV=""
CTA_TEXT=""
CTA_URL=""
AD_SLOT=""
EXCERPT=""
BODY=""

parse_input() {
  local in_body="0"
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "---BODY---" ]]; then
      in_body="1"
      continue
    fi

    if [[ "$in_body" == "1" ]]; then
      BODY+="$line"$'\n'
      continue
    fi

    case "$line" in
      TITLE:*) TITLE="$(trim "${line#TITLE:}")" ;;
      SLUG:*) SLUG="$(trim "${line#SLUG:}")" ;;
      CATEGORY:*) CATEGORY_CSV="$(trim "${line#CATEGORY:}")" ;;
      TAGS:*) TAGS_CSV="$(trim "${line#TAGS:}")" ;;
      CTA_TEXT:*) CTA_TEXT="$(trim "${line#CTA_TEXT:}")" ;;
      CTA_URL:*) CTA_URL="$(trim "${line#CTA_URL:}")" ;;
      AD_SLOT:*) AD_SLOT="$(trim "${line#AD_SLOT:}")" ;;
      EXCERPT:*) EXCERPT="$(trim "${line#EXCERPT:}")" ;;
    esac
  done < "$INPUT_FILE"

  BODY="$(trim "$BODY")"

  if [[ -z "$TITLE" || -z "$BODY" ]]; then
    echo "ERROR: TITLE と BODY は必須です（BODYは ---BODY--- 以降）" >&2
    exit 1
  fi
}

build_post_content() {
  local content="$BODY"

  if [[ -n "$AD_SLOT" ]]; then
    content+=$'\n\n<!-- wp:shortcode -->\n'
    content+="[ad_slot id=\"$AD_SLOT\"]"
    content+=$'\n<!-- /wp:shortcode -->\n'
  fi

  if [[ -n "$CTA_TEXT" && -n "$CTA_URL" ]]; then
    content+=$'\n\n<!-- wp:buttons -->\n<div class="wp-block-buttons">\n'
    content+="  <!-- wp:button {\"backgroundColor\":\"vivid-red\"} -->\n"
    content+="  <div class=\"wp-block-button\"><a class=\"wp-block-button__link has-vivid-red-background-color has-background wp-element-button\" href=\"$CTA_URL\">$CTA_TEXT</a></div>\n"
    content+="  <!-- /wp:button -->\n"
    content+="</div>\n<!-- /wp:buttons -->\n"
  fi

  printf '%s' "$content"
}

ensure_terms() {
  local taxonomy="$1"
  local csv="$2"
  local IFS=','
  read -ra items <<< "$csv"
  for raw in "${items[@]}"; do
    local name
    name="$(trim "$raw")"
    [[ -z "$name" ]] && continue

    if ! run_wp term exists "$name" "$taxonomy" >/dev/null 2>&1; then
      run_wp term create "$taxonomy" "$name" >/dev/null
    fi
  done
}

create_post() {
  local post_content
  post_content="$(build_post_content)"

  local create_args=(post create --post_type=post --post_status="$POST_STATUS" --post_title="$TITLE" --post_content="$post_content" --porcelain)

  if [[ -n "$SLUG" ]]; then
    create_args+=(--post_name="$SLUG")
  fi
  if [[ -n "$EXCERPT" ]]; then
    create_args+=(--post_excerpt="$EXCERPT")
  fi

  local post_id
  post_id="$(run_wp "${create_args[@]}")"

  if [[ -n "$CATEGORY_CSV" ]]; then
    ensure_terms "category" "$CATEGORY_CSV"
    run_wp post term set "$post_id" category "$CATEGORY_CSV" >/dev/null
  fi

  if [[ -n "$TAGS_CSV" ]]; then
    ensure_terms "post_tag" "$TAGS_CSV"
    run_wp post term set "$post_id" post_tag "$TAGS_CSV" >/dev/null
  fi

  echo "SUCCESS: post_id=$post_id status=$POST_STATUS"
  run_wp post url "$post_id"
}

print_summary() {
  cat <<TXT
=== Parsed Article Idea ===
TITLE      : $TITLE
SLUG       : ${SLUG:-<auto>}
STATUS     : $POST_STATUS
CATEGORY   : ${CATEGORY_CSV:-<none>}
TAGS       : ${TAGS_CSV:-<none>}
CTA_TEXT   : ${CTA_TEXT:-<none>}
CTA_URL    : ${CTA_URL:-<none>}
AD_SLOT    : ${AD_SLOT:-<none>}
EXCERPT    : ${EXCERPT:-<none>}
BODY_CHARS : ${#BODY}
TXT
}

main() {
  require_wp
  parse_input
  print_summary

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "DRY-RUN: 投稿は作成していません"
    exit 0
  fi

  create_post
}

main
