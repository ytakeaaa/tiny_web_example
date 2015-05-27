#!/bin/bash
#
#
set -e
set -o pipefail
set -u

: "${YUM_HOST:?"should not be empty"}"
: "${DB_HOST:?"should not be empty"}"

eval "$(
 YUM_HOST="${YUM_HOST}" \
  DB_HOST="${DB_HOST}"  \
  ${BASH_SOURCE[0]%/*}/runner-app.sh
)"

echo APP_ID="${instance_id}"
echo APP_HOST="${ipaddr}"
