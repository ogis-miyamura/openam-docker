#!/bin/sh

# echo "INFO: Waiting for download openam.war"
# while [ ! -e /opt/readonly/DONE_DOWNLOAD_OPENAM ]; do sleep 5; done
echo "$(date) INFO: Download openam.war"
curl -L https://github.com/openam-jp/openam/releases/download/14.0.0/openam-14.0.0.war \
    -o /usr/local/tomcat/webapps/openam.war

echo "$(date) INFO: Start Tomcat"
${CATALINA_HOME}/bin/catalina.sh jpda run &

echo "$(date) INFO: Waiting for start OpenAM server"
while ! grep "Server startup in" ${CATALINA_HOME}/logs/catalina.*.log > /dev/null; do sleep 5; done
sleep 5

echo "$(date) INFO: Start OpenAM silent install"
unzip \
    -q /opt/install/openam-distribution-ssoconfiguratortools-15.0.0-SNAPSHOT.zip \
    -d /opt/install/ssoconfiguratortools
java \
    -jar /opt/install/ssoconfiguratortools/openam-configurator-tool-15.0.0-SNAPSHOT.jar \
    --file /opt/install/.configParam \
    --acceptLicense \
    | tee /opt/install/install.log

# echo "INFO: Cleanup parameter file"
# rm -f /opt/install/.configParam

touch /opt/shared/DONE-$(hostname)

tail -f /dev/null
