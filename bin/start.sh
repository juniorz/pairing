#!/bin/bash

set -e

VNC_PASS="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)"
echo "VNC password: $VNC_PASS"

/usr/local/bin/start-vnc.sh "$VNC_PASS"
/usr/local/bin/start-tmate.sh "$VNC_PASS"

