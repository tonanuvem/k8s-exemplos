helm repo add bitnami https://charts.bitnami.com/bitnami
helm install zookeeper bitnami/zookeeper --set replicaCount=3  --set auth.enabled=false --set allowAnonymousLogin=true
printf "\n\n"
echo "    Stateful Sets:"
kubectl get sts
printf "\n\n"
echo "    Pods:"
kubectl get pod
printf "\n\n"
helm install kafka bitnami/kafka --set zookeeper.enabled=false --set replicaCount=3 --set externalZookeeper.servers=zookeeper.default.svc.cluster.local
printf "\n\n"
echo "    Stateful Sets:"
kubectl get sts
printf "\n\n"
echo "    Pods:"
kubectl get pod
printf "\n\n"
echo "    Volumes:"
kubectl get pv
printf "\n\n"
echo "    HELM:"
helm list
printf "\n\n"
echo "    ALL:"
kubectl get all
