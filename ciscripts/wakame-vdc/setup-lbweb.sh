#!/bin/bash
#
#
set -e
set -o pipefail
set -u

eval "$(
  ${BASH_SOURCE[0]%/*}/runner-lbweb.sh
)"

LDWEB_ID="${load_balancer_id}"
LBWEB_HOST="${ipaddr_public}"

${BASH_SOURCE[0]%/*}/load_balancer-register-instance.sh "${LDWEB_ID}" "${APP_ID}" >&2
