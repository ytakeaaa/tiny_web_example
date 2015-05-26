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

ipaddr="$(< /metadata/meta-data/local-ipv4)"
YUM_HOST="${ipaddr}" ./web3layers-ci.sh
```
