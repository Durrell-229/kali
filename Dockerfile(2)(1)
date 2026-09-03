FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    PORT=8080 \
    VNC_RESOLUTION=1280x800 \
    VNC_PASSWORD=change-me-now

# Kali XFCE + serveur X virtuel + VNC + passerelle VNC/WebSocket noVNC.
RUN apt-get update && apt-get install -y --no-install-recommends \
      kali-desktop-xfce \
      kali-tools-top10 \
      dbus-x11 \
      xvfb \
      x11vnc \
      novnc \
      websockify \
      tini \
      ca-certificates \
      curl \
      sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Compte de session graphique avec sudo, sans mot de passe, pour les outils Kali.
RUN useradd -m -s /bin/bash kali \
    && echo 'kali ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/kali \
    && chmod 0440 /etc/sudoers.d/kali \
    && mkdir -p /home/kali/.vnc \
    && chown -R kali:kali /home/kali

# Railway fournit PORT automatiquement. Le processus noVNC reste au premier plan.
EXPOSE 8080

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "-lc", "set -Eeuo pipefail; \
  : \"${PORT:=8080}\"; \
  : \"${DISPLAY:=:1}\"; \
  : \"${VNC_RESOLUTION:=1280x800}\"; \
  : \"${VNC_PASSWORD:=change-me-now}\"; \
  if [[ \"${VNC_PASSWORD}\" == \"change-me-now\" ]]; then echo 'WARNING: définis VNC_PASSWORD dans Railway.' >&2; fi; \
  mkdir -p /root/.vnc; \
  x11vnc -storepasswd \"${VNC_PASSWORD}\" /root/.vnc/passwd >/dev/null; \
  chmod 600 /root/.vnc/passwd; \
  Xvfb \"${DISPLAY}\" -screen 0 \"${VNC_RESOLUTION}x24\" -ac +extension GLX +render -noreset & \
  XVFB_PID=$!; \
  trap 'kill \"${XVFB_PID}\" 2>/dev/null || true' EXIT; \
  sleep 2; \
  export DISPLAY; \
  dbus-run-session -- startxfce4 >/tmp/xfce.log 2>&1 & \
  XFCE_PID=$!; \
  sleep 3; \
  x11vnc -display \"${DISPLAY}\" -rfbauth /root/.vnc/passwd -rfbport 5900 -forever -shared -noxrecord -noxfixes -noxdamage -localhost >/tmp/x11vnc.log 2>&1 & \
  VNC_PID=$!; \
  trap 'kill \"${VNC_PID}\" \"${XFCE_PID}\" \"${XVFB_PID}\" 2>/dev/null || true' EXIT; \
  echo \"Kali noVNC disponible sur le port ${PORT}\"; \
  exec websockify --web=/usr/share/novnc/ \"${PORT}\" localhost:5900"]
