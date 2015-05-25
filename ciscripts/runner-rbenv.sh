#!/bin/bash
#
#
set -e
set -o pipefail
set -u
set -x

eval "$(
  ./create-rbenv.sh
  )"
trap "mussel instance destroy \"${instance_id}\"" ERR

eval "$(./instance-get-ipaddr.sh "${instance_id}")"

{
  ./instance-wait4ssh.sh  "${instance_id}"
  ./instance-exec.sh      "${instance_id}" < ./provision-rbenv.sh
} >&2

echo instance_id="${instance_id}"
echo ipaddr="${ipaddr}"
