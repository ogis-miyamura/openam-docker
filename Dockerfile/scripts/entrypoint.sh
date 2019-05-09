#!/usr/bin/env bash
#
# Run systemd

${SUDO_TOMCAT_CMD} ${CATALINA_HOME}/bin/startup.sh

if [ "${OPENAM_CONFIGURATION_MODE}" = "POST" ]; then
    echo "INFO: Start OpenAM post-configure"
    ${OPENAM_INSTALLATION_DIR}/configure_openam.sh
fi

tail -f ${CATALINA_HOME}/logs/catalina.out
