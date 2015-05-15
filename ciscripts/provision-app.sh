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

[[ -f /etc/yum.repos.d/tiny-web-example.repo ]]
sed -i "s,127.0.0.1,${YUM_HOST}," /etc/yum.repos.d/tiny-web-example.repo
yum repolist

# tiny-web-example depends on epel to install nginx
rpm -qa epel-release* | egrep -q epel-release || {
  rpm -Uvh http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/i386/epel-release-6-8.noarch.rpm
  sed -i \
   -e 's,^#baseurl,baseurl,' \
   -e 's,^mirrorlist=,#mirrorlist=,' \
   -e 's,http://download.fedoraproject.org/pub/epel/,http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/,' \
   /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo
  yum install -y ca-certificates
}

yum install -y tiny-web-example
