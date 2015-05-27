#!/bin/bash
#
#
set -e
set -o pipefail
set -u

eval "$(
 YUM_HOST="${YUM_HOST}" \
  DB_HOST="${DB_HOST}"  \
  ${BASH_SOURCE[0]%/*}/runner-app.sh
)"

APP_ID="${instance_id}"
APP_HOST="${ipaddr}"
