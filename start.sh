#!/usr/bin/env bash
set -euo pipefail

export HOME=/home/desktop
export USER=desktop

VNC_DISPLAY=":1"
VNC_PORT="${VNCPORT:-5901}"
NOVNC_PORT="${NOVNCPORT:-6080}"
GEOMETRY="${VNC_GEOMETRY:-1366x768}"
DEPTH="${VNC_DEPTH:-24}"
DESKTOP_DIR="$HOME/Desktop"

mkdir -p "$HOME/.vnc" "$HOME/.config/autostart" "$DESKTOP_DIR"

cleanup() {
  vncserver -kill "$VNC_DISPLAY" >/dev/null 2>&1 || true
}
trap cleanup EXIT

sync_desktop_shortcuts() {
  mkdir -p "$DESKTOP_DIR"

  # Keep core shortcuts on the desktop
  install -m 755 /home/desktop/Desktop/All-Apps.desktop "$DESKTOP_DIR/All-Apps.desktop" 2>/dev/null || true
  install -m 755 /home/desktop/Desktop/Home.desktop "$DESKTOP_DIR/Home.desktop" 2>/dev/null || true
  install -m 755 /home/desktop/Desktop/Terminal.desktop "$DESKTOP_DIR/Terminal.desktop" 2>/dev/null || true
  install -m 755 /home/desktop/Desktop/Chrome.desktop "$DESKTOP_DIR/Chrome.desktop" 2>/dev/null || true
  install -m 755 /home/desktop/Desktop/Files.desktop "$DESKTOP_DIR/Files.desktop" 2>/dev/null || true

  # Copy newly installed GUI apps to desktop automatically
  for src_dir in /usr/share/applications "$HOME/.local/share/applications"; do
    [[ -d "$src_dir" ]] || continue

    find "$src_dir" -maxdepth 1 -name '*.desktop' -print0 | while IFS= read -r -d '' app; do
      type_val="$(grep -m1 '^Type=' "$app" 2>/dev/null | cut -d= -f2- || true)"
      no_display="$(grep -m1 '^NoDisplay=' "$app" 2>/dev/null | cut -d= -f2- || true)"
      hidden="$(grep -m1 '^Hidden=' "$app" 2>/dev/null | cut -d= -f2- || true)"
      exec_val="$(grep -m1 '^Exec=' "$app" 2>/dev/null | cut -d= -f2- || true)"
      name_val="$(grep -m1 '^Name=' "$app" 2>/dev/null | cut -d= -f2- || basename "$app" .desktop)"

      [[ "${type_val:-}" == "Application" ]] || continue
      [[ "${no_display,,}" == "true" ]] && continue
      [[ "${hidden,,}" == "true" ]] && continue
      [[ -n "${exec_val:-}" ]] || continue

      safe_name="$(printf '%s' "$name_val" | tr '/\\:*?"<>|' '_' | sed 's/[[:space:]]\+/ /g; s/^ *//; s/ *$//')"
      [[ -n "$safe_name" ]] || continue

      out="$DESKTOP_DIR/$safe_name.desktop"
      cp -f "$app" "$out"
      chmod +x "$out" || true
    done
  done
}

# Start VNC fresh
vncserver -kill "$VNC_DISPLAY" >/dev/null 2>&1 || true
rm -f "$HOME/.vnc/"*.pid "$HOME/.vnc/"*.log >/dev/null 2>&1 || true

# Initial sync
sync_desktop_shortcuts

# Keep syncing new apps in the background
(
  while true; do
    sync_desktop_shortcuts
    sleep 60
  done
) &

# Start VNC
vncserver "$VNC_DISPLAY" -geometry "$GEOMETRY" -depth "$DEPTH" -rfbport "$VNC_PORT"

# noVNC
exec websockify --web=/usr/share/novnc/ "$NOVNC_PORT" localhost:"$VNC_PORT"
