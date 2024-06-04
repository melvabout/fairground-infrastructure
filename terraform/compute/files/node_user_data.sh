#!/bin/bash
# populate /etc/hosts
python3 /root/populate_hosts.py 
# start the etcd cluster
/root/start_node_services.sh