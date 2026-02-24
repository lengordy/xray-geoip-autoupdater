#!/usr/bin/env bash
set -euo pipefail

VERSION="1.1.0"

# ================= CONFIGURATION =================
CONTAINER="${CONTAINER_NAME}"
WORKDIR="${INSTALL_PATH}"

STATE_FILE="/var/lib/geoip-update.state"
MAINT_FLAG="${MAINT_FLAG:-/run/geoip-maintenance.flag}"   # ← добавлено

TMPDIR="$(mktemp -d)"

GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
API_URL="https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest"
# =================================================

cleanup() {
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

fail() {
  send_tg "❌ *GeoIP / GeoSite update FAILED* on $(hostname)"
  exit 1
}

send_tg() {
  curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
    -d chat_id="$TG_CHAT_ID" \
    -d parse_mode="Markdown" \
    -d text="$1" > /dev/null || true
}

mkdir -p "$(dirname "$STATE_FILE")"

LATEST_TAG=$(curl -s "$API_URL" | jq -r '.tag_name') || fail
[[ -n "$LATEST_TAG" && "$LATEST_TAG" != "null" ]] || fail

CURRENT_TAG="none"
[[ -f "$STATE_FILE" ]] && CURRENT_TAG=$(cat "$STATE_FILE")

NOW=$(date +"%Y-%m-%d %H:%M")

if [[ "$LATEST_TAG" == "$CURRENT_TAG" ]]; then
  exit 0
fi

send_tg "⬇️ *New GeoIP / GeoSite update detected*
📦 Version: $LATEST_TAG
⏳ Starting update..."

cd "$TMPDIR" || fail

wget -q -O geosite.dat "$GEOSITE_URL" || fail
wget -q -O geoip.dat "$GEOIP_URL" || fail

[[ -s geosite.dat ]] || fail
[[ -s geoip.dat ]] || fail

docker cp geosite.dat "$CONTAINER":"$WORKDIR"/ || fail
docker cp geoip.dat "$CONTAINER":"$WORKDIR"/ || fail

# ── Новый блок перезапуска с maintenance-флагом и проверкой API ──
touch "$MAINT_FLAG" || fail

docker restart "$CONTAINER" >/dev/null || fail

API_OK=0
for i in {1..60}; do
  if docker exec "$CONTAINER" sh -lc "nc -z 127.0.0.1 2222" >/dev/null 2>&1; then
    API_OK=1
    break
  fi
  sleep 1
done

if [[ $API_OK -ne 1 ]]; then
  send_tg "❌ *GeoIP update applied but API did not recover*
Maintenance flag left in place."
  exit 1
fi

rm -f "$MAINT_FLAG"
echo "$LATEST_TAG" > "$STATE_FILE"

send_tg "✅ *GeoIP / GeoSite updated successfully*
🔁 Container restarted
📦 Version: $LATEST_TAG
🕒 Time: $NOW"
