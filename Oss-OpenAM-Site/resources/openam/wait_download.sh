#!/bin/sh

echo "$(date) INFO: Download openam.war"
curl -L ${OPENAM_WAR_URL} \
    -o /usr/local/tomcat/webapps/openam.war

echo "$(date) INFO: Start Tomcat"
${CATALINA_HOME}/bin/catalina.sh jpda run &

echo "$(date) INFO: Waiting for start OpenAM server"
while ! grep "Server startup in" ${CATALINA_HOME}/logs/catalina.*.log > /dev/null; do sleep 5; done
sleep 5

echo "$(date) INFO: Extract environmental variables on .configParam"
eval "echo \"$(cat /opt/install/.configParam)\"" > /opt/install/.configParam-comp
cat /opt/install/.configParam-comp

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
unset $(compgen -v | grep "OPENAM_")

echo "INFO: Initialize completed"
touch /opt/shared/DONE-$(hostname)

tail -f /dev/null
