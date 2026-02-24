![License](https://img.shields.io/badge/license-MIT-blue)
![Version](https://img.shields.io/badge/version-1.1.0-informational)
![Status](https://img.shields.io/badge/status-stable-green)

# xray-geoip-autoupdater

Lightweight systemd + Docker auto-updater for Xray GeoIP / GeoSite
databases with optional Telegram notifications.

------------------------------------------------------------------------

## Overview

xray-geoip-autoupdater automates updates of `geosite.dat` and
`geoip.dat` from `Loyalsoldier/v2ray-rules-dat` for Docker-based Xray
deployments.

The tool detects upstream releases, compares them with local state, and
updates only when a new version is available.

------------------------------------------------------------------------

## What it does

-   Checks latest release from `Loyalsoldier/v2ray-rules-dat`
-   Compares upstream tag with local state file
-   Downloads `geosite.dat` and `geoip.dat` if new version detected
-   Copies files into target Docker container
-   Restarts container after successful update
-   Sends optional Telegram notification
-   Exits silently if already up to date

------------------------------------------------------------------------

## Why this exists

Many Xray setups rely on `geosite` and `geoip` routing rules.

Keeping them updated ensures:

-   Correct domain classification (e.g. YouTube, Google, OpenAI)
-   Accurate geo-based routing
-   Up-to-date ASN and IP range mappings

This tool provides a minimal and deterministic way to automate database
updates in production environments.

------------------------------------------------------------------------

## Requirements

-   Linux server
-   Docker
-   systemd
-   jq
-   wget
-   curl
-   Telegram bot token (optional)

------------------------------------------------------------------------

## Installation

Clone repository:

``` bash
git clone https://github.com/lengordy/xray-geoip-autoupdater.git
cd xray-geoip-autoupdater
```

Install script:

``` bash
sudo cp xray-geoip-autoupdate.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/xray-geoip-autoupdate.sh
```

Install systemd units:

``` bash
sudo cp examples/systemd/xray-geoip-autoupdate.service /etc/systemd/system/
sudo cp examples/systemd/xray-geoip-autoupdate.timer /etc/systemd/system/
```

Create environment configuration:

``` bash
sudo cp .env.example /etc/geoip-autoupdate.env
sudo nano /etc/geoip-autoupdate.env
```

Enable timer:

``` bash
sudo systemctl daemon-reload
sudo systemctl enable --now xray-geoip-autoupdate.timer
```

------------------------------------------------------------------------

## Environment Configuration

Create or edit:

`/etc/geoip-autoupdate.env`

Example:

    TG_TOKEN=YOUR_TELEGRAM_BOT_TOKEN
    TG_CHAT_ID=YOUR_CHAT_ID
    CONTAINER_NAME=xray
    INSTALL_PATH=/usr/local/share/xray

------------------------------------------------------------------------

## How it works

-   Fetches latest release tag from GitHub API
-   Compares with `/var/lib/geoip-update.state`
-   Proceeds only if tag changed
-   Uses `mktemp` for isolated temporary directory
-   Validates downloaded files before deployment
-   Restarts container after successful update
-   Sends Telegram notification on success or failure
-   Cleans up temporary files automatically

------------------------------------------------------------------------

## Notes

-   Not tied to any specific control panel
-   Works with any Docker-based Xray setup
-   Not related to WARP directly
-   Safe to run daily (updates only on new release)
-   Designed for single-node production deployments

------------------------------------------------------------------------

## Maintenance Mode Integration

This version supports maintenance-aware updates.

If a maintenance flag file is configured:

- The updater sets the flag before container restart
- Waits until Node API becomes reachable
- Updates state only after successful API validation
- Leaves maintenance flag intact if API does not recover

This prevents false-positive monitoring alerts and ensures
deterministic post-restart validation in production environments.

------------------------------------------------------------------------

## Versioning

This project follows Semantic Versioning.

Changelog is maintained in `CHANGELOG.md`.

------------------------------------------------------------------------

## License

MIT License. See `LICENSE` for details.
