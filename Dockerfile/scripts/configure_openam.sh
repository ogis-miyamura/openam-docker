#!/usr/bin/env bash
#
# Configure OpenAM only once

#######################################
# Wait for the OpenAM startup
#######################################
wait_for_openam_startup() {
    OPENAM_TEST_URL=${OPENAM_PROTOCOL}://localhost:${OPENAM_PORT}/${OPENAM_CONTEXT}/config/options.htm

    while true; do
        sleep 10

        STATUS=$(curl -s --max-time 5 -LI ${OPENAM_TEST_URL} -o /dev/null -w '%{http_code}')
        echo "INFO: Waiting for the OpenAM Server (${STATUS}, $(tail -1 /usr/local/tomcat/logs/catalina.*.log))"

        if [ ${STATUS} -eq 200 ]; then
            echo "INFO: OpenAM Server startup detected"
            break;
        fi
    done
}

#######################################
# Configure the OpenAM by configurator
#######################################
configure_openam_by_tool() {
    CONFIGURATION_PARAMS=/var/tmp/openam_configuration
    CONFIGURATION_TOOL=${OPENAM_INSTALLATION_DIR}/$(basename ${OPENAM_CONFIGTOOL_NAME} .zip)

    cat << _EOT_ > ${CONFIGURATION_PARAMS}
SERVER_URL=${OPENAM_URL}
DEPLOYMENT_URI=${OPENAM_CONTEXT}
COOKIE_DOMAIN=${OPENAM_COOKIE_DOMAIN}

BASE_DIR=${OPENAM_HOME}
locale=en_US
PLATFORM_LOCALE=en_US

AM_ENC_KEY=${OPENAM_ENCRYPTION_KEY}
ADMIN_PWD=${OPENAM_ADMIN_PASSWORD}
ADMIN_CONFIRM_PWD=${OPENAM_ADMIN_PASSWORD}
AMLDAPUSERPASSWD=${OPENAM_LDAPADMIN_PASSWORD}
AMLDAPUSERPASSWD_CONFIRM=${OPENAM_LDAPADMIN_PASSWORD}

DATA_STORE=embedded
DIRECTORY_SSL=SIMPLE
DIRECTORY_SERVER=localhost
DIRECTORY_PORT=50389
DIRECTORY_ADMIN_PORT=4444
DIRECTORY_JMX_PORT=1689
ROOT_SUFFIX=${OPENAM_ROOT_SUFFIX}
DS_DIRMGRDN=cn=Directory Manager
DS_DIRMGRPASSWD=${OPENAM_ADMIN_PASSWORD}
_EOT_

    echo "INFO: Execute openam-configurator-tool"

    unzip -q ${CONFIGURATION_TOOL}.zip -d ${OPENAM_INSTALLATION_DIR}
    rm -f ${CONFIGURATION_TOOL}.zip

    echo "127.0.0.1 ${OPENAM_HOSTNAME}" >> /etc/hosts
    java \
        -jar $(ls ${CONFIGURATION_TOOL}/openam-configurator-tool*.jar) \
        --file ${CONFIGURATION_PARAMS} \
        --acceptLicense \
      > ${OPENAM_HOME}/install.log

    result_code=$?

    cat ${OPENAM_HOME}/install.log

    rm -f ${CONFIGURATION_PARAMS}

    return $result_code
}

#######################################
# Main
#######################################
wait_for_openam_startup
configure_openam_by_tool

exit $?
