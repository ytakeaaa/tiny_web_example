#!/bin/bash
#
#
set -e
set -o pipefail
set -u
set -x

# myaddr

eval "$(./myaddr.sh)"
yum_host="${ipaddr}"

# run instances

## db

eval "$(./runner-db.sh)"
db_id="${instance_id}"
echo "YUM_HOST=${yum_host}" | tee -a user_data_app.txt

## app

eval "$(./runner-app.sh)"
app_id="${instance_id}"

# cleanup instances

./instance-kill.sh "${db_id}"
./instance-kill.sh "${app_id}"
