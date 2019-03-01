#!/usr/bin/env bash
#
# Install and configure Tomcat

set -eu

# Add Tomcat group and user
groupadd tomcat
useradd -M -s /bin/nologin -g tomcat -d ${CATALINA_HOME} tomcat


# Download Tomcat binary
cd /usr/local

TOMCAT_TGZ_NAME=apache-tomcat-${CENTOS7_TOMCAT_VERSION}
curl \
    -L ${CENTOS7_TOMCAT_URL} \
    -o ${TOMCAT_TGZ_NAME}.tar.gz


tar -xzf ${TOMCAT_TGZ_NAME}.tar.gz
rm -f ${TOMCAT_TGZ_NAME}.tar.gz
ln -s /usr/local/apache-tomcat-${CENTOS7_TOMCAT_VERSION} ${CATALINA_HOME}


# Configure Tomcat service
TOMCAT_SYSTEMD_UNIT=/etc/systemd/system/tomcat.service
cat << _EOT_ > ${TOMCAT_SYSTEMD_UNIT}
[Unit]
Description=Apache Tomcat ${CENTOS7_TOMCAT_VERSION}
After=syslog.target network.target

[Service]
User=tomcat
Group=tomcat
Type=oneshot
PIDFile=${CATALINA_HOME}/tomcat.pid
RemainAfterExit=yes

Environment=CATALINA_HOME=${CATALINA_HOME}
Environment=CATALINA_BASE=${CATALINA_HOME}
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=${CATALINA_HOME}/bin/startup.sh
ExecStop=${CATALINA_HOME}/bin/shutdown.sh
ExecReStart=${CATALINA_HOME}/bin/shutdown.sh;${CATALINA_HOME}/bin/startup.sh

[Install]

WantedBy=multi-user.target
_EOT_

chmod 644 ${TOMCAT_SYSTEMD_UNIT}


# Prepare to start Tomcat service
chown -R tomcat. /usr/local/apache-tomcat-${CENTOS7_TOMCAT_VERSION}
chown -R tomcat. ${CATALINA_HOME}

systemctl enable tomcat
