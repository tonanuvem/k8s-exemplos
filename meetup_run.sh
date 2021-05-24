# Executar K8S (minikube):
sh ~/k8s-exemplos/minikube_run.sh
# Executar Istio:
sh ~/k8s-exemplos/istio_run.sh
# Criar namespace e inserir istio side car:
kubectl create ns sock-shop
kubectl label namespace sock-shop istio-injection=enabled
# Executar a stack:
kubectl create -f microservice-demo-weaveworks-socks.yaml
# Verificar os serviços em execução no namespace sock-shop:
kubectl get svc -n sock-shop
