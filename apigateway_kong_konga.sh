# configurar kong e konga
cd ~
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
kubectl create ns kong
helm install kong --set service.exposeAdmin=true --set service.type=NodePort --namespace kong bitnami/kong
kubectl get svc -n kong
git clone https://github.com/pantsel/konga.git && cd konga/charts/konga/
helm install konga -f ./values.yaml ../konga --set service.type=NodePort --namespace kong --wait
kubectl get svc konga -n kong
cd ~
export IP=$(curl -s checkip.amazonaws.com)
export PORT=$(kubectl -n kong get service kong -o jsonpath='{.spec.ports[?(@.name=="http-admin")].nodePort}')

# habilitar dashboard : https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

# configurar rota para o dashboard
curl -i -X POST --url http://$IP:$PORT/services/ --data 'name=dash' --data 'url=https://kubernetes-dashboard.kubernetes-dashboard.svc.cluster.local'
