#!/bin/bash

#
# Constants
#
TODAY=$(date '+%Y-%m-%d')
OPENAM_DIR=/opt/logs/openam-base-dir
TOMCAT_DIR=/opt/logs/openam-tomcat-logs

#
# Watch one log group
#
function tail_one() {
    tail -Fv $1 | awk '/^==> / { f=substr($0, 5, length-8); next } { print f": "$0 }' &
}

#
# Watch logs
#
for d in ${TOMCAT_DIR}/{catalina.${TODAY}.log,localhost.${TODAY}.log,localhost_access_log.${TODAY}.txt}; do \
    tail_one ${d}; done

for d in ${OPENAM_DIR}/openam/debug/{Authentication,Configuration,CoreSystem,Federation,IdRepo,Policy,Session,amUpgrade}; do \
    tail_one ${d}; done

for d in ${OPENAM_DIR}/openam/log/{access.csv,activity.csv,authentication.csv,configuration.csv}; do \
    tail_one ${d}; done

for d in ${OPENAM_DIR}/opends/logs/{access,errors,replication}; do \
    tail_one ${d}; done

#
# Wait
#
tail -f /dev/null
