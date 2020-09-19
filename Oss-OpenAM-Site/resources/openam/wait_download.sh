#!/bin/sh

#
# Download openam.war
#
echo "INFO: Download openam.war"
OPENAM_WAR_PATH=/usr/local/tomcat/webapps/openam.war
if [ ! -e ${OPENAM_WAR_PATH} ]; then
    curl -L ${OPENAM_WAR_URL} -o ${OPENAM_WAR_PATH}
fi

#
# Start Tomcat
#
echo "INFO: Start Tomcat"
${CATALINA_HOME}/bin/catalina.sh jpda run &

#
# Waiting for start OpenAM server
#
echo "INFO: Waiting for start OpenAM server"
while ! grep "Server startup in" ${CATALINA_HOME}/logs/catalina.*.log > /dev/null; do sleep 5; done

#
# OpenAM silent install
#
OPENAM_DONE_FLAG=/opt/shared/DONE-$(hostname)
if [ ! -e ${OPENAM_DONE_FLAG} ]; then
    echo "$(date) INFO: Extract environmental variables on .configParam"
    eval "echo \"$(cat /opt/install/.configParam)\"" > /opt/install/.configParam-comp

    echo "$(date) INFO: Start OpenAM silent install"
    unzip \
        -q /opt/install/openam-distribution-ssoconfiguratortools-15.0.0-SNAPSHOT.zip \
        -d /opt/install/ssoconfiguratortools
    java \
        -jar /opt/install/ssoconfiguratortools/openam-configurator-tool-15.0.0-SNAPSHOT.jar \
        --file /opt/install/.configParam-comp \
        --acceptLicense \
        | tee /opt/install/install.log

    echo "INFO: Cleanup install parameters"
    rm -f /opt/install/.configParam-comp
    unset $(env | grep "^OPENAM_" | sed -e s/=.*//)

    echo "INFO: Initialize completed"
    touch ${OPENAM_DONE_FLAG}
fi

#
# Wait
#
tail -f /dev/null
