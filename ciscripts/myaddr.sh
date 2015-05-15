#!/bin/bash
#
#
#
set -e
set -o pipefail
set -u

# ip command:
# for i in $(/sbin/ip route get 8.8.8.8 | head -1); do echo ipaddr=${i}; done | tail -1

# metadata:
ipaddr="$(< /metadata/meta-data/local-ipv4)"
echo ipaddr="${ipaddr}"
