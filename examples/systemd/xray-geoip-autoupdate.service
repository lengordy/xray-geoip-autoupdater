[Unit]
Description=GeoIP / GeoSite Auto Update for Xray
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
EnvironmentFile=/etc/geoip-autoupdate.env
ExecStart=/usr/local/bin/geoip-autoupdate.sh
