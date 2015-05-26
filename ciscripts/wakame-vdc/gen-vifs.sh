#!/bin/bash
#
set -e
set -o pipefail
set -u

cat <<EOS > "${vifs}"
{
 "eth0":{"network":"${network_id}","security_groups":"${security_group_id}"}
}
EOS
