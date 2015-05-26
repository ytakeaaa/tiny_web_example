#!/bin/bash
#
#
set -e
set -x
set -o pipefail

cd spec_integration

bundle install
cp config/webapi.conf.example config/webapi.conf
bundle exec rspec ./spec/webapi_integration_spec.rb
