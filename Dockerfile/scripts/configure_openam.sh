#!/usr/bin/env bash

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

configure_openam() {
    OPENAM_CONFIGURE_URL=${OPENAM_PROTOCOL}://localhost:${OPENAM_PORT}/${OPENAM_CONTEXT}/config/configurator
    cat << _EOT_ > /opt/configure_once.sh
#!/usr/bin/env bash
curl \
    --request POST "${OPENAM_CONFIGURE_URL}" \
    --header "Content-Type:application/x-www-form-urlencoded" \
    \
    --data-urlencode "SERVER_URL=${OPENAM_URL}" \
    --data-urlencode "DEPLOYMENT_URI=${OPENAM_CONTEXT}" \
    --data-urlencode "COOKIE_DOMAIN=${OPENAM_COOKIE_DOMAIN}" \
    \
    --data-urlencode "BASE_DIR=${HOME}/openam" \
    --data-urlencode "locale=en_US" \
    --data-urlencode "PLATFORM_LOCALE=en_US" \
    \
    --data-urlencode "AM_ENC_KEY=${OPENAM_ENCRYPTION_KEY}" \
    --data-urlencode "ADMIN_PWD=${OPENAM_ADMIN_PASSWORD}" \
    --data-urlencode "ADMIN_CONFIRM_PWD=${OPENAM_ADMIN_PASSWORD}" \
    --data-urlencode "AMLDAPUSERPASSWD=${OPENAM_LDAPADMIN_PASSWORD}" \
    --data-urlencode "AMLDAPUSERPASSWD_CONFIRM=${OPENAM_LDAPADMIN_PASSWORD}" \
    \
    --data-urlencode "DATA_STORE=embedded" \
    --data-urlencode "DIRECTORY_SSL=SIMPLE" \
    --data-urlencode "DIRECTORY_SERVER=localhost" \
    --data-urlencode "DIRECTORY_PORT=50389" \
    --data-urlencode "DIRECTORY_ADMIN_PORT=4444" \
    --data-urlencode "DIRECTORY_JMX_PORT=1689" \
    --data-urlencode "ROOT_SUFFIX=${OPENAM_ROOT_SUFFIX}" \
    --data-urlencode "DS_DIRMGRDN=cn=Directory Manager" \
    --data-urlencode "DS_DIRMGRPASSWD=${OPENAM_ADMIN_PASSWORD}" \
    \
    --data-urlencode "acceptLicense=true"
_EOT_

    echo "INFO: Configure and cleanup"
    chmod +x /opt/configure_once.sh
    /opt/configure_once.sh
    rm -f configure_once.sh

    cat ${HOME}/openam/install.log
}

# Run OpenAM for configure
${CATALINA_HOME}/bin/startup.sh

wait_for_openam_startup
configure_openam

# Stop OpenAM
${CATALINA_HOME}/bin/shutdown.sh
