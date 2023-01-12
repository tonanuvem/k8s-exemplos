#!/bin/bash

# Pre-req: ter instalado o istio (https://github.com/tonanuvem/k8s-exemplos/blob/master/istio_run_loadbalancer.sh)

wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml

# Ajustar para acessar de maneira insegura (somente para LAB):
sed -i 's|            - --auto-generate-certificates|            - --auto-generate-certificates\n            - --enable-skip-login\n            - --disable-settings-authorizer\n|' recommended.yaml

kubectl apply -f recommended.yaml

kubectl apply -f https://raw.githubusercontent.com/tonanuvem/k8s-exemplos/master/dashboard_permission.yml

# Aguardando o IP Externo
echo ""
echo "Aguardando o IP Externo do Gateway (Ingress)"
while [ $(kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }'| wc -m) = '0' ]; do { printf .; sleep 1; } done
export INGRESS_DOMAIN=$(kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }').nip.io
echo ""
echo "INGRESS_DOMAIN = $INGRESS_DOMAIN"

# Utilizar o objeto Gateway (Ingress) para limitar o uso dos IPs publicos
# https://istio.io/latest/docs/tasks/observability/gateways/#option-2-insecure-access-http

# 1. Apply the following configuration to expose Grafana:
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: kubernetes-dashboard-gateway
  namespace: kubernetes-dashboard
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https-dashboard
      protocol: HTTPS
    tls:
      mode: SIMPLE
      serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
      privateKey: /etc/istio/ingressgateway-certs/tls.key
    hosts:
    - "dashboard.${INGRESS_DOMAIN}"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kubernetes-dashboard-vs
  namespace: kubernetes-dashboard
spec:
  hosts:
  - "dashboard.${INGRESS_DOMAIN}"
  gateways:
  - kubernetes-dashboard-gateway
  http:
  - route:
    - destination:
        host: kubernetes-dashboard
        port:
          number: 443
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  host: kubernetes-dashboard
  trafficPolicy:
    tls:
      mode: DISABLE
---
EOF


echo ""
echo "Acessar K8S Dashboard: http://dashboard.$INGRESS_DOMAIN"
echo ""
echo ""
