sudo minikube start --vm-driver=none --kubernetes-version=v1.18.2 --apiserver-ips=$(curl checkip.amazonaws.com)
minikube addons enable metrics-server
minikube dashboard --url &
kubectl get pod -n kubernetes-dashboard
kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}' && kubectl get svc kubernetes-dashboard -n kubernetes-dashboard
