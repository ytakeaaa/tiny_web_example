#!/bin/bash
#
#
set -e
set -o pipefail
set -u

eval "$(
  ${BASH_SOURCE[0]%/*}/runner-db.sh
)"

DB_ID="${instance_id}"
DB_HOST="${ipaddr}"
