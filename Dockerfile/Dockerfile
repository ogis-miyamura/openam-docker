FROM tomcat:8.0-jre8

MAINTAINER ogis-miyamura

ARG OPENAM_WAR_URL=https://github.com/ogis-miyamura/openam/releases/download/amjp%2F14.0.0-SNAPSHOT/OpenAM-14.0.0-SNAPSHOT.war

RUN \
  curl \
    -L ${OPENAM_WAR_URL} \
    -o ${CATALINA_HOME}/webapps/openam.war

EXPOSE 8080 8443 50389

CMD ["catalina.sh", "run"]
