#!/usr/bin/env bash
set -Eeuo pipefail

: "${PORT:=8080}"
: "${DISPLAY:=:1}"
: "${VNC_RESOLUTION:=1280x800}"
: "${VNC_PASSWORD:=change-me-now}"

if [[ "${VNC_PASSWORD}" == "change-me-now" ]]; then
  echo "WARNING: définis VNC_PASSWORD dans Railway avant la mise en production." >&2
fi

mkdir -p /home/kali/.vnc
printf '%s\n' "${VNC_PASSWORD}" | x11vnc -storepasswd stdin /home/kali/.vnc/passwd >/dev/null
chown -R kali:kali /home/kali/.vnc
chmod 600 /home/kali/.vnc/passwd

# Démarrage d'une session XFCE propre dans Xvfb.
export XAUTHORITY=/tmp/.Xauthority
rm -f "${XAUTHORITY}"
touch "${XAUTHORITY}"
xauth -f "${XAUTHORITY}" add "${DISPLAY}" . "$(mcookie)"

exec supervisord -n -c /etc/supervisor/supervisord.conf
