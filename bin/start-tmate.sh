#!/bin/bash

set -ex

cd ~/go/src/github.com/coyim/coyim

export DISPLAY=":1"
tmate -S /tmp/tmate.sock \
	new-session -d \; \
	wait tmate-ready

TMATE_SSH="$(tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}')"
TMATE_SSH_RO="$(tmate -S /tmp/tmate.sock display -p '#{tmate_ssh_ro}')"

MOTD="vnc: $1 \ntmate: ${TMATE_SSH_RO}"
tmate -S /tmp/tmate.sock \
	splitw -d -v -p 80 "echo -e \"$MOTD\" | /usr/games/cowsay -f Pikachu -n ; /bin/bash" \; \
	attach

# Ideas
# could lock/unlock until something happens wait-for -L / wait-for - U
