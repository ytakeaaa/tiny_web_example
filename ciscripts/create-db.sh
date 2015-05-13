#!/bin/bash
#
set -e
set -o pipefail
set -x

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
cat "${vifs}"

# setup user_data.txt

user_data="user_data.txt"
cat <<EOS > "${user_data}"
EOS
cat "${user_data}"

# instance-specific parameter

cpu_cores="1"
hypervisor="kvm"
memory_size="1024"
image_id="wmi-mysqld1d64"
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
   --user-data    "${user_data}"    \
   --display-name "${display_name}" \
  | egrep ^:id: | awk '{print $2}'
)"
: "${instance_id:?"should not be empty"}"
echo instance_id="${instance_id}"
