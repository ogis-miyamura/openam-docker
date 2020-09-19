#!/bin/bash

#
# Console command examples
#
# - Show log process command:   ps aux | grep tail
# - Show log group command:     ps aux | grep "/opends/logs" | grep -v "grep"
# - Stop log command:           kill -STOP xx
# - Stop log group command:     kill -STOP $(ps aux | grep "/opends/logs/" | grep -v "grep" | sed -e 's/ \+/ /g' | cut -d' ' -f 2)
#

#
# Constants
#
TODAY=$(date '+%Y-%m-%d')
OPENAM_DIR=/opt/logs/openam-base-dir
TOMCAT_DIR=/opt/logs/openam-tomcat-logs

#
# Watch one log
#
function tail_one() {
    tail -Fv $1 | awk '/^==> / { f=substr($0, 5, length-8); next } { print f": "$0 }' &
}

#
# Stop watch process
#
function stop_tail() {
    echo "Stop watch log group: '$1'"
    kill -STOP $(ps aux | grep "$1" | grep -v "grep" | sed -e 's/ \+/ /g' | cut -d' ' -f 2)
}

#
# Watch logs
#
for d in ${TOMCAT_DIR}/{catalina.${TODAY}.log,localhost.${TODAY}.log,localhost_access_log.${TODAY}.txt}; do \
    tail_one ${d}; done

for d in ${OPENAM_DIR}/openam/log/{access.csv,activity.csv,authentication.csv,configuration.csv}; do \
    tail_one ${d}; done

for d in ${OPENAM_DIR}/openam/debug/{Authentication,Configuration,CoreSystem,Federation,IdRepo,Policy,Session,amUpgrade}; do \
    tail_one ${d}; done

for d in ${OPENAM_DIR}/opends/logs/{access,errors,replication}; do \
    tail_one ${d}; done

#
# Apply tail log switchs ("N" -> Stop)
#
if [ "${TAIL_TOMCAT_LOGS^^}" = "N" ];   then stop_tail "${TOMCAT_DIR}"; fi
if [ "${TAIL_OPENAM_LOGS^^}" = "N" ];   then stop_tail "/openam/log/"; fi
if [ "${TAIL_OPENAM_DEBUG^^}" = "N" ];  then stop_tail "/openam/debug/"; fi
if [ "${TAIL_OPENDJ_LOGS^^}" = "N" ];   then stop_tail "/opends/logs/"; fi

#
# Wait
#
tail -f /dev/null
