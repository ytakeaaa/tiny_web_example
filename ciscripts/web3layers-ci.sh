#!/bin/bash
#
#
set -e
set -o pipefail
set -u
set -x

# required shell params

: "${YUM_HOST:?"should not be empty"}"

# run instances

## db

eval "$(${BASH_SOURCE[0]%/*}/runner-db.sh)"
db_id="${instance_id}"
DB_HOST="${ipaddr}"

## app

eval "$(
 YUM_HOST="${YUM_HOST}" \
  DB_HOST="${DB_HOST}"  \
  ${BASH_SOURCE[0]%/*}/runner-app.sh
 )"
app_id="${instance_id}"
APP_HOST="${ipaddr}"

# smoketest

## app

APP_HOST="${APP_HOST}" ${BASH_SOURCE[0]%/*}/smoketest-app.sh

# cleanup instances

${BASH_SOURCE[0]%/*}/instance-kill.sh "${db_id}"
${BASH_SOURCE[0]%/*}/instance-kill.sh "${app_id}"
