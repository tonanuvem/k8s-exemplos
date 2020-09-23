#!/bin/sh
#wget https://tonanuvem.github.io/k8s-exemplos/config_nodes_drain.sh
croncmd="/home/ubuntu/k8s-exemplos/config_nodes_drain.sh"
cronlog="/home/ubuntu/config_nodes_drain.log"
echo $croncmd
cronjob="*/1 * * * * $croncmd > $cronlog 2>&1"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
crontab -l
