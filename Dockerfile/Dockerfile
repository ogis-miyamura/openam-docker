# FROM Maven , git pull 
# $ mvn install -f forgerock-parent
# $ mvn install -f forgerock-bom
# $ mvn install -f forgerock-build-tools
# $ mvn install -f forgerock-i18n-framework
# $ mvn install -f forgerock-guice
# $ mvn install -f forgerock-guava
# $ mvn install -f forgerock-ui
# $ mvn install -DskipTests -f forgerock-commons
# $ mvn install -f opendj-sdk
# $ mvn install -DskipTests -f forgerock-persistit
# $ mvn install -f opendj
# $ mvn install -f forgerock-bloomfilter
# $ mvn install -f openam
# Stash openam.war

ARG IMAGE_FROM
FROM ${IMAGE_FROM}

MAINTAINER ogis-miyamura


# ===== Get build arguments =====

# Docker build base arguments
ARG IMAGE_FROM
ARG SUDO_TOMCAT_CMD

# CentOS7 package parameters
ARG CENTOS7_TOMCAT_MAJOR
ARG CENTOS7_TOMCAT_VERSION
ARG CENTOS7_JDK_VERSION
ARG CENTOS7_TOMCAT_URL

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


# ===== Set up environment parameters =====

# CentOS7 package parameters
ENV CENTOS7_TOMCAT_MAJOR ${CENTOS7_TOMCAT_MAJOR}
ENV CENTOS7_TOMCAT_VERSION ${CENTOS7_TOMCAT_VERSION}
ENV CENTOS7_JDK_VERSION ${CENTOS7_JDK_VERSION}
ENV CENTOS7_TOMCAT_URL ${CENTOS7_TOMCAT_URL:-https://archive.apache.org/dist/tomcat/tomcat-${CENTOS7_TOMCAT_MAJOR}/v${CENTOS7_TOMCAT_VERSION}/bin/apache-tomcat-${CENTOS7_TOMCAT_VERSION}.tar.gz}

# OpenAM application parameters
ENV OPENAM_VERSION ${OPENAM_VERSION:-14.0.0-SNAPSHOT}
ENV OPENAM_WAR_URL ${OPENAM_WAR_URL:-https://github.com/ogis-miyamura/openam/releases/download/amjp%2F${OPENAM_VERSION}/OpenAM-${OPENAM_VERSION}.war}
ENV OPENAM_CONFIGTOOL_URL ${OPENAM_CONFIGTOOL_URL:-https://github.com/ogis-miyamura/openam/releases/download/amjp%2F${OPENAM_VERSION}/openam-configurator-tool-13.0.0-SNAPSHOT.zip}

# OpenAM server parameters
# - format:   ${OPENAM_PROTOCOL}://${OPENAM_HOSTNAME}:${OPENAM_PORT}/${OPENAM_CONTEXT}/
# - example:  http://openam.example.com:8080/sso/
ENV OPENAM_HOSTNAME ${OPENAM_HOSTNAME:-openam.example.com}
ENV OPENAM_PROTOCOL ${OPENAM_PROTOCOL:-http}
ENV OPENAM_PORT ${OPENAM_PORT:-8080}
ENV OPENAM_CONTEXT ${OPENAM_CONTEXT:-sso}
ENV OPENAM_URL ${OPENAM_URL:-${OPENAM_PROTOCOL}://${OPENAM_HOSTNAME}:${OPENAM_PORT}}
ENV OPENAM_COOKIE_DOMAIN ${OPENAM_COOKIE_DOMAIN:-.example.com}
ENV OPENAM_ROOT_SUFFIX ${OPENAM_ROOT_SUFFIX:-dc=openam,dc=example,dc=com}
ENV OPENAM_HOME ${OPENAM_HOME:-/opt/openam}
ENV OPENAM_INSTALLATION_DIR ${OPENAM_INSTALLATION_DIR:-/opt/install}

# OpenAM amadmin parameters
ENV OPENAM_ENCRYPTION_KEY ${OPENAM_ENCRYPTION_KEY:-##AmEnC@@}
ENV OPENAM_ADMIN_PASSWORD ${OPENAM_ADMIN_PASSWORD:-adM1npassword}
ENV OPENAM_LDAPADMIN_PASSWORD ${OPENAM_LDAPADMIN_PASSWORD:-ldapadM1npassword}

# Tomcat parameters
ENV CATALINA_HOME ${CATALINA_HOME:-/usr/local/tomcat}
ENV CATALINA_OPTS ${CATALINA_OPTS:-"-Xmx2048m -server"}


# ===== CentOS package installation =====

# Install JDK and Tomcat for CentOS
COPY scripts/centos_install_jdk.sh ${OPENAM_INSTALLATION_DIR}/
COPY scripts/centos_install_tomcat.sh ${OPENAM_INSTALLATION_DIR}/
RUN \
    case ${IMAGE_FROM} in \
        centos* ) \
            echo "INFO: Install OpenJDK ${CENTOS7_JDK_VERSION}" \
         && chmod +x ${OPENAM_INSTALLATION_DIR}/centos_install_jdk.sh \
         && ${OPENAM_INSTALLATION_DIR}/centos_install_jdk.sh \
            \
         && echo "INFO: Install Tomcat ${CENTOS7_TOMCAT_VERSION}" \
         && chmod +x ${OPENAM_INSTALLATION_DIR}/centos_install_tomcat.sh \
         && ${OPENAM_INSTALLATION_DIR}/centos_install_tomcat.sh \
            ;; \
    esac


# ===== OpanAM installation =====

# Download OpenAM modules
RUN \
    mkdir -p ${CATALINA_HOME}/webapps \
 && curl \
      -L ${OPENAM_WAR_URL} \
      -o ${CATALINA_HOME}/webapps/${OPENAM_CONTEXT}.war \
 && mkdir -p ${OPENAM_INSTALLATION_DIR} \
 && mkdir -p ${OPENAM_HOME} \
 && curl \
      -L ${OPENAM_CONFIGTOOL_URL} \
      -o ${OPENAM_INSTALLATION_DIR}/$(basename ${OPENAM_CONFIGTOOL_URL})


# Start OpenAM once and configure
COPY scripts/configure_openam.sh ${OPENAM_INSTALLATION_DIR}/
RUN \
    if [ "${OPENAM_PRECONFIGURE}" = "y" ]; then \
        echo "INFO: Start OpenAM pre-configure" \
     && ${SUDO_TOMCAT_CMD} ${CATALINA_HOME}/bin/startup.sh \
     && chmod +x ${OPENAM_INSTALLATION_DIR}/configure_openam.sh \
     && ${OPENAM_INSTALLATION_DIR}/configure_openam.sh \
     && ${SUDO_TOMCAT_CMD} ${CATALINA_HOME}/bin/shutdown.sh \
    ; fi


# ===== Prepare to run container =====

# Set working directory
WORKDIR ${OPENAM_HOME}

# Expose ports
EXPOSE ${OPENAM_PORT}

# Put entrypoint script
COPY scripts/entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh

CMD ["/opt/entrypoint.sh"]
