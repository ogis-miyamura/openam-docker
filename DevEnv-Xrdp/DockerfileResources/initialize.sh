#!/bin/bash

chown -R ${XRDP_USER}. /opt/
chown -R ${XRDP_USER}. /home/${XRDP_USER}
chmod 777 /home/${XRDP_USER}

# Run systemd.
exec /sbin/init
