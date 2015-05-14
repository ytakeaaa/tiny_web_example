#!/bin/bash
#
# Usage:
#  $0
#
set -e
set -o pipefail
set -u

## functions

function retry_until() {
  local blk="$@"

  local wait_sec=${RETRY_WAIT_SEC:-120}
  local sleep_sec=${RETRY_SLEEP_SEC:-3}
  local tries=0
  local start_at=$(date +%s)
  local chk_cmd=

  while :; do
    eval "${blk}" && {
      break
    } || {
      sleep ${sleep_sec}
    }

    tries=$((${tries} + 1))
    if [[ "$(($(date +%s) - ${start_at}))" -gt "${wait_sec}" ]]; then
      echo "Retry Failure: Exceed ${wait_sec} sec: Retried ${tries} times" >&2
      return 1
    fi
    echo [$(date +%FT%X) "#$$"] time:${tries} "eval:${chk_cmd}" >&2
  done
}

## shell params

balance_algorithm="leastconn"
engine="haproxy"
max_connection="1000"
instance_port="8080"
instance_protocol="http"
port_maps="8080:http"
display_name="lb8080"

## create a load_balancer

load_balancer_id="$(
  mussel load_balancer create \
   --balance-algorithm "${balance_algorithm}" \
   --engine            "${engine}"            \
   --instance-port     "${instance_port}"     \
   --instance-protocol "${instance_protocol}" \
   --max-connection    "${max_connection}"    \
   --display-name      "${display_name}"      \
   $(
    IFS=,
    for i in ${port_maps}; do
      echo --port     ${i%%:*}
      echo --protocol ${i##*:}
    done
   ) \
  | egrep ^:id: | awk '{print $2}'
)"

: "${load_balancer_id:?"load_balancer is empty"}"
echo "${load_balancer_id} is initializing..." >&2

trap "mussel load_balancer destroy \"${load_balancer_id}\"" ERR

## wait for the load_balancer to be running

retry_until [[ '"$(mussel load_balancer show "${load_balancer_id}" | egrep -w "^:state: running")"' ]]
echo load_balancer_id="${load_balancer_id}"
