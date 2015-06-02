#!/bin/bash
#
#
echo "--- start ---"

set -e
set -o pipefail
set -u
set -x

ls ./
pwd

echo "--- unit test ---"
bash ./ciscripts/unit-test.sh

echo "--- rpm build ---"
bash ./ciscripts/rpm-build.sh

echo "--- create repository ---"
bash ./ciscripts/create-repo.sh

cd ciscripts

export IMAGE_ID=wmi-centos1d64
export YUM_HOST=10.0.22.102
export WRITE_FILE=/var/lib/jenkins/jobs/buildtest/workspace/imagefile.txt

echo "--- image build ---"
bash ./image-build.sh

image_ids=($(cat $WRITE_FILE))
export DB_IMAGE_ID=${image_ids[0]}
export APP_IMAGE_ID=${image_ids[1]}
echo DB_IMAGE_ID=$DB_IMAGE_ID
echo APP_IMAGE_ID=$APP_IMAGE_ID

echo "--- web 3 layer ci ---"
bash ./web3layers-ci.sh

echo "--- end ---"
