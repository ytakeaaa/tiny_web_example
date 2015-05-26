#!/bin/bash
#
#
set -e
set -o pipefail
set -u
set -x

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

## lbapp

eval "$(${BASH_SOURCE[0]%/*}/runner-lbapp.sh)"
lbapp_id="${load_balancer_id}"
LBAPP_HOST="${ipaddr_public}"

${BASH_SOURCE[0]%/*}/load_balancer-register-instance.sh "${lbapp_id}" "${app_id}"

## trap

trap "
 ${BASH_SOURCE[0]%/*}/load_balancer-kill.sh \"${lbapp_id}\"
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
  APP_HOST="${APP_HOST}" ${BASH_SOURCE[0]%/*}/smoketest-app.sh
fi

# cleanup load balancers

${BASH_SOURCE[0]%/*}/load_balancer-kill.sh "${lbapp_id}"

# cleanup instances

${BASH_SOURCE[0]%/*}/instance-kill.sh "${db_id}"
${BASH_SOURCE[0]%/*}/instance-kill.sh "${app_id}"
