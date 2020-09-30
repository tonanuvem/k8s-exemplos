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
printf "\n\n"
echo "   KONG : CONFIGURANDO ROTAS"
printf "\n\n"
curl -i -X POST --url http://$IP:$PORT/services/ --data 'name=dashboard' --data 'url=https://kubernetes-dashboard.kubernetes-dashboard.svc.cluster.local'
curl -i -X POST --url http://$IP:$PORT/services/dashboard/routes --data 'paths[]=/dashboard'

# criando usuario de exemplo: https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
printf "\n\n"
echo "   DASHBOARD : CONFIGURANDO TOKEN"
printf "\n\n"
# criar Conta
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aluno
  namespace: kubernetes-dashboard
EOF
# criar Permissão
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: aluno
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: aluno
  namespace: kubernetes-dashboard
EOF
printf "\n\n"
echo "   KONG : "
kubectl -n kong get service kong
printf "\n\n"
echo "   KONGA UI : "
kubectl -n kong get service konga
printf "\n\n"
echo "   TOKEN DASHBOARD : "
printf "\n\n"
# verificar Token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep aluno | awk '{print $1}')
