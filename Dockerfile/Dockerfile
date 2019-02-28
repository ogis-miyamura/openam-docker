FROM tomcat:8.0-jre8

MAINTAINER ogis-miyamura


# OpenAM application parameters
ARG OPENAM_VERSION
ARG OPENAM_WAR_URL
ARG OPENAM_CONFIGTOOL_URL
ARG OPENAM_PRECONFIGURE

# OpenAM server parameters
ARG OPENAM_HOSTNAME
ARG OPENAM_PROTOCOL
ARG OPENAM_PORT
ARG OPENAM_CONTEXT
ARG OPENAM_URL
ARG OPENAM_COOKIE_DOMAIN
ARG OPENAM_ROOT_SUFFIX
ARG OPENAM_HOME
ARG OPENAM_INSTALLATION_DIR

# OpenAM amadmin parameters
ARG OPENAM_ENCRYPTION_KEY
ARG OPENAM_ADMIN_PASSWORD
ARG OPENAM_LDAPADMIN_PASSWORD

# Tomcat parameters
ARG CATALINA_OPTS


# OpenAM application parameters
ENV OPENAM_VERSION ${OPENAM_VERSION:-14.0.0-SNAPSHOT
ENV OPENAM_WAR_URL ${OPENAM_WAR_URL:-https://github.com/ogis-miyamura/openam/releases/download/amjp%2F${OPENAM_VERSION}/OpenAM-${OPENAM_VERSION}.war}
ENV OPENAM_CONFIGTOOL_URL ${OPENAM_CONFIGTOOL_URL:-https://github.com/ogis-miyamura/openam/releases/download/amjp%2F${OPENAM_VERSION}/openam-configurator-tool-13.0.0-SNAPSHOT.zip}
ENV OPENAM_PRECONFIGURE ${OPENAM_PRECONFIGURE:-y}

# OpenAM server parameters
# - format:   ${OPENAM_PROTOCOL}://${OPENAM_HOSTNAME}:${OPENAM_PORT}/${OPENAM_CONTEXT}/
# - example:  http://openam.example.com:8080/sso/
ENV OPENAM_HOSTNAME ${OPENAM_HOSTNAME:-openam.example.com}
ENV OPENAM_PROTOCOL ${OPENAM_PROTOCOL:-http}
ENV OPENAM_PORT ${OPENAM_PORT:-8080}
ENV OPENAM_CONTEXT ${OPENAM_CONTEXT:-sso}
ENV OPENAM_URL ${OPENAM_URL:-${OPENAM_PROTOCOL}://${OPENAM_HOSTNAME}:${OPENAM_PORT}}
ENV OPENAM_COOKIE_DOMAIN ${OPENAM_COOKIE_DOMAIN:-.example.com}
ENV OPENAM_ROOT_SUFFIX ${OPENAM_ROOT_SUFFIX:-dc openam,dc example,dc com}
ENV OPENAM_HOME ${OPENAM_HOME:-/opt/openam}
ENV OPENAM_INSTALLATION_DIR ${OPENAM_INSTALLATION_DIR:-/opt/install}

# OpenAM amadmin parameters
ENV OPENAM_ENCRYPTION_KEY ${OPENAM_ENCRYPTION_KEY:-##AmEnC@@}
ENV OPENAM_ADMIN_PASSWORD ${OPENAM_ADMIN_PASSWORD:-adM1npassword}
ENV OPENAM_LDAPADMIN_PASSWORD ${OPENAM_LDAPADMIN_PASSWORD:-ldapadM1npassword}

# Tomcat parameters
ENV CATALINA_OPTS ${CATALINA_OPTS:-"-Xmx2048m -server"}


# Set working directory
WORKDIR ${OPENAM_HOME}

# Download modules
RUN \
    curl \
      -L ${OPENAM_WAR_URL} \
      -o ${CATALINA_HOME}/webapps/${OPENAM_CONTEXT}.war \
 && mkdir -p ${OPENAM_INSTALLATION_DIR} \
 && curl \
      -L ${OPENAM_CONFIGTOOL_URL} \
      -o ${OPENAM_INSTALLATION_DIR}/$(basename ${OPENAM_CONFIGTOOL_URL})

# Put management scripts into container
COPY scripts ${OPENAM_INSTALLATION_DIR}
RUN chmod +x ${OPENAM_INSTALLATION_DIR}/*.sh

# Start OpenAM once and configure
RUN \
    if [ "${OPENAM_PRECONFIGURE}" = "y" ]; then \
        echo "INFO: Start OpenAM pre-configure" \
     && ${CATALINA_HOME}/bin/startup.sh \
     && ${OPENAM_INSTALLATION_DIR}/configure_openam.sh \
     && ${CATALINA_HOME}/bin/shutdown.sh \
    ; fi

# Expose ports
EXPOSE ${OPENAM_PORT}
