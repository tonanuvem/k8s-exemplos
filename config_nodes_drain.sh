#!/bin/sh
# this script can be run as a cronjob: https://github.com/kubernetes/kubernetes/issues/55713
# outro script: https://github.com/mattmattox/drain-node-on-crash
# erro: https://github.com/kubernetes/kubernetes/issues/55713
# info: https://stackoverflow.com/questions/53641252/kubernetes-recreate-pod-if-node-becomes-offline-timeout/57805955#57805955
# info: https://dev.to/duske/how-kubernetes-handles-offline-nodes-53b5
# info: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#taint-based-evictions

KUBECTL="/usr/local/bin/kubectl"

# Get only nodes which are not drained yet
NOT_READY_NODES=$($KUBECTL get nodes | grep -P 'NotReady(?!,SchedulingDisabled)' | awk '{print $1}' | xargs echo)
# Get only nodes which are still drained
READY_NODES=$($KUBECTL get nodes | grep '\sReady,SchedulingDisabled' | awk '{print $1}' | xargs echo)

echo "Unready nodes that are undrained: $NOT_READY_NODES"
echo "Ready nodes: $READY_NODES"


for node in $NOT_READY_NODES; do
  echo "Node $node not drained yet, draining..."
  $KUBECTL drain --ignore-daemonsets --force $node
  # kubectl delete pod --force --grace-period=0
  echo "Done"
done;

for node in $READY_NODES; do
  echo "Node $node still drained, uncordoning..."
  $KUBECTL uncordon $node
  echo "Done"
done;
