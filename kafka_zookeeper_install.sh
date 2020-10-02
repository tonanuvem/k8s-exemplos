helm repo add bitnami https://charts.bitnami.com/bitnami
helm install zookeeper bitnami/zookeeper --set replicaCount=3  --set auth.enabled=false --set allowAnonymousLogin=true
kubectl get sts
kubectl get pod
helm list
helm install kafka bitnami/kafka --set zookeeper.enabled=false --set replicaCount=3 --set externalZookeeper.servers=zookeeper.default.svc.cluster.local
kubectl get sts
kubectl get pod
helm list
kubectl get pv
