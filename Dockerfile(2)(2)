FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    PORT=8080 \
    VNC_RESOLUTION=1280x800 \
    VNC_PASSWORD=change-me-now

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
      sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash kali \
    && echo 'kali ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/kali \
    && chmod 0440 /etc/sudoers.d/kali \
    && mkdir -p /home/kali

EXPOSE 8080

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "-lc", "set -Eeuo pipefail; \
  : \"${PORT:=8080}\"; \
  : \"${DISPLAY:=:1}\"; \
  : \"${VNC_RESOLUTION:=1280x800}\"; \
  : \"${VNC_PASSWORD:=change-me-now}\"; \
  echo \"Starting Kali desktop on display ${DISPLAY}, resolution ${VNC_RESOLUTION}, HTTP port ${PORT}\"; \
  Xvfb \"${DISPLAY}\" -screen 0 \"${VNC_RESOLUTION}x24\" -ac +extension GLX +render -noreset >/tmp/xvfb.log 2>&1 & \
  XVFB_PID=$!; \
  trap 'kill \"${XVFB_PID}\" 2>/dev/null || true' EXIT; \
  for i in $(seq 1 30); do kill -0 \"${XVFB_PID}\" 2>/dev/null && [[ -S /tmp/.X11-unix/X1 ]] && break; sleep 1; done; \
  kill -0 \"${XVFB_PID}\" 2>/dev/null || { cat /tmp/xvfb.log; exit 1; }; \
  export DISPLAY; \
  dbus-run-session -- startxfce4 >/tmp/xfce.log 2>&1 & \
  XFCE_PID=$!; \
  sleep 5; \
  x11vnc -display \"${DISPLAY}\" -passwd \"${VNC_PASSWORD}\" -rfbport 5900 -listen 127.0.0.1 -forever -shared -noxrecord -noxfixes -noxdamage -repeat >/tmp/x11vnc.log 2>&1 & \
  VNC_PID=$!; \
  trap 'kill \"${VNC_PID}\" \"${XFCE_PID}\" \"${XVFB_PID}\" 2>/dev/null || true' EXIT; \
  for i in $(seq 1 30); do kill -0 \"${VNC_PID}\" 2>/dev/null && (echo > /dev/tcp/127.0.0.1/5900) 2>/dev/null && break; sleep 1; done; \
  kill -0 \"${VNC_PID}\" 2>/dev/null || { cat /tmp/x11vnc.log; cat /tmp/xfce.log; exit 1; }; \
  echo \"noVNC ready: open /vnc.html?autoconnect=true&resize=remote\"; \
  exec websockify --verbose --heartbeat=30 --web=/usr/share/novnc/ \"0.0.0.0:${PORT}\" 127.0.0.1:5900"]
