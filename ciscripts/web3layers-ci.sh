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

# run load balancers

## lbweb

eval "$(${BASH_SOURCE[0]%/*}/runner-lbweb.sh)"
lbweb_id="${load_balancer_id}"
LBWEB_HOST="${ipaddr_public}"

${BASH_SOURCE[0]%/*}/load_balancer-register-instance.sh "${lbweb_id}" "${app_id}"

## trap

trap "
 ${BASH_SOURCE[0]%/*}/load_balancer-kill.sh \"${lbweb_id}\"
 mussel instance destroy \"${db_id}\"
 mussel instance destroy \"${app_id}\"
" ERR

# smoketest

## app

if [[ -n "${JENKINS_HOME:-""}" ]]; then
  # called by jenkins
  # TODO
  echo not implemented so far.
else
  # stand alone
  APP_HOST="${APP_HOST}"   ${BASH_SOURCE[0]%/*}/smoketest-app.sh
  WEB_HOST="${APP_HOST}"   ${BASH_SOURCE[0]%/*}/smoketest-web.sh
  WEB_HOST="${LBWEB_HOST}" ${BASH_SOURCE[0]%/*}/smoketest-web.sh
fi

# cleanup load balancers

${BASH_SOURCE[0]%/*}/load_balancer-kill.sh "${lbweb_id}"

# cleanup instances

${BASH_SOURCE[0]%/*}/instance-kill.sh "${db_id}"
${BASH_SOURCE[0]%/*}/instance-kill.sh "${app_id}"
