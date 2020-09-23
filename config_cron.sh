#!/bin/sh
#wget https://tonanuvem.github.io/k8s-exemplos/config_nodes_drain.sh
croncmd="/home/ubuntu/k8s-exemplos/config_nodes_drain.sh"
echo $croncmd
cronjob="*/1 * * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
crontab -l
