curl -L https://istio.io/downloadIstio | sh - 
export PASTA=$(ls | grep istio-)
cd $PASTA && export PATH=$PWD/bin:$PATH
istioctl install -y --set profile=demo
kubectl create -f samples/addons
kubectl label namespace default istio-injection=enabled
sleep 2
kubectl get pod -n istio-system

# Utilizar o objeto Gateway do Ingress para limitar o uso dos IPs publicos
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ingress-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway # use Istio default gateway implementation
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kiali
  namespace: istio-system
spec:
  hosts:
  - "*"
  gateways:
  - ingress-gateway
  http:
  - match:
    - uri:
        prefix: /kiali
    route:
    - destination:
        port:
          number: 20001
        host: kiali.istio-system.svc.cluster.local
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: grafana
  namespace: istio-system
spec:
  hosts:
  - "*"
  gateways:
  - ingress-gateway
  http:
  - match:
    - uri:
        prefix: /grafana
    route:
    - destination:
        port:
          number: 3000
        host: grafana.istio-system.svc.cluster.local
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: prometheus
  namespace: istio-system
spec:
  hosts:
  - "*"
  gateways:
  - ingress-gateway
  http:
  - match:
    - uri:
        prefix: /prometheus
    route:
    - destination:
        port:
          number: 9090
        host: prometheus.istio-system.svc.cluster.local
EOF

#kubectl patch svc kiali -n istio-system -p '{"spec": {"type": "LoadBalancer"}}' && kubectl get svc kiali -n istio-system
#kubectl patch svc prometheus -n istio-system -p '{"spec": {"type": "LoadBalancer"}}' && kubectl get svc prometheus -n istio-system
#kubectl patch svc grafana -n istio-system -p '{"spec": {"type": "LoadBalancer"}}' && kubectl get svc grafana -n istio-system

# Aguardando os IPs Externos
#echo ""
echo "Aguardando os IPs Externos dos serviços (K8S LoadBalancer)"
while [ $(kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }'| wc -m) = '0' ]; do { printf .; sleep 1; } done
export IP=$(kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }')

# Não utilizamos LB
#while [ $(kubectl get service kiali -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }'| wc -m) = '0' ]; do { printf .; sleep 1; } done
#export IP_KIALI=$(kubectl get service kiali -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }')
#echo " IP_externo KIALI OK"
#while [ $(kubectl get service grafana -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }'| wc -m) = '0' ]; do { printf .; sleep 1; } done
#export IP_GRAFANA=$(kubectl get service grafana -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }')
#echo " IP_externo GRAFANA OK"

#echo ""
# Acesso ao Kiali
echo "Acessar Istio Kiali: http://$IP/kiali"
echo ""
# Acesso ao Grafana
echo "Acessar Grafana: http://$IP/grafana"
echo ""
