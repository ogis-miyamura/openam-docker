#!/bin/sh

# tail -F \
#     /var/tmp/openam-base-dir/openam/debug/{Authentication,Configuration,CoreSystem,Federation,IdRepo,Policy,Session,amUpgrade} \
#     /var/tmp/openam-base-dir/openam/log/{access.csv,activity.csv,authentication.csv,configuration.csv} \
#     /var/tmp/openam-base-dir/opends/logs/{access} \
#     /var/tmp/openam-tomcat-logs/{catalina.out,*.log} \
#     /dev/null \
#     | awk '/^==> / {a=substr($0, 5, length-8); next} {print a":"$0}'

tail -F /var/tmp/openam-base-dir/openam/log/access.csv &
tail -F /var/tmp/openam-base-dir/openam/log/activity.csv &
tail -F /var/tmp/openam-base-dir/openam/log/authentication.csv &
tail -F /var/tmp/openam-base-dir/openam/log/configuration.csv &

tail -F /var/tmp/openam-base-dir/openam/debug/Authentication &
tail -F /var/tmp/openam-base-dir/openam/debug/Configuration &
tail -F /var/tmp/openam-base-dir/openam/debug/CoreSystem &
tail -F /var/tmp/openam-base-dir/openam/debug/Federation &
tail -F /var/tmp/openam-base-dir/openam/debug/IdRepo &
tail -F /var/tmp/openam-base-dir/openam/debug/Policy &
tail -F /var/tmp/openam-base-dir/openam/debug/Session &
tail -F /var/tmp/openam-base-dir/openam/debug/amUpgrade &

tail -F /var/tmp/openam-base-dir/opends/logs/access &
tail -F /var/tmp/openam-base-dir/opends/logs/errors &
tail -F /var/tmp/openam-base-dir/opends/logs/replication &

tail -F /var/tmp/openam-tomcat-logs/catalina.$(date '+%Y-%m-%d').log &
tail -F /var/tmp/openam-tomcat-logs/localhost.$(date '+%Y-%m-%d').log &
tail -F /var/tmp/openam-tomcat-logs/localhost_access_log.$(date '+%Y-%m-%d').txt &

tail -f /dev/null
