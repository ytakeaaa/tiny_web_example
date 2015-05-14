#!/bin/bash
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

# setup musselrc

cat <<EOS > ~/.musselrc
DCMGR_HOST=10.0.2.2
account_id=a-shpoolxx
EOS

# setup vifs.json

network_id="nw-demo1"
security_group_id="sg-cicddemo"
vifs="vifs.json"

cat <<EOS > "${vifs}"
{
 "eth0":{"network":"${network_id}","security_groups":"${security_group_id}"}
}
EOS

# setup user_data.txt

user_data="user_data_centos.txt"

# instance-specific parameter

cpu_cores="1"
hypervisor="kvm"
memory_size="1024"
image_id="wmi-centos1d64"
display_name="centos"
ssh_key_id="ssh-cicddemo"

## create an instance

instance_id="$(
  mussel instance create \
   --cpu-cores    "${cpu_cores}"    \
   --hypervisor   "${hypervisor}"   \
   --image-id     "${image_id}"     \
   --memory-size  "${memory_size}"  \
   --ssh-key-id   "${ssh_key_id}"   \
   --vifs         "${vifs}"         \
   --user-data    "${user_data}"    \
   --display-name "${display_name}" \
  | egrep ^:id: | awk '{print $2}'
)"
: "${instance_id:?"should not be empty"}"
echo "${instance_id} is initializing..." >&2

trap "mussel instance destroy \"${instance_id}\"" ERR

## wait for the instance to be running

retry_until [[ '"$(mussel instance show "${instance_id}" | egrep -w "^:state: running")"' ]]
echo instance_id="${instance_id}"
