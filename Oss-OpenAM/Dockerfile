FROM tomcat:${TOMCAT_MAJOR:-"9"}-${JDK_VERSION:-"8"}

# # build docker image
# docker build . -t oss-openam
#
# # start openam as background service
# docker run --rm -it -d -p 8080:8080 --name oss-openam oss-openam
#
# # start openam for remote debug
# docker run --rm -it -d -e JPDA_ADDRESS=8000 -p 8080:8080 -p 8000:8000 --name oss-openam oss-openam /usr/local/tomcat/bin/catalina.sh jpda run
#
# # access url
# http://localhost:8080/openam

#
# Download openam.war
#
RUN \
    OPENAM_WAR_URL=https://github.com/openam-jp/openam/releases/download/14.0.0/openam-14.0.0.war \
&&  OPENAM_WAR_PATH=/usr/local/tomcat/webapps/openam.war \
&&  curl -L ${OPENAM_WAR_URL} -o ${OPENAM_WAR_PATH}
