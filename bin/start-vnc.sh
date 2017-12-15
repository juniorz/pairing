#!/bin/bash
set -e

### disable screensaver and power management
#xset -dpms &
#xset s noblank &
#xset s off &
#/usr/bin/startxfce4 --replace

PASS="$1"

mkdir -p $HOME/.vnc
echo "$PASS" | vncpasswd -f > $HOME/.vnc/passwd
chmod 600 $HOME/.vnc/passwd

/opt/novnc/utils/launch.sh --listen 6080 --vnc 127.0.0.1:5901 > /dev/null 2>&1 &
vncserver -kill :1 > /dev/null 2>&1 || true
vncserver :1 -geometry 1024x768 -depth 24 -alwaysshared

