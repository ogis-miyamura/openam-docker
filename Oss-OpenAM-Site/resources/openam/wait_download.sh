#!/bin/sh

echo "INFO: Waiting for download openam.war"
while [ ! -e /opt/readonly/DONE_DOWNLOAD_OPENAM ]; do sleep 5; done

cp /opt/readonly/*.war /usr/local/tomcat/webapps/

echo "INFO: Start Tomcat"
${CATALINA_HOME}/bin/catalina.sh jpda run &

echo "INFO: Waiting for start OpenAM server"
while ! grep "Server startup in" ${CATALINA_HOME}/logs/catalina.*.log > /dev/null; do sleep 5; done

# echo "INFO: Start OpenAM silent install"
# unzip \
#     -q /opt/install/openam-distribution-ssoconfiguratortools-15.0.0-SNAPSHOT.zip \
#     -d /opt/install/ssoconfiguratortools
# java \
#     -jar /opt/install/ssoconfiguratortools/openam-configurator-tool-15.0.0-SNAPSHOT.jar \
#     --file /opt/install/.configParam \
#     --acceptLicense \
#     | tee /opt/install/install.log

# echo "INFO: Cleanup parameter file"
# rm -f /opt/install/.configParam

tail -f /dev/null
