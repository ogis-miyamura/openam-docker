# Accept container image name defined in .env as parameters
ARG AM_IMAGE
FROM ${AM_IMAGE}

# Install build tools
RUN yum install -y \
      sudo \
      tar \
      unzip \
      bzip2 \
      git \
      gcc \
      g++ \
      make \
 && rm -rf /var/cache/yum/* \
 && yum clean all

# Install Maven
# Accept Maven version defined in .env as parameters
ARG MVN_VERSION
RUN cd /opt \
 && curl https://archive.apache.org/dist/maven/maven-3/${MVN_VERSION}/binaries/apache-maven-${MVN_VERSION}-bin.tar.gz | tar zx \
 && ln -s apache-maven-${MVN_VERSION} apache-maven \
 && echo 'export PATH=$PATH:/opt/apache-maven/bin' | tee -a /etc/profile
