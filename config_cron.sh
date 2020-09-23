#!/bin/sh

# script para colocar o node que falhou/retornou como CORDON / UNCORDON
cat >> /home/ubuntu/config_nodes_drain.sh << EOL
KUBECTL="kubectl"
NOT_READY_NODES=$($KUBECTL get nodes | grep -P 'NotReady(?!,SchedulingDisabled)' | awk '{print $1}' | xargs echo)
READY_NODES=$($KUBECTL get nodes | grep '\sReady,SchedulingDisabled' | awk '{print $1}' | xargs echo)
echo "Unready nodes that are undrained: $NOT_READY_NODES"
echo "Ready nodes: $READY_NODES"
for node in $NOT_READY_NODES; do
  echo "Node $node not drained yet, draining..."
  $KUBECTL drain --ignore-daemonsets --force $node
  echo "Done"
done;
for node in $READY_NODES; do
  echo "Node $node still drained, uncordoning..."
  $KUBECTL uncordon $node
  echo "Done"
done;
EOL

# cron no MASTER
#wget https://tonanuvem.github.io/k8s-exemplos/config_nodes_drain.sh
croncmd="/home/ubuntu/config_nodes_drain.sh"
cronlog="/home/ubuntu/config_nodes_drain.log"
echo $croncmd
chmod +x $croncmd
cronjob="*/1 * * * * $croncmd > $cronlog 2>&1"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
crontab -l
