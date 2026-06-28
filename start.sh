#!/bin/bash
set -e

DISPLAY_NUM=99
DISPLAY=":${DISPLAY_NUM}"
RESOLUTION="1280x720x24"
VNC_PORT=5900
WEB_PORT="${PORT:-5000}"
VNC_PASSWORD="${VNC_PASSWORD:-}"
NOVNC_DIR="$(dirname "$0")/novnc"

echo "=== Starting Browser Desktop ==="
echo "Web port: $WEB_PORT"

cleanup() {
    pkill -f "Xvfb :${DISPLAY_NUM}" 2>/dev/null || true
    pkill -f x11vnc 2>/dev/null || true
    pkill -f websockify 2>/dev/null || true
    pkill -f "google-chrome" 2>/dev/null || true
    pkill -f "chromium-browser" 2>/dev/null || true
    pkill -f openbox 2>/dev/null || true
}
trap cleanup EXIT

pkill -f "Xvfb :${DISPLAY_NUM}" 2>/dev/null || true
sleep 1

echo "Starting Xvfb on ${DISPLAY}..."
Xvfb "${DISPLAY}" -screen 0 "${RESOLUTION}" -ac +extension GLX +render -noreset &
sleep 3

for i in 1 2 3 4 5; do
    if DISPLAY="${DISPLAY}" xdpyinfo >/dev/null 2>&1; then
        echo "X display ready!"
        break
    fi
    echo "Waiting for X display... attempt $i"
    sleep 2
done

export DISPLAY="${DISPLAY}"

echo "Starting openbox window manager..."
openbox &
sleep 1

echo "Launching Chromium with Violentmonkey..."
chromium-browser \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-software-rasterizer \
    --disable-gpu \
    --start-maximized \
    --no-first-run \
    --disable-translate \
    --disable-notifications \
    --disable-default-apps \
    --window-size=1280,720 \
    --window-position=0,0 \
    --test-type \
    --noerrdialogs \
    --load-extension=/app/extensions/violentmonkey \
    https://www.google.com &
sleep 5

echo "Pinning Violentmonkey extension..."
python3 -c "
import json, os, time
prefs_file = os.path.expanduser('~/.config/google-chrome/Default/Preferences')
# Wait for preferences file to be created
for i in range(10):
    if os.path.exists(prefs_file):
        try:
            with open(prefs_file, 'r') as f:
                prefs = json.load(f)
            ext_settings = prefs.get('extensions', {}).get('settings', {})
            modified = False
            for ext_id, settings in ext_settings.items():
                if ext_id and ext_id != '__MSG__':
                    path = settings.get('path', '')
                    if 'violentmonkey' in path.lower():
                        settings['pin_to_toolbar'] = True
                        settings['toolbar_pin'] = True
                        print(f'Pinned extension: {ext_id}')
                        modified = True
            if modified:
                with open(prefs_file, 'w') as f:
                    json.dump(prefs, f, indent=2)
                print('Extension pinned successfully')
            else:
                print('Extension not found in preferences yet')
            break
        except:
            pass
    time.sleep(1)
" 2>/dev/null || true

echo "Starting x11vnc..."
if [ -n "$VNC_PASSWORD" ]; then
    x11vnc -display "${DISPLAY}" -rfbport "${VNC_PORT}" \
        -passwd "${VNC_PASSWORD}" -forever -shared -bg \
        -o /tmp/x11vnc.log 2>/dev/null
else
    x11vnc -display "${DISPLAY}" -rfbport "${VNC_PORT}" \
        -nopw -forever -shared -bg \
        -o /tmp/x11vnc.log 2>/dev/null
fi
sleep 2

echo "Starting noVNC on port ${WEB_PORT}..."
websockify --web "${NOVNC_DIR}" "${WEB_PORT}" "localhost:${VNC_PORT}" &

echo ""
echo "=== Desktop ready! ==="
echo "Open the preview and go to /vnc.html to connect"
wait
