#!/bin/bash
#
#
set -e
set -o pipefail
set -u

eval "$(
  ${BASH_SOURCE[0]%/*}/runner-db.sh
)"

echo DB_ID="${instance_id}"
echo DB_HOST="${ipaddr}"
