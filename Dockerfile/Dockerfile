FROM tomcat:8.0-jre8

MAINTAINER ogis-miyamura


# OpenAM application parameters
ARG OPENAM_VERSION=14.0.0-SNAPSHOT
ARG OPENAM_WAR_URL=https://github.com/ogis-miyamura/openam/releases/download/amjp%2F${OPENAM_VERSION}/OpenAM-${OPENAM_VERSION}.war
ARG OPENAM_CONFIGTOOL_URL=https://github.com/ogis-miyamura/openam/releases/download/amjp%2F${OPENAM_VERSION}/openam-configurator-tool-13.0.0-SNAPSHOT.zip
ARG CATALINA_OPTS="-Xmx2048m -server"

# OpenAM server parameters
# - format:   ${OPENAM_PROTOCOL}://${OPENAM_HOSTNAME}:${OPENAM_HTTP(s)_PORT}/${OPENAM_CONTEXT}/
# - example:  http://openam.example.com:8080/sso/
ARG OPENAM_HOSTNAME=openam.example.com
ARG OPENAM_PROTOCOL=http
ARG OPENAM_PORT=8080
ARG OPENAM_CONTEXT=sso
ARG OPENAM_URL=${OPENAM_PROTOCOL}://${OPENAM_HOSTNAME}:${OPENAM_PORT}
ARG OPENAM_COOKIE_DOMAIN=.example.com
ARG OPENAM_ROOT_SUFFIX=dc=openam,dc=example,dc=com

# OpenAM amadmin parameters
ARG OPENAM_ADMIN_PASSWORD=amadM1n
ARG OPENAM_LDAPADMIN_PASSWORD=ldapadM1n


# Copy arguments to environment variables
ENV OPENAM_VERSION=${OPENAM_VERSION}
ENV OPENAM_WAR_URL=${OPENAM_WAR_URL}
ENV OPENAM_CONFIGTOOL_URL=${OPENAM_CONFIGTOOL_URL}
ENV CATALINA_OPTS=${CATALINA_OPTS}

ENV OPENAM_HOSTNAME=${OPENAM_HOSTNAME}
ENV OPENAM_PROTOCOL=${OPENAM_PROTOCOL}
ENV OPENAM_PORT=${OPENAM_PORT}
ENV OPENAM_CONTEXT=${OPENAM_CONTEXT}
ENV OPENAM_URL=${OPENAM_URL}
ENV OPENAM_COOKIE_DOMAIN=${OPENAM_COOKIE_DOMAIN}
ENV OPENAM_ROOT_SUFFIX=${OPENAM_ROOT_SUFFIX}

ENV OPENAM_ADMIN_PASSWORD=${OPENAM_ADMIN_PASSWORD}
ENV OPENAM_LDAPADMIN_PASSWORD=${OPENAM_LDAPADMIN_PASSWORD}


WORKDIR /opt

# Download and put modules
RUN \
  curl \
    -L ${OPENAM_WAR_URL} \
    -o ${CATALINA_HOME}/webapps/${OPENAM_CONTEXT}.war
  # && curl \
  #   -L ${OPENAM_CONFIGTOOL_URL} \
  #   -o /opt/openam-configurator-tool.zip \
  # && unzip -q /opt/openam-configurator-tool.zip \
  # && rm -f /opt/openam-configurator-tool.zip

# Put run scripts into container
COPY scripts /opt/scripts
RUN chmod +x /opt/scripts/*.sh \
  && : "===== Configure OpenAM =====" \
  && /opt/scripts/configure_openam.sh

# Expose ports
EXPOSE ${OPENAM_PORT}
