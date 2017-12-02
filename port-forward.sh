set -e

# I have a vps to use as jumpbox.
# Its sshd_config has `GatewayPorts clientspecified` for my user.
# My ~/.ssh/config has `Host port-forwarder` configured to my jumpbox.
/usr/bin/ssh -f -N -T -M -S "/tmp/port-forward-${1}-to-${2}" -R $2:localhost:$1 port-forwarder
