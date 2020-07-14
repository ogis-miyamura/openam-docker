FROM centos:7


# ===== Build command examples =====
#
# docker build . -t openam-buildenv-jdk8
# docker build . -t openam-buildenv-jdk8        --build-arg BUILDUSER_PASSWORD=password  --build-arg JDKVERSION=1.8.0
# docker build . -t openam-buildenv-jdk11       --build-arg BUILDUSER_PASSWORD=password  --build-arg JDKVERSION=11
# docker build . -t openam-buildenv-jdk11-mvn35 --build-arg BUILDUSER_PASSWORD=password  --build-arg JDKVERSION=11     --build-arg MAVENVERSION=35


# ===== SetUp basic packages =====

# Install basic packages
RUN yum install -y \
      sudo \
      unzip \
      bzip2 \
      git \
      gcc-c++ \
      make \
      centos-release-scl \
 && yum clean all

# Install Git latest version
RUN cd /usr/local/src/ \
 && git clone \
      git://git.kernel.org/pub/scm/git/git.git \
      -b master \
 && yum -y install \
      curl-devel \
      expat-devel \
      gettext-devel \
      openssl-devel \
      zlib-devel \
 && yum -y remove \
      git \
 && yum clean all \
 && cd git \
 && make prefix=/usr/local all \
 && make prefix=/usr/local install \
 && hash -r


# ===== Install JDK =====

##ARG JDKVERSION=1.8.0
ARG JDKVERSION=11

# Install JDK
RUN yum install -y \
      java-${JDKVERSION}-openjdk-devel \
 && yum clean all

# Select specified version of JDK (and ignore warnings)
RUN JDK_HOME=$(alternatives --list | grep java_sdk_${JDKVERSION} | head -1 | cut -f 3) \
 && alternatives --set java  ${JDK_HOME}/bin/java  | true \
 && alternatives --set javac ${JDK_HOME}/bin/javac | true \
 && alternatives --set jar   ${JDK_HOME}/bin/jar   | true


# ===== Install Maven =====

ARG MAVENVERSION=33

# Install Maven
RUN yum install -y \
      rh-maven${MAVENVERSION} \
 && yum clean all

# Create user profile script
RUN echo -e $"export LANG=C \n\
export JAVA_HOME=/usr/lib/jvm/java-${JDKVERSION}-openjdk \n\
source scl_source enable rh-maven${MAVENVERSION}" \
    > /etc/profile.d/maven.sh


# ===== SetUp user =====

ARG BUILDUSER=builduser
ARG BUILDUSER_PASSWORD=password
ARG BUILDUSER_ID=1000
ARG WORKDIR=/home/${BUILDUSER}/work

# Add user
RUN echo "${BUILDUSER}:${BUILDUSER_PASSWORD}:${BUILDUSER_ID}:${BUILDUSER_ID}::/home/${BUILDUSER}:/bin/bash" | newusers \
 && usermod -aG wheel ${BUILDUSER} \
 && echo "${BUILDUSER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create login script
RUN echo -e $"#!/bin/bash \n\
cd /home/${BUILDUSER} \n\
source /etc/profile \n\
source /etc/bashrc" \
    > /home/${BUILDUSER}/.bashrc \
 && chmod +x /home/${BUILDUSER}/.bashrc


# ===== Install Tomcat9 =====

ARG TOMCAT_MAJOR=9
ARG TOMCAT_DETAIL=9.0.36
ARG TOMCAT_DIR=tomcat90
ARG TOMCAT_INSTANCES_DIR=tomcat-instances

RUN cd /home/${BUILDUSER} \
 && curl -LO https://ftp.riken.jp/net/apache/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_DETAIL}/bin/apache-tomcat-${TOMCAT_DETAIL}.tar.gz \
 && tar xzf apache-tomcat-*.tar.gz \
 && rm -rf apache-tomcat-*.tar.gz \
 && mv $(ls . | grep apache-tomcat) ${TOMCAT_DIR} \
 && chown -R ${BUILDUSER}:${BUILDUSER} ${TOMCAT_DIR} \
 && mkdir -p /home/${BUILDUSER}/${TOMCAT_INSTANCES_DIR}


# ===== Clone and build OpenAM =====

USER ${BUILDUSER}

RUN \
    GIT_URL_PREFIX=https://github.com/openam-jp \
 && GIT_BRANCH=master \
 && mkdir -p ${WORKDIR} \
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
        forgerock-persistit \
        forgerock-bloomfilter \
        opendj-sdk \
        opendj \
        openam \
    ; do \
        git clone ${GIT_URL_PREFIX}/${r}.git -b ${GIT_BRANCH}; \
        mvn install -DskipTests=true -Dmaven.javadoc.skip=true -f ${r}; \
    done
