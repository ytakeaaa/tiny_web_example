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
  strings /metadata/user-data
  . /metadata/user-data
fi
: "${DB_HOST:?"should not be empty"}"
