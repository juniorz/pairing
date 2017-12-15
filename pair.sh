#!/bin/bash

set -eu

#PID="$$"
PAIR=${1:-}
ME=${2:-"$(git config user.email)"}

if [[ -z "$PAIR" ]]; then
	echo "$0 pair@domain.com" >&2
	exit 1
fi

# Save pid
SESSION_NAME=$(echo "pairing-$PAIR" | tr '@' '-')
#echo "$PID" > "/pairing/.${SESSION_NAME}.pid"

# Prepare gpg keys.
dst=$(mktemp -d)
gpg2 --export --armor $PAIR > "$dst/$PAIR.pub" || true
gpg2 --export --armor $ME > "$dst/$ME.pub" || true

# Waits for VNC server to start, and connects to it.
(
	# Wait for vnc
	NEXT_WAIT_TIME=0
	until nc -vz 127.0.0.1 5901 || [ $NEXT_WAIT_TIME -eq 4 ]; do
	   sleep $(( NEXT_WAIT_TIME++ ))
	done

	# Forward ports
	./port-forward.sh 5901 *:5900
	./port-forward.sh 6080 6080

	vncviewer 127.0.0.1:5901 \
		-SendPrimary=0 \
		-SendClipboard=0 \
		-AcceptClipboard=1 \
		-Shared=1 \
		-RemoteResize=0 \
		-Maximize=0 \
		-QualityLevel=9 \
		-NoJPEG=1 \
		-CompressLevel=6 \
		-FullColor=1 \
		-PasswordFile=/pairing/.vnc/passwd \
	2>&1
) > /dev/null 2>&1 &

#TODO: When this starts a tmate session, send an email to
docker run -it --rm \
	--name "$SESSION_NAME" \
        -h pairing \
        --memory=300m \
        --memory-swap=300m \
        --cpus=1.5 \
	--security-opt=seccomp:unconfined \
	-p 5901:5901 \
	-p 6080:6080 \
        -v /etc/localtime:/etc/localtime:ro \
	-e SSH_AUTH_SOCK="/from-host/S.gpg-agent.ssh" \
	-v $(gpgconf --list-dirs agent-ssh-socket):/from-host/S.gpg-agent.ssh \
	-v $(gpgconf --list-dirs agent-extra-socket):/pairing/.gnupg/S.gpg-agent \
	-v $dst:/pairing/keys \
	-v `pwd`:/host \
	-v /pairing:/pairing \
	-v ${HOME}/go/src:/pairing/go/src \
	-v ${HOME}/.gitconfig:/pairing/.config/git/config:ro \
	-v ${HOME}/.config/nvim:/pairing/.config/nvim:ro \
	-v ${HOME}/.local/share/nvim:/pairing/.local/share/nvim:ro \
	-v ${HOME}/.tmux.conf:/etc/tmux.conf:ro \
	pairing /usr/local/bin/start.sh

# Clean pub keys dir
rm -rf $dst

# Stop port forwards
./stop-port-forward.sh 5901 *:5900 || true
./stop-port-forward.sh 6080 6080 || true
