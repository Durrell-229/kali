FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_RESOLUTION=1280x800 \
    VNC_PASSWORD=change-me-now \
    PORT=8080

# XFCE fournit le bureau léger; noVNC/websockify rendent l'interface accessible
# depuis le navigateur. Supervision garde les processus actifs dans le conteneur.
RUN apt-get update && apt-get install -y --no-install-recommends \
      kali-desktop-xfce \
      kali-tools-top10 \
      dbus-x11 \
      xauth \
      xvfb \
      x11vnc \
      novnc \
      websockify \
      supervisor \
      sudo \
      ca-certificates \
      procps \
      net-tools \
      curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Utilisateur non-root pour la session graphique.
RUN useradd -m -s /bin/bash kali \
    && echo 'kali ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/kali \
    && chmod 0440 /etc/sudoers.d/kali \
    && mkdir -p /home/kali/.vnc \
    && chown -R kali:kali /home/kali

COPY start-vnc.sh /usr/local/bin/start-vnc.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /usr/local/bin/start-vnc.sh

EXPOSE 8080

CMD ["/usr/local/bin/start-vnc.sh"]
