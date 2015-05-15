## Script Chain

1. run `runner-app.sh`
  1. run `create-app.sh`
  2. run `provision-app.sh`
  3. generate `user_data_app.txt`
2. run `runner-db.sh`
  1. run `create-db.sh`
  2. run `provision-db.sh`

## JenkinsCI

Add the following code to JenkinsCI shell job.

```
#!/bin/bash
#
#
set -e
set -o pipefail
set -u
set -x

cd ciscripts
ls -l
./web3layers-ci.sh
```
