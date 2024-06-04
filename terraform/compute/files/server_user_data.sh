#!/bin/bash
# populate /etc/hosts
python3 /root/populate_hosts.py 
# start the kubernetes control plane
/root/start_control_plane_services.sh
