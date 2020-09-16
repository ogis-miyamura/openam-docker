#!/bin/sh

echo "$(date) INFO: Waiting for install OpenAM-Primary"
while [ ! -e /opt/shared/DONE-openam-primary ]; do sleep 5; done

echo "$(date) INFO: Start install OpenAM-Secondary"
sh /opt/install/wait_download.sh

tail -f /dev/null
