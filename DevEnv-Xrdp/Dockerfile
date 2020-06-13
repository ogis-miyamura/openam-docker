FROM centos:7

STOPSIGNAL SIGRTMIN+3

ENV container docker


# ===== Put scripts and templates =====

COPY DockerfileResources /usr/local/src/


# ===== Install packages =====

RUN \
    case ${HTTP_PROXY} in \
        http* ) \
            echo "proxy=${HTTP_PROXY}" >> /etc/yum.conf; \
            ;; \
    esac

# Update and install packages
RUN \
    yum update -y \
 && yum -y install \
      epel-release \
 && yum update \
      epel-release --disablerepo=epel \
 && yum -y groupinstall "X Window System" \
 && yum -y install \
      mate-desktop \
      mate-desktop-libs \
      mate-* \
      caja.x86_64 \
      system-config-language.noarch \
      system-config-date \
 && yum autoremove -y \
      mate-screensaver \
      NetworkManager \
 && yum install -y \
      xrdp \
      tigervnc-server \
 && yum install -y \
      sudo \
      bash \
      zip \
      unzip \
      bzip2 \
      git \
      gcc-c++ \
      make \
      centos-release-scl \
 && rm -rf /var/cache/yum/* \
 && yum clean all


# ===== Install Maven =====

ARG MAVENVERSION=33

# Install Maven
RUN \
    yum install -y \
      rh-maven${MAVENVERSION} \
 && rm -rf /var/cache/yum/* \
 && yum clean all


# ===== Install JDK =====

ARG JDKVERSION=1.8.0
ARG WORKDIR=/home/xrdpuser/eclipse-workspace

# Install JDK
RUN \
    yum install -y \
      java-${JDKVERSION}-openjdk-devel \
 && rm -rf /var/cache/yum/* \
 && yum clean all

# Select specified version of JDK (and ignore warnings)
RUN \
    JDK_HOME=$(alternatives --list | grep java_sdk_${JDKVERSION} | head -1 | cut -f 3) \
 && alternatives --set java  ${JDK_HOME}/bin/java  | true \
 && alternatives --set javac ${JDK_HOME}/bin/javac | true \
 && alternatives --set jar   ${JDK_HOME}/bin/jar   | true


# ===== Create xrdp user =====

ARG XRDP_USER=${XRDP_USER:-xrdpuser}
ARG XRDP_PASSWORD=${XRDP_PASSWORD:-password}
ARG XRDP_USER_EMAIL=${XRDP_USER_EMAIL:-xrdpuser@example.net}

RUN \
    echo "${XRDP_USER}:${XRDP_PASSWORD}:${XRDP_USER_ID}:${XRDP_USER_ID}::/home/${XRDP_USER}:/bin/bash" | newusers \
 && usermod -aG wheel ${XRDP_USER} \
 && sed -e 's/%wheel\(.*\)/#%wheel\1/g' \
        -e 's/#.*%wheel\(.*\)NOPASSWD\(.*\)/%wheel\1NOPASSWD\2/g' \
        -i /etc/sudoers \
 && echo -e $"#!/bin/bash \n\
export XRDP_USER=${XRDP_USER} \n\
cd /home/${XRDP_USER} \n\
source /etc/profile \n\
source /etc/bashrc" \
    > /home/${XRDP_USER}/.bashrc \
 && chmod +x /home/${XRDP_USER}/.bashrc

RUN \
    case ${HTTP_PROXY} in \
        http* ) \
            mkdir -p /home/${XRDP_USER}/.m2; \
            export HTTP_PROXY_HOST=`echo \${HTTP_PROXY} | sed -e 's|.*//\(.\+\):.*|\1|'`; \
            export HTTP_PROXY_PORT=`echo \${HTTP_PROXY} | sed -e 's|.*:\(.\+\)$|\1|'`; \
            printf "cat <<++EOS\n`cat /usr/local/src/mvn_settings_template`\n++EOS\n" | sh > /home/${XRDP_USER}/.m2/settings.xml; \
            \
            ;; \
    esac


# ===== Install Eclipse =====

# https://www.eclipse.org/downloads/packages/
#ARG ECLIPSE_PACKAGE=2018-09/R/eclipse-java-2018-09-linux-gtk-x86_64.tar.gz
ARG ECLIPSE_PACKAGE=2020-06/RC2/eclipse-jee-2020-06-R-linux-gtk-x86_64.tar.gz
ARG ECLIPSE_ARCHIVE=eclipse.tar.gz

RUN \
    cd /opt \
 && curl \
        $(case ${HTTP_PROXY} in http* ) echo "-x ${HTTP_PROXY}";; esac) \
        -L http://ftp.fau.de/eclipse/technology/epp/downloads/release/${ECLIPSE_PACKAGE} \
        -o ${ECLIPSE_ARCHIVE} \
 && tar xf ${ECLIPSE_ARCHIVE} \
 && chown -R ${XRDP_USER}:${XRDP_USER} eclipse* \
 && rm -f ${ECLIPSE_ARCHIVE} \
 && ln -s /opt/eclipse/eclipse /usr/bin/eclipse \
 && cp /usr/local/src/apps_eclipse_template /usr/share/applications/eclipse.desktop


# ===== Install VS Code =====

ARG VSCODE_PACKAGE=https://go.microsoft.com/fwlink/?LinkID=620884
ARG VSCODE_ARCHIVE=vscode.tar.gz

RUN \
    cd /opt \
 && curl \
        $(case ${HTTP_PROXY} in http* ) echo "-x ${HTTP_PROXY}";; esac) \
        -L ${VSCODE_PACKAGE} \
        -o ${VSCODE_ARCHIVE} \
 && tar xf ${VSCODE_ARCHIVE} \
 && chown -R ${XRDP_USER}:${XRDP_USER} vscode* \
 && rm -f ${VSCODE_ARCHIVE} \
 && ln -s /opt/VSCode-linux-x64/bin/code /usr/bin/vscode \
 && cp /usr/local/src/apps_vscode_template /usr/share/applications/vscode.desktop


# ===== Enable CentOS systemd =====

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ "/sys/fs/cgroup" ]


# ===== Enable xrdp service =====

RUN \
    ln -s /usr/lib/systemd/system/xrdp.service \
          /etc/systemd/system/multi-user.target.wants/xrdp.service \
 && systemctl enable xrdp


# ===== Clone OpenAM source codes =====

# Create user profile script
RUN echo -e $"export LANG=C \n\
export JAVA_HOME=/usr/lib/jvm/java-${JDKVERSION}-openjdk \n\
source scl_source enable rh-maven${MAVENVERSION}" \
    > /etc/profile.d/maven.sh

# Clone OpenAM source codes and build

USER ${XRDP_USER}

RUN \
    GIT_URL_PREFIX=https://github.com/openam-jp \
 && GIT_BRANCH=master \
 && sudo mkdir -p ${WORKDIR} \
 && sudo chown -R ${XRDP_USER}:${XRDP_USER} ${WORKDIR} \
 && cd ${WORKDIR} \
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
        git clone ${GIT_URL_PREFIX}/${r}.git -b ${GIT_BRANCH}; \
        mvn install -DskipTests -f ${r}; \
    done

USER root


# ===== Configure Mate desktop =====

USER ${XRDP_USER}

RUN \
    echo "mate-session" > /home/${XRDP_USER}/.Xclients \
 && chmod a+x /home/${XRDP_USER}/.Xclients \
 && echo "mate-session" > /home/${XRDP_USER}/.Xauthority

USER root


# ===== Install Tomcat =====

ARG TOMCATVERSION=9
ARG TOMCATVERSION_DETAIL=9.0.36
ARG CATALINA_HOME=/opt/tomcat90
ARG TOMCAT_DOWNLOAD_HOST=https://archive.apache.org/dist/tomcat
ARG TOMCAT_PACKAGE=tomcat-${TOMCATVERSION}/v${TOMCATVERSION_DETAIL}/bin/apache-tomcat-${TOMCATVERSION_DETAIL}.tar.gz
ARG TOMCAT_ARCHIVE=apache-tomcat-${TOMCATVERSION}.tar.gz

RUN \
    cd /opt \
 && curl \
        $(case ${HTTP_PROXY} in http* ) echo "-x ${HTTP_PROXY}";; esac) \
        -L ${TOMCAT_DOWNLOAD_HOST}/${TOMCAT_PACKAGE} \
        -o ${TOMCAT_ARCHIVE} \
 && tar xf ${TOMCAT_ARCHIVE} \
 && chown -R ${XRDP_USER}:${XRDP_USER} apache-tomcat-* \
 && rm -f ${TOMCAT_ARCHIVE} \
 && mv $(find . -name apache-tomcat-\* -type d) ${CATALINA_HOME}


# Create user profile script
RUN \
    echo -e $"export CATALINA_HOME=${CATALINA_HOME} \n\
export CATALINA_BASE=${CATALINA_HOME}" \
    > /etc/profile.d/tomcat.sh


# ===== Install AWS CLI =====

ARG AWSCLI_HOST=https://s3.amazonaws.com/aws-cli
ARG AWSCLI_ARCHIVE=awscli-bundle.zip

RUN \
    curl \
        $(case ${HTTP_PROXY} in http* ) echo "-x ${HTTP_PROXY}";; esac) \
        -L ${AWSCLI_HOST}/${AWSCLI_ARCHIVE} \
        -o ${AWSCLI_ARCHIVE} \
 && unzip ${AWSCLI_ARCHIVE} \
 && rm -f ${VSCODE_ARCHIVE} \
 && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws


# ===== Set up develop environment =====

# Create .gitconfig.
RUN \
    printf "cat <<++EOS\n`cat /usr/local/src/gitconfig_template`\n++EOS\n" | sh > /usr/local/src/gitconfig \
 && cp /usr/local/src/gitconfig /root/.gitconfig \
 && cp /usr/local/src/gitconfig /home/${XRDP_USER}/.gitconfig \
 && chown ${XRDP_USER}:${XRDP_USER} /home/${XRDP_USER}/.gitconfig \
 && case ${HTTP_PROXY} in \
        http* ) \
            git config --global http.proxy ${HTTP_PROXY}; \
            git config --global https.proxy ${HTTP_PROXY}; \
            ;; \
    esac


# Set proxy for npm.
RUN \
    case ${HTTP_PROXY} in \
        http* ) \
                npm -g config set proxy ${HTTP_PROXY} \
             && npm -g config set https-proxy ${HTTP_PROXY} \
             && npm -g config set registry http://registry.npmjs.org/ \
            ;; \
    esac \
 && yum install -y \
      make \
 && rm -rf /var/cache/yum/* \
 && yum clean all


CMD [ "/sbin/init" ]
