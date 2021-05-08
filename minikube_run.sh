sudo minikube start --vm-driver=none --kubernetes-version=v1.18.2 --apiserver-ips=$(curl checkip.amazonaws.com)
