#!/bin/bash
#
#
set -e
set -o pipefail
set -u
set -x

# run instances

## db

eval "$(./runner-db.sh)"
db_id="${instance_id}"

## app

eval "$(./runner-app.sh)"
app_id="${instance_id}"

# cleanup instances

./instance-kill.sh "${db_id}"
./instance-kill.sh "${app_id}"
