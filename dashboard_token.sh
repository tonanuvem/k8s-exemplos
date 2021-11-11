#!/bin/bash
export COLOR_RESET='\e[0m'
export COLOR_LIGHT_GREEN='\e[0;49;32m' 

export INGRESS_HOST=$(curl -s checkip.amazonaws.com)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}'
kubectl get svc kubernetes-dashboard -n kubernetes-dashboard
export INGRESS_PORT=$(kubectl -n kubernetes-dashboard get service kubernetes-dashboard -o jsonpath='{.spec.ports[?()].nodePort}')
echo ""
echo "Acessar K8S Dashboard: http://$INGRESS_HOST:$INGRESS_PORT"
    
# Kubernetes dashboard access token.

SECRET_RESOURCE=$(kubectl get secrets -n kube-system -o name | grep dash-kubernetes-dashboard-token)
ENCODED_TOKEN=$(kubectl get $SECRET_RESOURCE -n kube-system -o=jsonpath='{.data.token}')
export TOKEN=$(echo $ENCODED_TOKEN | base64 --decode)
echo ""
echo "--- Copy and paste this token for dashboard access ---"
echo -e $COLOR_LIGHT_GREEN
echo -e $TOKEN
echo -e $COLOR_RESET
