# ===== Build preprocess image =====

# Docker build base arguments
ARG IMAGE_FROM

FROM centos:centos7 as download-env

# OpenAM application parameters
ENV OPENAM_CONFIGTOOL_NAME ${OPENAM_CONFIGTOOL_NAME:-openam-configurator-tool.jar}

# Install basic packages
RUN \
    yum install -y \
      sudo \
      zip \
      unzip \
      bzip2 \
      git \
      gcc-c++ \
      make \
      centos-release-scl \
 && yum clean all

# Install Maven and create user profile script
ENV MAVENVERSION 33

RUN \
    yum install -y \
      rh-maven${MAVENVERSION} \
 && yum clean all

ENV JDKVERSION 1.8.0

# Install JDK
RUN \
    yum install -y \
      java-${JDKVERSION}-openjdk-devel \
 && yum clean all

RUN \
    echo -e $"export LANG=C \n\
export JAVA_HOME=/usr/lib/jvm/java-${JDKVERSION}-openjdk \n\
source scl_source enable rh-maven${MAVENVERSION}" \
    > /etc/profile.d/maven.sh

# Build OpenAM
RUN \
    GIT_URL_PREFIX=https://github.com/openam-jp \
 && GIT_BRANCH=master \
 && source /etc/profile.d/maven.sh \
 && for r in \
        forgerock-parent \
        forgerock-bom \
        forgerock-build-tools \
        forgerock-i18n-framework \
        forgerock-guice \
        forgerock-guava \
        forgerock-ui \
        forgerock-commons \
        opendj-sdk \
        forgerock-persistit \
        opendj \
        forgerock-bloomfilter \
        openam \
    ; do \
        git clone --depth=1 ${GIT_URL_PREFIX}/${r}.git -b ${GIT_BRANCH}; \
        mvn install -DskipTests -f ${r}; \
    done

# Stash openam.war and configurator-tool
RUN \
    find ./openam/openam-server -name *.war | xargs -I% mv % /tmp/openam.war \
 && cp -rp ./openam/openam-tools/openam-configurator-tool/target /tmp/openam-configurator-tool \
 && cd /tmp \
 && zip -r openam-configurator-tool.zip ./openam-configurator-tool/*



# ===== Build target image =====

FROM ${IMAGE_FROM}


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
ARG OPENAM_CONFIGTOOL_NAME
ARG OPENAM_CONFIGURATION_MODE



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
ENV OPENAM_CONFIGTOOL_NAME ${OPENAM_CONFIGTOOL_NAME:-openam-configurator-tool.zip}

# OpenAM server parameters
# - format:   ${OPENAM_PROTOCOL}://${OPENAM_HOSTNAME}:${OPENAM_PORT}/${OPENAM_CONTEXT}/
# - example:  http://openam.example.com:8080/openam/
ENV OPENAM_HOSTNAME ${OPENAM_HOSTNAME:-openam.example.com}
ENV OPENAM_PROTOCOL ${OPENAM_PROTOCOL:-http}
ENV OPENAM_PORT ${OPENAM_PORT:-8080}
ENV OPENAM_CONTEXT ${OPENAM_CONTEXT:-openam}
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


# ===== Configure Tomcat =====

# Modify CookieProcessor in Tomcat configration
RUN \
    case ${CENTOS7_TOMCAT_VERSION} in \
        8.5.* | 9.0.* ) \
            sed -i.org \
                -e 's|</Context>|    <CookieProcessor className="org.apache.tomcat.util.http.LegacyCookieProcessor"/>\n</Context>|' \
                ${CATALINA_HOME}/conf/context.xml \
            ;; \
    esac


# ===== OpanAM installation =====

# Deploy OpenAM modules
RUN \
    mkdir -p ${CATALINA_HOME}/webapps \
 && mkdir -p ${OPENAM_INSTALLATION_DIR} \
 && mkdir -p ${OPENAM_HOME}

COPY --from=download-env /tmp/openam.war ${CATALINA_HOME}/webapps/${OPENAM_CONTEXT}.war
COPY --from=download-env /tmp/${OPENAM_CONFIGTOOL_NAME} ${OPENAM_INSTALLATION_DIR}/

ENV OPENAM_CONFIGURATION_MODE ${OPENAM_CONFIGURATION_MODE:-NO}

# Start OpenAM once and configure
COPY scripts/configure_openam.sh ${OPENAM_INSTALLATION_DIR}/
RUN \
    chmod +x ${OPENAM_INSTALLATION_DIR}/configure_openam.sh \
 && if [ "${OPENAM_CONFIGURATION_MODE^^}" = "PRE" ]; then \
        echo "INFO: Start OpenAM pre-configure" \
     && ${SUDO_TOMCAT_CMD} ${CATALINA_HOME}/bin/startup.sh \
     && ls -al ${OPENAM_INSTALLATION_DIR} \
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
