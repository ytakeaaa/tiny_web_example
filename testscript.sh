#!/bin/bash
#
#
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
export WRITE_FILE=imagefile.txt

echo "--- image build ---"
bash ./image-build.sh
