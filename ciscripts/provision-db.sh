#!/bin/bash
#
# requires:
#  bash
#  mysqladmin, mysql
#
set -e
set -o pipefail
set -u
set -x

until mysqladmin -uroot ping; do
  sleep 1
done

dbname="wordpress"
dbuser="wordpressuser"
dbpass="password"
dbacl="10.%"

mysqladmin -uroot drop   ${dbname} <<< "Y" || :
mysqladmin -uroot create ${dbname} --default-character-set=utf8

mysql -uroot mysql <<EOS
  GRANT ALL PRIVILEGES ON ${dbname}.* TO ${dbuser}@'${dbacl}' IDENTIFIED BY '${dbpass}';
  FLUSH PRIVILEGES;
  SELECT * FROM user WHERE User = '${dbuser}' \G
EOS
