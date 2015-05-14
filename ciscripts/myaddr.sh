#!/bin/bash
#
#
#
set -e
set -o pipefail
set -u

for i in $(/sbin/ip route get 8.8.8.8 | head -1); do echo ipaddr=${i}; done | tail -1
