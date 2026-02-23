![License](https://img.shields.io/badge/license-MIT-blue)
![Version](https://img.shields.io/badge/version-1.0.0-informational)
![Status](https://img.shields.io/badge/status-stable-green)

# xray-geoip-autoupdater

Lightweight systemd + Docker auto-updater for Xray GeoIP / GeoSite databases with Telegram notifications.

---

## What it does

- Checks latest release from `Loyalsoldier/v2ray-rules-dat`
- Compares with local state
- Downloads `geosite.dat` and `geoip.dat` if new version detected
- Copies files into Docker container
- Restarts container
- Sends Telegram notification
- Exits silently if already up to date

---

## Why this exists

Many Xray setups rely on `geosite` and `geoip` routing rules.

Keeping them updated ensures:

- Correct domain classification (e.g. YouTube, Google, OpenAI)
- Accurate geo-based routing
- Up-to-date ASN / IP ranges

This tool provides a minimal, production-ready way to automate updates.

---

## Requirements

- Linux server
- Docker
- systemd
- jq
- wget
- Telegram bot (optional but recommended)

---

## Installation

1. Copy files:

   - `/usr/local/bin/geoip-autoupdate.sh`
   - `/etc/systemd/system/geoip-autoupdate.service`
   - `/etc/systemd/system/geoip-autoupdate.timer`
   - `/etc/geoip-autoupdate.env`

2. Make script executable:

   chmod +x /usr/local/bin/geoip-autoupdate.sh

3. Reload and enable:

   systemctl daemon-reload
   systemctl enable geoip-autoupdate.timer
   systemctl start geoip-autoupdate.timer

---

## Environment configuration

Create:

`/etc/geoip-autoupdate.env`

Example:

TG_TOKEN=YOUR_TELEGRAM_BOT_TOKEN  
TG_CHAT_ID=YOUR_CHAT_ID  
CONTAINER_NAME=xray  
INSTALL_PATH=/usr/local/share/xray  

---

## How it works

- Fetches latest release tag from GitHub API
- Compares with `/var/lib/geoip-update.state`
- Only updates if tag changed
- Uses `mktemp` for safe temporary directory
- Cleans up automatically
- Sends Telegram alerts on success or failure

---

## Notes

- Not tied to any specific panel
- Works with any Docker-based Xray setup
- Not related to WARP directly
- Safe to run daily (updates only on new release)

---

## License

MIT
