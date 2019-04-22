#!/bin/bash

chown -R ${XRDP_USER}. /home/${XRDP_USER}

# Export environment variables definition
env | grep _ >> ~/environment
sudo mv -f ~/environment /etc/environment

# Run systemd.
exec /sbin/init
