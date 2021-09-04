sudo minikube start --vm-driver=none --kubernetes-version=v1.17.11 --apiserver-ips=$(curl checkip.amazonaws.com)
sudo chown -R $USER $HOME/.kube
sudo chown -R $USER $HOME/.minikube
sudo chmod -R u+wrx $HOME/.minikube
minikube addons enable metrics-server
minikube dashboard --url &
kubectl get pod -n kubernetes-dashboard
kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}' && kubectl get svc kubernetes-dashboard -n kubernetes-dashboard
# Dashboard
export INGRESS_HOST=$(curl -s checkip.amazonaws.com)
export INGRESS_PORT=$(kubectl -n kubernetes-dashboard get service kubernetes-dashboard -o jsonpath='{.spec.ports[?()].nodePort}')
echo "Acessar Minikube Dashboard: http://$INGRESS_HOST:$INGRESS_PORT"
echo ""
