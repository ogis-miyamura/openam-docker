FROM centos:7
MAINTAINER ogis-miyamura

STOPSIGNAL SIGRTMIN+3

# Build parameters.
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG http_proxy
ARG https_proxy
ARG NO_PROXY

ARG XRDP_USER=${XRDP_USER:-xrdpuser}
ARG XRDP_PASSWORD=${XRDP_PASSWORD:-P@ssw0rd}

ARG JENKINS_GIT_USER
ARG JENKINS_GIT_MAIL
ARG JDK_DEFAULT_VERSION
ARG PHANTOMJS_PACKAGE
ARG MAVEN_LOCALREPO_PATH

# Set Maven yum repos.
RUN \
  curl \
    -x ${HTTP_PROXY} \
    -L http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo \
    -o /etc/yum.repos.d/epel-apache-maven.repo \
 && sed -i s/\\\$releasever/7/g /etc/yum.repos.d/epel-apache-maven.repo

# Update and install packages.
RUN \
    echo "proxy=${HTTP_PROXY}" >> /etc/yum.conf \
 && yum -y install \
      epel-release \
 && yum update -y \
 && yum groupinstall -y \
      "MATE Desktop" \
 && yum install -y \
      sudo \
      bash \
      zip \
      unzip \
      bzip2 \
      git \
      xrdp \
      tigervnc-server \
      expect \
 && yum install -y \
      java-\${JDK_DEFAULT_VERSION}-openjdk \
      java-\${JDK_DEFAULT_VERSION}-openjdk-devel \
      apache-maven \
      make \
      gcc-c++ \
      nodejs \
      npm \
      python-pip \
 && pip install --proxy="${HTTP_PROXY/http:\/\//}" -U pip \
 && pip install --proxy="${HTTP_PROXY/http:\/\//}" -U awscli \
 && yum remove -y \
      mate-screensaver \
      NetworkManager \
 && rm -rf /var/cache/yum/* \
 && yum autoremove -y \
 && yum clean all

# Install xrdp and tigervnc-server.
RUN \
    ln -s /usr/lib/systemd/system/xrdp.service \
          /etc/systemd/system/multi-user.target.wants/xrdp.service

# Create xrdp user.
RUN \
    sed -e 's/%wheel\(.*\)/#%wheel\1/g' \
        -e 's/#.*%wheel\(.*\)NOPASSWD\(.*\)/%wheel\1NOPASSWD\2/g' \
        -i /etc/sudoers \
 && useradd -m ${XRDP_USER} -s /bin/bash \
 && gpasswd -a ${XRDP_USER} wheel \
 && printf "\
set timeout -1\n\
spawn passwd ${XRDP_USER}\n\
expect \"New password:\" { send \"${XRDP_PASSWORD}\\\n\" }\n\
expect \"Retype new password:\" { send \"${XRDP_PASSWORD}\\\n\" }\n\
expect eof\n\
" | expect

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

# Make proxy setting template for Maven and insert to settings.xml.
COPY DockerfileResources/mvn_settings_template.xml /usr/local/src/
RUN \
    export HTTP_PROXY_HOST=`echo \${HTTP_PROXY} | sed -e 's|.*//\(.\+\):.*|\1|'` \
 && export HTTP_PROXY_PORT=`echo \${HTTP_PROXY} | sed -e 's|.*:\(.\+\)$|\1|'` \
 && printf "cat <<++EOS\n`cat /usr/local/src/mvn_settings_template.xml`\n++EOS\n" | sh > /home/${XRDP_USER}/.m2/settings.xml \
 && cd /usr/share/apache-maven/conf \
 && mv ./settings.xml ./settings.xml.original \
 && cp -f /home/${XRDP_USER}/.m2/settings.xml ./settings.xml \
 && sed -e "s/offline>true</offline>false</" ./settings.xml > ./settings.online.xml

# Set proxy for npm.
RUN \
    npm -g config set proxy ${HTTP_PROXY} \
 && npm -g config set https-proxy ${HTTPS_PROXY} \
 && npm -g config set registry http://registry.npmjs.org/ \
 && npm -g install coffeescript marked node-pre-gyp

# Install phantomjs from archive file.
RUN \
    cd /usr/local/src \
 && curl \
    -x ${HTTP_PROXY} \
    -L https://bitbucket.org/ariya/phantomjs/downloads/${PHANTOMJS_PACKAGE}.tar.bz2 \
    -o /usr/local/src/${PHANTOMJS_PACKAGE}.tar.bz2 \
 && tar jxfv ${PHANTOMJS_PACKAGE}.tar.bz2 \
 && rm -f ${PHANTOMJS_PACKAGE}.tar.bz2 \
 && mv ${PHANTOMJS_PACKAGE} /usr/lib/ \
 && ln -s /usr/lib/${PHANTOMJS_PACKAGE}/bin/phantomjs /usr/bin/phantomjs

# Install Eclipse.
RUN \
    cd /opt \
 && curl \
    -x ${HTTP_PROXY} \
    -L http://ftp.fau.de/eclipse/technology/epp/downloads/release/2018-09/R/eclipse-java-2018-09-linux-gtk-x86_64.tar.gz \
    -o /opt/eclipse.tar.gz \
 && tar -xvf eclipse.tar.gz \
 && rm -f eclipse.tar.gz \
 && ln -s /opt/eclipse/eclipse /usr/bin/eclipse

# Install Eclipse Japanese plugin (Pleiades).
RUN \
    mkdir -p /opt/eclipse/dropins/pleiades \
 && cd /opt/eclipse/dropins/pleiades \
 && curl \
    -x ${HTTP_PROXY} \
    -L http://ftp.jaist.ac.jp/pub/mergedoc/pleiades/build/stable/pleiades.zip \
    -o ./pleiades.zip \
 && unzip pleiades.zip \
 && rm -rf pleiades.zip
    # - Disabled because Eclipse crashes on startup. -
    #  && echo "-javaagent:/opt/eclipse/dropins/pleiades/plugins/jp.sourceforge.mergedoc.pleiades/pleiades.jar" \
    #         >> /opt/eclipse/eclipse.ini

# Create Applications-Eclipse shortcut.
COPY DockerfileResources/apps_eclipse_template /usr/share/applications/eclipse.desktop

# Stop Firewall service.
RUN systemctl disable firewalld

# Expose RDP port.
EXPOSE 3389

# Run initialize script.
COPY DockerfileResources/*.sh /usr/local/src/
RUN chmod +x /usr/local/src/*.sh
CMD [ "sh", "/usr/local/src/initialize.sh" ]
