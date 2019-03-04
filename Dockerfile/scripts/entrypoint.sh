#!/usr/bin/env bash
#
# Run systemd

${SUDO_TOMCAT_CMD} ${CATALINA_HOME}/bin/startup.sh

tail -f ${CATALINA_HOME}/logs/catalina.out
