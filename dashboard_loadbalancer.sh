#!/bin/bash
#export COLOR_RESET='\e[0m'
#export COLOR_LIGHT_GREEN='\e[0;49;32m' 

wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml

# Ajustar para acessar de maneira insegura (somente para LAB):
sed -i 's|            - --auto-generate-certificates|            - --auto-generate-certificates\n            - --enable-skip-login\n            - --disable-settings-authorizer\n|' recommended.yaml

kubectl apply -f recommended.yaml

kubectl apply -f https://raw.githubusercontent.com/tonanuvem/k8s-exemplos/master/dashboard_permission.yml

kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc kubernetes-dashboard -n kubernetes-dashboard
echo ""
echo "Aguardando o IP Externo do serviço (K8S LoadBalancer)"
while [ $(kubectl get service kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{ .status.loadBalancer.ingress[].ip }'| wc -m) = '0' ]; do { printf .; sleep 1; } done
export IP=$(kubectl get service kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{ .status.loadBalancer.ingress[].ip }')
echo ""
echo ""
echo "Acessar K8S Dashboard: https://$IP"
echo ""
echo ""
