FROM centos:7

STOPSIGNAL SIGRTMIN+3

ENV container docker


# ===== Put scripts and templates =====

COPY DockerfileResources /usr/local/src/
RUN \
    chmod +x /usr/local/src/*.sh


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
 && yum groupinstall -y \
      "MATE Desktop" \
 && yum install -y \
      sudo \
      bash \
      zip \
      unzip \
      bzip2 \
      git \
      gcc-c++ \
      nodejs \
      npm \
      xrdp \
      tigervnc-server \
 && yum autoremove -y \
      mate-screensaver \
      NetworkManager \
 && rm -rf /var/cache/yum/* \
 && yum clean all


# ===== Install Maven =====

ARG MAVENVERSION=33

# Install Maven
RUN \
    yum install -y \
      centos-release-scl \
 && yum install -y \
      rh-maven${MAVENVERSION} \
 && rm -rf /var/cache/yum/* \
 && yum clean all


# ===== Install JDK =====

ARG JDKVERSION=1.8.0

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


# Create user profile script
RUN echo -e $"export LANG=C \n\
export JAVA_HOME=/usr/lib/jvm/java-${JDKVERSION}-openjdk \n\
source scl_source enable rh-maven${MAVENVERSION}" \
    > /etc/profile.d/maven.sh


# ===== Install Eclipse =====

ARG ECLIPSE_PACKAGE=2018-09/R/eclipse-java-2018-09-linux-gtk-x86_64.tar.gz

RUN \
    cd /opt \
 && case ${HTTP_PROXY} in \
        http* ) \
            curl \
              -x ${HTTP_PROXY} \
              -LO http://ftp.fau.de/eclipse/technology/epp/downloads/release/${ECLIPSE_PACKAGE} \
            ;; \
        * ) \
            curl \
              -LO http://ftp.fau.de/eclipse/technology/epp/downloads/release/${ECLIPSE_PACKAGE} \
            ;; \
    esac \
 && tar -xvf $(ls eclipse-*.tar.gz) \
 && rm -f $(ls eclipse-*.tar.gz) \
 && ln -s /opt/eclipse/eclipse /usr/bin/eclipse \
 && cp /usr/local/src/apps_eclipse_template /usr/share/applications/eclipse.desktop


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


# ===== Install Mate desktop =====

RUN \
    echo "mate-session" > /home/${XRDP_USER}/.Xclients \
 && chmod a+x /home/${XRDP_USER}/.Xclients \
 && chown ${XRDP_USER}:${XRDP_USER} /home/${XRDP_USER}/.Xclients


# ===== Install Tomcat =====

ARG TOMCATVERSION=90
ARG TOMCAT_PACKAGE=tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz

RUN \
    cd /opt \
 && case ${HTTP_PROXY} in \
        http* ) \
            curl \
              -x ${HTTP_PROXY} \
              -LO http://ftp.tsukuba.wide.ad.jp/software/apache/tomcat/${TOMCAT_PACKAGE} \
            ;; \
        * ) \
            curl \
              -LO http://ftp.tsukuba.wide.ad.jp/software/apache/tomcat/${TOMCAT_PACKAGE} \
            ;; \
    esac \
 && tar xzf $(ls apache-tomcat-*.tar.gz) \
 && rm -rf $(ls apache-tomcat-*.tar.gz) \
 && mv $(find . -name apache-tomcat-\* -type d) /opt/tomcat${TOMCATVERSION}

# Create user profile script
RUN \
    echo -e $"export CATALINA_HOME=/opt/tomcat${TOMCATVERSION} \n\
export CATALINA_BASE=/opt/tomcat${TOMCATVERSION}" \
    > /etc/profile.d/tomcat.sh

# Create OpenAM context
RUN \
    source /etc/profile.d/tomcat.sh \
 && mkdir -p ${CATALINA_HOME}/conf/Catalina/localhost \
 && echo -e '<Context \n\
  path="/openam" \n\
  docBase="/opt/openam/" \n\
  reloadable="true" \n\
  crossContext="true" \n\
  antiJARLocking="true" \n\
  antiResourceLocking="true" \n\
  />' \
    > ${CATALINA_HOME}/conf/Catalina/localhost/openam.xml


# ===== Install AWS CLI =====

RUN \
    case ${HTTP_PROXY} in \
        http* ) \
            curl \
              -x ${HTTP_PROXY} \
              -LO https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip \
            ;; \
        * ) \
            curl \
              -LO https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip \
            ;; \
    esac \
 && unzip awscli-bundle.zip \
 && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws


# ===== Set up develop environment =====

# Create .gitconfig.
RUN \
    printf "cat <<++EOS\n`cat /usr/local/src/gitconfig_template`\n++EOS\n" | sh > /usr/local/src/gitconfig \
 && cp /usr/local/src/gitconfig /root/.gitconfig \
 && cp /usr/local/src/gitconfig /home/${XRDP_USER}/.gitconfig \
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


CMD ["/usr/local/src/initialize.sh"]
