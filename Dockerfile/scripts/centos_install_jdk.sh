#!/usr/bin/env bash
#
# Install and configure OpenJDK

set -eu

if [ -n "${HTTP_PROXY:-''}" ]; then
    echo proxy=${HTTP_PROXY:-''} >> /etc/yum.conf
fi

yum -y install \
    java-${CENTOS7_JDK_VERSION:-''}-openjdk \
    unzip \
    gzip2

yum clean all
