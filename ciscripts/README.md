## JenkinsCI

シェルジョブに下記内容を定義して下さい。
なお、`APP_IMAGE_ID`と`DB_IMAGE_ID`には、それぞれ新規作成したマシンイメージIDで置き換えて下さい。

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

APP_IMAGE_ID="wmi-********" \
 DB_IMAGE_ID="wmi-********" \
    YUM_HOST="${ipaddr}" \
 ./web3layers-ci.sh
```
