#!/bin/sh

apk --update add curl
rm -rf /var/cache/apk/*

curl -L https://github.com/openam-jp/openam/releases/download/14.0.0/openam-14.0.0.war \
    -o /opt/openam-webapps-dir/openam.war

touch /opt/openam-webapps-dir/DONE_DOWNLOAD_OPENAM
