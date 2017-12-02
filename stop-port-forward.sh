set -e

/usr/bin/ssh -S "/tmp/port-forward-${1}-to-${2}" -O exit port-forwarder
