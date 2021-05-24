# Executar K8S (minikube):
sh ~/k8s-exemplos/minikube_run.sh
# Executar Istio:
sh ~/k8s-exemplos/istio_run.sh
# Criar namespace e inserir istio side car:
kubectl create ns sock-shop
kubectl label namespace sock-shop istio-injection=enabled
# Executar a stack:
kubectl create -f ~/k8s-exemplos/microservice-demo-weaveworks-socks.yaml
# Verificar os serviços em execução no namespace sock-shop:
kubectl get svc -n sock-shop
# Front end Sock Shop:
export INGRESS_HOST=$(curl -s checkip.amazonaws.com)
export INGRESS_PORT=$(kubectl -n sock-shop get service front-end -o jsonpath='{.spec.ports[?()].nodePort}')
echo "Acessar e-Commerce Front-end: http://$INGRESS_HOST:$INGRESS_PORT"
