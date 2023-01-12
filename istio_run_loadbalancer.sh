curl -L https://istio.io/downloadIstio | sh - 
export PASTA=$(ls | grep istio-)
cd $PASTA && export PATH=$PWD/bin:$PATH
istioctl install -y --set profile=demo
kubectl create -f samples/addons
kubectl label namespace default istio-injection=enabled
sleep 2
kubectl get pod -n istio-system
kubectl patch svc kiali -n istio-system -p '{"spec": {"type": "LoadBalancer"}}' && kubectl get svc kiali -n istio-system
kubectl patch svc prometheus -n istio-system -p '{"spec": {"type": "LoadBalancer"}}' && kubectl get svc prometheus -n istio-system
kubectl patch svc grafana -n istio-system -p '{"spec": {"type": "LoadBalancer"}}' && kubectl get svc grafana -n istio-system
# Aguardando os IPs Externos
echo ""
echo "Aguardando os IPs Externos dos serviços (K8S LoadBalancer)"
while [ $(kubectl get service kkiali -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }'| wc -m) = '0' ]; do { printf .; sleep 1; } done
export IP_KIALI=$(kubectl get service kiali -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }')
echo " IP_externo KIALI OK"
while [ $(kubectl get service grafana -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }'| wc -m) = '0' ]; do { printf .; sleep 1; } done
export IP_GRAFANA=$(kubectl get service grafana -n istio-system -o jsonpath='{ .status.loadBalancer.ingress[].ip }')
echo " IP_externo GRAFANA OK"
# Acesso ao Kiali
echo "Acessar Istio Kiali: http://$IP_KIALI"
echo ""
# Acesso ao Grafana
echo "Acessar Grafana: http://$IP_GRAFANA"
echo ""
