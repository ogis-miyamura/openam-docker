FROM centos:7


# ===== Build command examples =====
#
# docker build . -t openam-buildenv-jdk8
# docker build . -t openam-buildenv-jdk11       --build-arg JDKVERSION=11
# docker build . -t openam-buildenv-jdk11-mvn35 --build-arg JDKVERSION=11 --build-arg MAVENVERSION=35


# ===== Static step =====

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


# ===== Install Maven =====

ARG MAVENVERSION=33

# Install Maven
RUN yum install -y \
      rh-maven${MAVENVERSION} \
 && yum clean all


# ===== Install JDK =====

ARG JDKVERSION=1.8.0

# Install JDK
RUN yum install -y \
      java-${JDKVERSION}-openjdk-devel \
 && yum clean all

# Select specified version of JDK (and ignore warnings)
RUN JDK_HOME=$(alternatives --list | grep java_sdk_${JDKVERSION} | head -1 | cut -f 3) \
 && alternatives --set java  ${JDK_HOME}/bin/java  | true \
 && alternatives --set javac ${JDK_HOME}/bin/javac | true \
 && alternatives --set jar   ${JDK_HOME}/bin/jar   | true


# Create user profile script
RUN echo -e $"export LANG=C \n\
export JAVA_HOME=/usr/lib/jvm/java-${JDKVERSION}-openjdk \n\
source scl_source enable rh-maven${MAVENVERSION}" \
    > /etc/profile.d/maven.sh


# ===== Create user =====

ARG BUILDUSER=builduser
ARG BUILDUSER_PASSWORD=password
ARG BUILDUSER_ID=1000

# Create BUILDUSER
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


USER ${BUILDUSER}
