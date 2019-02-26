FROM centos:centos7

MAINTAINER ogis-miyamura

ARG OPENAM_VERSION
ENV OPENAM_VERSION ${OPENAM_VERSION:-13.0.0}

# 8.5.37 / 8.0.53
ARG TOMCAT_VERSION
ENV TOMCAT_VERSION ${TOMCAT_VERSION:-8.0.53}

ARG JDK_VERSION
ENV JDK_VERSION ${JDK_VERSION:-1.8.0}

ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

WORKDIR /opt


# Setup packages.
RUN \
    yum -y install \
        java-${JDK_VERSION}-openjdk \
        unzip \
 && yum clean all


# Install Tomcat 8.5.
COPY tomcat.service /etc/systemd/system/
RUN \
    chmod 755 /etc/systemd/system/tomcat.service \
 && groupadd tomcat \
 && useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat \
 && curl -LO https://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
 && tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
 && rm -f apache-tomcat-${TOMCAT_VERSION}.tar.gz \
 && ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat


# Deploy OpenAM war.
COPY OpenAM-${OPENAM_VERSION}.war ${CATALINA_HOME}/webapps/
RUN \
    unzip -q \
        ${CATALINA_HOME}/webapps/OpenAM-${OPENAM_VERSION}.war \
        -d ${CATALINA_HOME}/webapps/openam


# Start service.
RUN \
    chown -R tomcat:tomcat /opt/* \
 && systemctl enable tomcat


EXPOSE 8080

CMD ["/sbin/init"]
