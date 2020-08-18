# Executar stack sock-shop:

kubectl create -f microservice-demo-weaveworks-socks.yaml
kubectl get svc -n sock-shop

# Executar chat:

kubectl create -f chat.yaml
kubectl get svc -n fiap-chat
