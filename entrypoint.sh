#!/bin/sh
set -e
: "${CLIENT_ID:?CLIENT_ID is required}"
: "${WS_PATH:?WS_PATH is required}"
PORT="${PORT:-3000}"
cat > /tmp/config.json <<JSON
{
  "log": { "access": "none", "loglevel": "error" },
  "inbounds": [{
    "listen": "0.0.0.0",
    "port": ${PORT},
    "protocol": "vless",
    "settings": { "clients": [{ "id": "${CLIENT_ID}" }], "decryption": "none" },
    "streamSettings": { "network": "ws", "wsSettings": { "path": "${WS_PATH}" } },
    "sniffing": { "enabled": true, "destOverride": ["http", "tls", "quic"] }
  }],
  "outbounds": [{ "protocol": "freedom", "tag": "direct" },
                { "protocol": "blackhole", "tag": "block" }],
  "routing": { "rules": [{ "type": "field", "ip": ["geoip:private"], "outboundTag": "block" }] }
}
JSON
exec /usr/local/bin/xray run -config /tmp/config.json
