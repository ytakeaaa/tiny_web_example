#!/bin/bash
#
#
set -e
set -o pipefail
set -u

# required shell params

# vifs
network_id="nw-demo1"
security_group_id="sg-zhi49m5k"
vifs="vifs.json"

# instance-specific parameter
cpu_cores="1"
hypervisor="kvm"
memory_size="512"
image_id="centos1d64"
ssh_key_id="ssh-cicddemo"

# create an musselrc
cat <<EOS > ~/.musselrc
DCMGR_HOST=10.0.2.2
account_id=a-shpoolxx
EOS
export MUSSEL_RC=/test/musselrc

# create an vifs
cat <<EOS > "${vifs}"
{
 "eth0":{"network":"${network_id}","security_groups":"${security_group_id}"}
}
EOS

## create database image
echo "--create db image start--"

# db display name
display_name="db"

# create an instance
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
echo "${instance_id} is initializing..."

trap 'mussel instance destroy "${instance_id}"' ERR

# wait for the instance to be running
retry_until [[ '"$(mussel instance show "${instance_id}" | egrep -w "^:state: running")"' ]]
echo "${instance_id} is running"

# get instance ipaddr
ipaddr="$(
  mussel instance show "${instance_id}" \
  | egrep :address:  \
  | awk '{print $2}' \
  | tr '\n' ','
)"
: "${ipaddr:?"should not be empty"}"
ipaddr="${ipaddr%%,}"
echo "${instance_id} ipaddr: ${ipaddr}"

# wait for ssh to be ready
./wakame-vdc/instance-wait4ssh.sh  "${instance_id}"

# install package
./wakame-vdc/instance-exec.sh      "${instance_id}" < ./wakame-vdc/provision-imgdb.sh

# instance state: running -> halted
mussel instance poweroff --force false ${instance_id}
echo "${instance_id} is halting"

# wait for the instance to be halted
retry_until [[ '"$(mussel instance show "${instance_id}" | egrep -w "^:state: halted")"' ]]
echo "${instance_id} is halted"

# instance backup
DB_IMAGE_ID="$(mussel instance backup ${instance_id} --display-name db | egrep ^:image_id: | awk '{print $2}')"
echo "database image id: ${DB_IMAGE_ID}"

# wait for the image to be available
retry_until [[ '"$(mussel image show "${DB_IMAGE_ID}" | egrep -w "^:state: available")"' ]]
echo "${DB_IMAGE_ID} is available"

# instance destroy
mussel instance destroy "${instance_id}"
echo "${instance_id} is deleted"

## create app image

# app display name
display_name="app"

# create an instance
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
echo "${instance_id} is initializing..."

trap 'mussel instance destroy "${instance_id}"' ERR

# wait for the instance to be running
retry_until [[ '"$(mussel instance show "${instance_id}" | egrep -w "^:state: running")"' ]]
echo "${instance_id} is running"

# get instance ipaddr
ipaddr="$(
  mussel instance show "${instance_id}" \
  | egrep :address:  \
  | awk '{print $2}' \
  | tr '\n' ','
)"
: "${ipaddr:?"should not be empty"}"
ipaddr="${ipaddr%%,}"
echo "${instance_id} ipaddr: ${ipaddr}"

# wait for ssh to be ready
./wakame-vdc/instance-wait4ssh.sh  "${instance_id}"

# install package
./wakame-vdc/instance-exec.sh      "${instance_id}" \
		    YUM_HOST="10.0.22.102" \
		    bash -l < ./wakame-vdc/provision-imgapp.sh

# instance state: running -> halted
mussel instance poweroff --force false ${instance_id}
echo "${instance_id} is halting"

# wait for the instance to be halted
retry_until [[ '"$(mussel instance show "${instance_id}" | egrep -w "^:state: halted")"' ]]
echo "${instance_id} is halted"

# instance backup
APP_IMAGE_ID="$(mussel instance backup ${instance_id} --display-name app | egrep ^:image_id: | awk '{print $2}')"
echo "app image id: ${APP_IMAGE_ID}"

# wait for the image to be available
RETRY_WAIT_SEC=180 retry_until [[ '"$(mussel image show "${APP_IMAGE_ID}" | egrep -w "^:state: available")"' ]]
echo "${DB_IMAGE_ID} is available"

# instance destroy
mussel instance destroy "${instance_id}"
echo "${instance_id} is deleted"

echo DB_IMAGE_ID="${DB_IMAGE_ID}"
echo APP_IMAGE_ID="${APP_IMAGE_ID}"

echo "DB_IMAGE_ID=${DB_IMAGE_ID}"   >  ./tmp_image.txt
echo "APP_IMAGE_ID=${APP_IMAGE_ID}" >> tmp_image.txt
