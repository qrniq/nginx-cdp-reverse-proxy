#!/bin/bash

# dbus-daemon --session --fork --print-address 1 > /tmp/dbus-session-addr.txt
#export DBUS_SESSION_BUS_ADDRESS=$(cat /tmp/dbus-session-addr.txt)
# export DBUS_SESSION_BUS_ADDRESS=`dbus-daemon --fork --config-file=/usr/share/dbus-1/session.conf --print-address`
# /etc/init.d/dbus restart

# Default port if not specified
DEFAULT_PORT=9224
PORT=${CHROME_DEBUG_PORT:-$DEFAULT_PORT}

# Validate port is within range
if [ "$PORT" -lt 48000 ] || [ "$PORT" -gt 49000 ]; then
    echo "Port $PORT is outside the allowed range (48000-49000). Using default port $DEFAULT_PORT."
    PORT=$DEFAULT_PORT
fi

echo "Starting Chrome with remote debugging on port $PORT"

nginx -t

# Start nginx in background
nginx -g "daemon on;"

# Start Chrome in headless mode with remote debugging

echo "Starting Chrome..."
google-chrome-stable \
    --headless \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --disable-setuid-sandbox \
    --no-first-run \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI,VizDisplayCompositor \
    --disable-extensions \
    --disable-default-apps \
    --disable-sync \
    --metrics-recording-only \
    --no-default-browser-check \
    --mute-audio \
    --disable-background-networking \
    --disable-client-side-phishing-detection \
    --disable-hang-monitor \
    --disable-popup-blocking \
    --disable-prompt-on-repost \
    --disable-web-resources \
    --enable-automation \
    --enable-logging \
    --log-level=0 \
    --password-store=basic \
    --use-mock-keychain \
    --disable-software-rasterizer \
    --disable-background-media-control \
    --disable-backgrounding-occluded-window \
    --disable-component-cloud-policy \
    --disable-ipc-flooding-protection \
    --remote-debugging-address=0.0.0.0 \
    --remote-debugging-port=48401 \
    --user-data-dir=/home/ec2-user/chrome-user-data 

echo "Chrome started."