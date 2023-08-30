# Aguardando o IP Externo
echo ""
echo "Aguardando o IP Externo do Gateway (Ingress)"
while [ $(kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }'| wc -m) = '0' ]; do { printf .; sleep 1; } done
export INGRESS_DOMAIN=$(kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }').nip.io
echo ""
echo "INGRESS_DOMAIN = $INGRESS_DOMAIN"

# Executando projeto: https://github.com/GoogleCloudPlatform/microservices-demo
# mudanças: adicionado namespace 'ecommerce' 

kubectl create namespace ecommerce
kubectl label namespace ecommerce istio-injection=enabled
kubectl apply -f https://raw.githubusercontent.com/tonanuvem/k8s-exemplos/master/google-ecommerce-namespace.yml

# Utilizar o objeto Gateway (Ingress) para limitar o uso dos IPs publicos
# https://istio.io/latest/docs/tasks/observability/gateways/#option-2-insecure-access-http

# 1. Apply the following configuration to expose E-COMMERCE:
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ecommerce-gateway
  namespace: ecommerce
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http-ecommerce
      protocol: HTTP
    hosts:
    - "ecommerce.${INGRESS_DOMAIN}"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ecommerce-vs
  namespace: ecommerce
spec:
  hosts:
  - "ecommerce.${INGRESS_DOMAIN}"
  gateways:
  - ecommerce-gateway
  http:
  - route:
    - destination:
        host: frontend-external
        port:
          number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: ecommerce
  namespace: ecommerce
spec:
  host: frontend-external
  trafficPolicy:
    tls:
      mode: DISABLE
---
EOF


echo ""
echo "Acessar Demo: http://ecommerce.$INGRESS_DOMAIN"
echo ""
echo ""
