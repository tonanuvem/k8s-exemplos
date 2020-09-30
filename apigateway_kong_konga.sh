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
