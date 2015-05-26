#!/bin/bash
#
#
set -e
set -o pipefail
set -u
set -x

#

eval "$(
  ${BASH_SOURCE[0]%/*}/create-lbweb.sh
  )"
trap "mussel load_balancer destroy \"${load_balancer_id}\"" ERR

eval "$(${BASH_SOURCE[0]%/*}/load_balancer-get-ipaddr.sh "${load_balancer_id}")"

echo load_balancer_id="${load_balancer_id}"
echo ipaddr="${ipaddr}"
echo ipaddr_public="${ipaddr%,*}"
echo ipaddr_managed="${ipaddr#*,}"
