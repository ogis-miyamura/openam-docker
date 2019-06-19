#!/bin/bash

chown -R ${XRDP_USER}. /home/${XRDP_USER}
chown -R ${XRDP_USER}. /opt/

# Run systemd.
exec /sbin/init
