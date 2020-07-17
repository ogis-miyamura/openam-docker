FROM centos:7


# ===== Build command examples =====
#
# docker build . -t openam-buildenv
# docker build . -t openam-buildenv-mvn35  --build-arg BUILDUSER_PASSWORD=password  --build-arg MAVENVERSION=35


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

# Install various versions of JDK
RUN yum install -y \
      java-1.8.0-openjdk-devel \
      java-11-openjdk-devel \
 && yum clean all

## Remove java from alternatives
RUN for JDK in $(alternatives --display java | grep -E "^/usr/lib/jvm" | cut -d " " -f 1); do \
      alternatives --remove java ${JDK}; \
    done

# Register java to alternatives
RUN for JDK in $(ls -l /usr/lib/jvm | grep -v "1.7" | grep -E "^d" | cut -d " " -f 9); do \
      JDK_BIN=/usr/lib/jvm/${JDK}/bin; \
      alternatives --install /usr/bin/java java ${JDK_BIN}/java 1 \
        --slave /usr/local/java_home java_home /usr/lib/jvm/${JDK} \
        --slave /usr/bin/javac javac ${JDK_BIN}/javac \
        --slave /usr/bin/javah javah ${JDK_BIN}/javah \
        --slave /usr/bin/javap javap ${JDK_BIN}/javap \
        --slave /usr/bin/javadoc javadoc ${JDK_BIN}/javadoc \
        --slave /usr/bin/jar jar ${JDK_BIN}/jar \
        --slave /usr/bin/keytool keytool ${JDK_BIN}/keytool \
        --slave /usr/bin/rmiregistry rmiregistry ${JDK_BIN}/rmiregistry \
        --slave /usr/bin/jarsigner jarsigner ${JDK_BIN}/jarsigner \
        --slave /usr/bin/rmic rmic ${JDK_BIN}/rmic \
        ; \
       && alternatives --set java ${JDK_BIN}/java; \
    done


# ===== Install Maven =====

ARG MAVENVERSION=33

# Install Maven
RUN yum install -y \
      rh-maven${MAVENVERSION} \
 && yum clean all

# Create user profile script
RUN echo -e $"export LANG=C \n\
export JAVA_HOME=/usr/local/java_home \n\
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


# ===== Install various versions of Tomcat =====

ARG TOMCAT_DIR=tomcat90
ARG TOMCAT_INSTANCES_DIR=tomcat-instances

USER ${BUILDUSER}

RUN cd /home/${BUILDUSER} \
 && for TOMCAT_MAJOR in 7 8 9 10; do \
      case $TOMCAT_MAJOR in \
        7) TOMCAT_DETAIL=7.0.105;; \
        8) TOMCAT_DETAIL=8.5.57;; \
        9) TOMCAT_DETAIL=9.0.37;; \
        10) TOMCAT_DETAIL=10.0.0-M7;; \
      esac; \
      TOMCAT_ARCHIVE=apache-tomcat-${TOMCAT_DETAIL}; \
      curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_DETAIL}/bin/${TOMCAT_ARCHIVE}.tar.gz; \
      tar xzf ${TOMCAT_ARCHIVE}.tar.gz; \
      mv ${TOMCAT_ARCHIVE} tomcat${TOMCAT_MAJOR}; \
    done \
 && rm -rf apache-tomcat-*.tar.gz \
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
