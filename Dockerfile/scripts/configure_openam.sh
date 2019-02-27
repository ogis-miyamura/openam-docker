#!/usr/bin/env bash

wait_for_openam_startup() {
    OPENAM_TEST_URL=${OPENAM_PROTOCOL}://localhost:${OPENAM_PORT}/${OPENAM_CONTEXT}/config/options.htm

    while true; do
        sleep 10
        ##curl -s --max-time 5 -LI ${OPENAM_TEST_URL} | head -n 10
        STATUS=$(curl -s --max-time 5 -LI ${OPENAM_TEST_URL} -o /dev/null -w '%{http_code}')
        echo "INFO: Waiting for the OpenAM Server (${STATUS}, $(tail -1 /usr/local/tomcat/logs/catalina.*.log))"

        if [ ${STATUS} -eq 200 ]; then
            echo "INFO: OpenAM Server startup detected"
            break;
        fi
    done
}

configure_openam() {
    curl \
        --request POST "${OPENAM_URL}/${OPENAM_CONTEXT}/config/configurator" \
        --header "Content-Type:application/x-www-form-urlencoded" \
        \
        --data-urlencode "ACCEPT_LICENSES=true" \
        \
        --data-urlencode "SERVER_URL=${OPENAM_URL}" \
        --data-urlencode "DEPLOYMENT_URI=${OPENAM_CONTEXT}" \
        --data-urlencode "COOKIE_DOMAIN=${OPENAM_COOKIE_DOMAIN}" \
        \
        --data-urlencode "BASE_DIR=${HOME}/openam" \
        --data-urlencode "locale=en_US" \
        --data-urlencode "PLATFORM_LOCALE=en_US" \
        \
        --data-urlencode "AM_ENC_KEY=" \
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
        --data-urlencode "DS_DIRMGRPASSWD=${OPENAM_ADMIN_PASSWORD}"
}

${CATALINA_HOME}/bin/startup.sh

wait_for_openam_startup
configure_openam

catalina.sh stop



# # export OPENAM_COOKIE_DOMAIN=.example.com
# # export OPENAM_ROOT_SUFFIX=dc=openam,dc=example,dc=com

# # export OPENAM_URL=https://${OPENAM_HOSTNAME}:${OPENAM_HTTPS_PORT}
# export OPENAM_URL=http://${OPENAM_HOSTNAME}:8080

# curl --request POST "${OPENAM_URL}/${OPENAM_CONTEXT}/config/configurator" \
#   --header "Content-Type:application/x-www-form-urlencoded" \
#   : "" \
#   : "===== OpenAM misc parameters =====" \
#   --data-urlencode "ACCEPT_LICENSES=true" \
#   : "" \
#   : "===== OpenAM server parameters =====" \
#   --data-urlencode "SERVER_URL=${OPENAM_URL}" \
#   --data-urlencode "DEPLOYMENT_URI=${OPENAM_CONTEXT}" \
#   --data-urlencode "COOKIE_DOMAIN=${OPENAM_COOKIE_DOMAIN}" \
#   : "" \
#   : "===== OpenAM application parameters =====" \
#   --data-urlencode "BASE_DIR=${HOME}/openam" \
#   --data-urlencode "locale=en_US" \
#   --data-urlencode "PLATFORM_LOCALE=en_US" \
#   : "" \
#   : "===== OpenAM amadmin parameters =====" \
#   --data-urlencode "AM_ENC_KEY=" \
#   --data-urlencode "ADMIN_PWD=${OPENAM_ADMIN_PASSWORD}" \
#   --data-urlencode "ADMIN_CONFIRM_PWD=${OPENAM_ADMIN_PASSWORD}" \
#   --data-urlencode "AMLDAPUSERPASSWD=${OPENAM_LDAPADMIN_PASSWORD}" \
#   --data-urlencode "AMLDAPUSERPASSWD_CONFIRM=${OPENAM_LDAPADMIN_PASSWORD}" \
#   : "" \
#   : "===== OpenAM datastore parameters =====" \
#   --data-urlencode "DATA_STORE=embedded" \
#   --data-urlencode "DIRECTORY_SSL=SIMPLE" \
#   --data-urlencode "DIRECTORY_SERVER=localhost" \
#   --data-urlencode "DIRECTORY_PORT=50389" \
#   --data-urlencode "DIRECTORY_ADMIN_PORT=4444" \
#   --data-urlencode "DIRECTORY_JMX_PORT=1689" \
#   --data-urlencode "ROOT_SUFFIX=${OPENAM_ROOT_SUFFIX}" \
#   --data-urlencode "DS_DIRMGRDN=cn=Directory Manager" \
#   --data-urlencode "DS_DIRMGRPASSWD=${OPENAM_ADMIN_PASSWORD}"



# # cat << _EOT_ > /opt/openam-configuration.txt
# # OPENAM_URL=${OPENAM_URL}
# # DEPLOYMENT_URI=${OPENAM_CONTEXT}
# # BASE_DIR=/opt/openam
# # locale=en_US
# # PLATFORM_LOCALE=en_US
# # AM_ENC_KEY=
# # ADMIN_PWD=${OPENAM_ADMIN_PASSWORD}
# # AMLDAPUSERPASSWD=${OPENAM_LDAPADMIN_PASSWORD}
# # COOKIE_DOMAIN=${OPENAM_COOKIE_DOMAIN}
# # ACCEPT_LICENSES=true
# # DATA_STORE=embedded
# # DIRECTORY_SSL=SIMPLE
# # DIRECTORY_SERVER=${OPENAM_HOSTNAME}
# # DIRECTORY_PORT=50389
# # DIRECTORY_ADMIN_PORT=4444
# # DIRECTORY_JMX_PORT=1689
# # ROOT_SUFFIX=${OPENAM_ROOT_SUFFIX}
# # DS_DIRMGRDN=cn=Directory Manager
# # DS_DIRMGRPASSWD=${OPENAM_ADMIN_PASSWORD}
# # _EOT_

# # cat /opt/openam-configuration.txt

# # java \
# #   -jar /opt/openam-configurator-tool-13.0.0-SNAPSHOT/openam-configurator-tool-14.0.0-SNAPSHOT.jar \
# #   --file /opt/openam-configuration.txt

# # java \
# #   -Djavax.net.ssl.trustStore=/opt/cacerts.jks \
# #   -Djavax.net.ssl.trustStorePassword=${OPENAM_ADMIN_PASSWORD} \
# #   -jar /opt/openam-configurator-tool.jar \
# #   -f /opt/openam-configuration.txt

# # set -euo pipefail

# # # Check if the setup has already been completed
# # if [ ! -f  ] 

# # # Instance dir does not exist? Then we need to run setup
# # if [ ! -f ${BASE_DIR}/install.log ] ; then
# #   echo "OpenAM config not found. Configuring.."
# #   chown root:root -R $BASE_DIR
# #   /data/configure.sh &
# # fi

# # echo "Starting the server"
# # sed -i '3i JAVA_OPTS="$JAVA_OPTS -server -Xmx$MAX_HEAP -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=256m  -Dcom.sun.identity.configuration.directory=${BASE_DIR}"' ${CATALINA_HOME}/bin/catalina.sh
# # ${CATALINA_HOME}/bin/catalina.sh run
