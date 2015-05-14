#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -u
set -x

hostname

if [[ -f /metadata/user-data ]]; then
  . /metadata/user-data
fi
: "${DB_HOST:?"should not be empty"}"
: "${YUM_HOST:?"should not be empty"}"

ls -l /etc/yum.repos.d/tiny-web-example.repo
yum repolist
