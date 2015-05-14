#!/bin/bash
#
#
set -e
set -o pipefail
set -u
set -x

eval "$(
  ./create-app.sh
  )"
trap "mussel instance destroy \"${instance_id}\"" ERR

eval "$(./instance-get-ipaddr.sh "${instance_id}")"

{
  ./instance-wait4ssh.sh  "${instance_id}"
  ./instance-exec.sh      "${instance_id}" "cat > /etc/yum.repos.d/tiny-web-example.repo" < ../rpmbuild/tiny-web-example.repo
  ./instance-exec.sh      "${instance_id}" < ./provision-app.sh
} >&2

echo instance_id="${instance_id}"
echo ipaddr="${ipaddr}"
