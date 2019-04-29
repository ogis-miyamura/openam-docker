FROM centos:7

STOPSIGNAL SIGRTMIN+3


# ===== Build command examples =====
#
# docker build . -t devenv-xrdp-jdk8
# docker build . -t devenv-xrdp-jdk11       --build-arg JDKVERSION=11
# docker build . -t devenv-xrdp-jdk11-mvn35 --build-arg JDKVERSION=11 --build-arg MAVENVERSION=35

# ===== Run command examples =====
# sudo sed -ie "s/^SELINUX=enforcing$/SELINUX=disabled/g"
# docker run -d --rm --privileged -p 13389:3389 -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name devenv-xrdp-jdk8 devenv-xrdp-jdk8

# # Build parameters.
# ARG HTTP_PROXY
# ARG HTTPS_PROXY
# ARG NO_PROXY


# ===== Static step =====

# Update and install packages.
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
      make \
      gcc-c++ \
      nodejs \
      npm \
      python-pip \
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
RUN yum install -y \
      centos-release-scl \
 && yum clean all
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


# ===== Install Eclipse =====

RUN \
    cd /opt \
 && curl \
    -L http://ftp.fau.de/eclipse/technology/epp/downloads/release/2018-09/R/eclipse-java-2018-09-linux-gtk-x86_64.tar.gz \
    -o /opt/eclipse.tar.gz \
 && tar -xvf eclipse.tar.gz \
 && rm -f eclipse.tar.gz \
 && ln -s /opt/eclipse/eclipse /usr/bin/eclipse


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


# ===== Create xrdp default user =====

ARG XRDP_USER=${XRDP_USER:-xrdpuser}
ARG XRDP_USER_PASSWORD=${XRDP_PASSWORD:-password}
ARG XRDP_USER_MAIL=${XRDP_USER_MAIL:-xrdpuser@example.net}
ARG XRDP_USER_ID=1000

# Create XRDP_USER
RUN \
    echo "${XRDP_USER}:${XRDP_USER_PASSWORD}:${XRDP_USER_ID}:${XRDP_USER_ID}::/home/${XRDP_USER}:/bin/bash" | newusers \
 && usermod -aG wheel ${XRDP_USER} \
 && sed -e 's/%wheel\(.*\)/#%wheel\1/g' \
        -e 's/#.*%wheel\(.*\)NOPASSWD\(.*\)/%wheel\1NOPASSWD\2/g' \
        -i /etc/sudoers \
 && echo -e $"#!/bin/bash \n\
cd /home/${XRDP_USER} \n\
source /etc/profile \n\
source /etc/bashrc" \
    > /home/${XRDP_USER}/.bashrc \
 && chmod +x /home/${XRDP_USER}/.bashrc


# Enable xrdp service.
RUN \
    ln -s /usr/lib/systemd/system/xrdp.service \
          /etc/systemd/system/multi-user.target.wants/xrdp.service \
 && systemctl enable xrdp

# Install Mate desktop.
RUN \
    echo "mate-session" > /home/${XRDP_USER}/.Xclients \
 && chmod a+x /home/${XRDP_USER}/.Xclients \
 && chown ${XRDP_USER}:${XRDP_USER} /home/${XRDP_USER}/.Xclients

# Make .gitconfig.
COPY DockerfileResources/gitconfig_template /usr/local/src/
RUN \
    printf "cat <<++EOS\n`cat /usr/local/src/gitconfig_template`\n++EOS\n" | sh > /usr/local/src/gitconfig \
 && cp /usr/local/src/gitconfig /root/.gitconfig \
 && cp /usr/local/src/gitconfig /home/${XRDP_USER}/.gitconfig


# Create Applications-Eclipse shortcut.
COPY DockerfileResources/apps_eclipse_template /usr/share/applications/eclipse.desktop


# Stop Firewall service.
RUN systemctl disable firewalld

# Expose RDP port.
EXPOSE 3389

# Run initialize script.
COPY DockerfileResources/*.sh /usr/local/src/
RUN chmod +x /usr/local/src/*.sh

CMD ["/usr/sbin/init"]
