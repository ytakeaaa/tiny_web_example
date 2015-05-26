#!/bin/bash
#
set -e
set -o pipefail
set -u

# include

. ${BASH_SOURCE[0]%/*}/retry.sh

# setup musselrc

${BASH_SOURCE[0]%/*}/gen-musselrc.sh

# setup vifs.json

network_id="nw-demo1"
security_group_id="sg-cicddemo"
vifs="vifs.json"

. ${BASH_SOURCE[0]%/*}/gen-vifs.sh

# instance-specific parameter

cpu_cores="1"
hypervisor="kvm"
memory_size="512"
image_id="wmi-xrjtduc4"
display_name="db"
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
   --display-name "${display_name}" \
  | egrep ^:id: | awk '{print $2}'
)"
: "${instance_id:?"should not be empty"}"
echo "${instance_id} is initializing..." >&2

trap "mussel instance destroy \"${instance_id}\"" ERR

## wait for the instance to be running

retry_until [[ '"$(mussel instance show "${instance_id}" | egrep -w "^:state: running")"' ]]
echo instance_id="${instance_id}"
