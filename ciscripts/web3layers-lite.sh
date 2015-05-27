#!/bin/bash
#
#
set -e
set -o pipefail
set -u

# required shell params

: "${YUM_HOST:?"should not be empty"}"

#

cd ${BASH_SOURCE[0]%/*}/wakame-vdc

# run instances

## db

eval "$(${BASH_SOURCE[0]%/*}/runner-db.sh)"
DB_ID="${instance_id}"
DB_HOST="${ipaddr}"

## app

eval "$(
 YUM_HOST="${YUM_HOST}" \
  DB_HOST="${DB_HOST}"  \
  ${BASH_SOURCE[0]%/*}/runner-app.sh
 )"
APP_ID="${instance_id}"
APP_HOST="${ipaddr}"

## trap

trap "
 mussel instance destroy \"${DB_ID}\"
 mussel instance destroy \"${APP_ID}\"
" ERR

# smoketest

## app

#if [[ -n "${JENKINS_HOME:-""}" ]]; then
#  # called by jenkins
#  # TODO
#  echo not implemented so far.
#else
  # stand alone
  APP_HOST="${APP_HOST}" ${BASH_SOURCE[0]%/*}/smoketest-app.sh
  WEB_HOST="${APP_HOST}" ${BASH_SOURCE[0]%/*}/smoketest-web.sh
#fi

# cleanup instances

${BASH_SOURCE[0]%/*}/instance-kill.sh "${DB_ID}"
${BASH_SOURCE[0]%/*}/instance-kill.sh "${APP_ID}"
