ARG UBUNTU_VERSION=24.04
FROM --platform=linux/amd64 ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Dhaka
ENV HOME=/home/desktop
ENV USER=desktop
ENV DISPLAY=:1
ENV VNC_GEOMETRY=1366x768
ENV VNC_DEPTH=24
ENV VNCPORT=5901
ENV NOVNCPORT=6080
ENV VNCPWD=changeme

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies xfce4-terminal xfce4-whiskermenu-plugin xfdesktop4 thunar \
    tightvncserver \
    novnc websockify \
    dbus-x11 x11-apps x11-xserver-utils xauth xterm \
    sudo curl wget ca-certificates gnupg tzdata \
    git nano vim neovim \
    net-tools iproute2 procps psmisc \
    unzip zip p7zip-full file \
    build-essential pkg-config software-properties-common \
    fonts-dejavu-core fonts-liberation \
    xdg-utils desktop-file-utils \
    libgl1 libnss3 libxss1 libxtst6 libatk-bridge2.0-0 libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

# Google Chrome stable
RUN set -eux; \
    wget -qO /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; \
    apt-get update; \
    (apt-get install -y /tmp/chrome.deb || (apt-get -f install -y && apt-get install -y /tmp/chrome.deb)); \
    rm -f /tmp/chrome.deb; \
    rm -rf /var/lib/apt/lists/*

# user
RUN useradd -m -s /bin/bash desktop \
    && echo "desktop ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/desktop \
    && chmod 0440 /etc/sudoers.d/desktop

USER desktop
WORKDIR /home/desktop

RUN mkdir -p /home/desktop/.vnc \
             /home/desktop/.config/autostart \
             /home/desktop/Desktop

# VNC startup
RUN cat > /home/desktop/.vnc/xstartup <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
exec dbus-launch --exit-with-session startxfce4
EOF
RUN chmod +x /home/desktop/.vnc/xstartup

# VNC password
RUN printf '%s\n' "${VNCPWD}" | vncpasswd -f > /home/desktop/.vnc/passwd \
    && chmod 600 /home/desktop/.vnc/passwd

# Chrome autostart
RUN cat > /home/desktop/.config/autostart/chrome.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Google Chrome
Exec=google-chrome-stable --no-sandbox --disable-dev-shm-usage --start-maximized
X-GNOME-Autostart-enabled=true
EOF

# "All Apps" button - Whisker Menu popup
RUN cat > /home/desktop/Desktop/All-Apps.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=All Apps
Comment=Open app menu
Exec=sh -lc 'xfce4-popup-whiskermenu || xfce4-popup-applicationsmenu || thunar /usr/share/applications'
Icon=applications-all
Terminal=false
Categories=Utility;
EOF
RUN chmod +x /home/desktop/Desktop/All-Apps.desktop

# Common desktop shortcuts
RUN cat > /home/desktop/Desktop/Home.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Home
Comment=Open home folder
Exec=thunar /home/desktop
Icon=user-home
Terminal=false
Categories=System;FileManager;
EOF
RUN chmod +x /home/desktop/Desktop/Home.desktop

RUN cat > /home/desktop/Desktop/Terminal.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Terminal
Comment=Open terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
EOF
RUN chmod +x /home/desktop/Desktop/Terminal.desktop

RUN cat > /home/desktop/Desktop/Chrome.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Google Chrome
Comment=Open browser
Exec=google-chrome-stable --no-sandbox --disable-dev-shm-usage --start-maximized
Icon=google-chrome
Terminal=false
Categories=Network;WebBrowser;
EOF
RUN chmod +x /home/desktop/Desktop/Chrome.desktop

RUN cat > /home/desktop/Desktop/Files.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Files
Comment=Open file manager
Exec=thunar
Icon=system-file-manager
Terminal=false
Categories=System;FileManager;
EOF
RUN chmod +x /home/desktop/Desktop/Files.desktop

COPY --chown=desktop:desktop start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5901
EXPOSE 6080

CMD ["/usr/local/bin/start.sh"]
