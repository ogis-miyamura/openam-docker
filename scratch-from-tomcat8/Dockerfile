FROM tomcat:8.0-jre8

MAINTAINER ogis-miyamura

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG JENKINS_HOST
ARG JENKINS_OPENAM_WAR_PATH
ARG OPENAM_VERSION
ARG JDK_VERSION
ARG CATALINA_OPTS

RUN \
    curl \
      -L http://${JENKINS_HOST}/${JENKINS_OPENAM_WAR_PATH} \
      -o ${CATALINA_HOME}/webapps/openam.war

## Configure SSL/TLS access
#RUN \
#    perl -0pi.bak -e 's/<!--\n    <Connector port="8443"/<Connector port="8443" maxHttpHeaderSize="102400" keystoreFile="\/opt\/server.keystore" keystorePass="$ENV{'KEYSTORE_PASS'}"/' $CATALINA_HOME/conf/server.xml \
# && perl -0pi.bak -e 's/sslProtocol="TLS" \/>\n    -->/sslProtocol="TLS" \/>/' $CATALINA_HOME/conf/server.xml

EXPOSE 8080 8443 50389

CMD ["catalina.sh", "run"]
