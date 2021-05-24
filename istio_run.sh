curl -L https://istio.io/downloadIstio | sh - 
export PASTA=$(ls | grep istio-)
cd $PASTA && export PATH=$PWD/bin:$PATH
istioctl install -y --set profile=demo
kubectl create -f samples/addons
kubectl label namespace default istio-injection=enabled
sleep 2
kubectl get pod -n istio-system
kubectl patch svc kiali -n istio-system -p '{"spec": {"type": "NodePort"}}' && kubectl get svc kiali -n istio-system
kubectl patch svc prometheus -n istio-system -p '{"spec": {"type": "NodePort"}}' && kubectl get svc prometheus -n istio-system
kubectl patch svc grafana -n istio-system -p '{"spec": {"type": "NodePort"}}' && kubectl get svc grafana -n istio-system
# Acesso ao Kiali
export INGRESS_HOST=$(curl -s checkip.amazonaws.com)
export INGRESS_PORT=$(kubectl -n istio-system get service kiali -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
echo "Acessar Istio Kiali: http://$INGRESS_HOST:$INGRESS_PORT"
echo ""
# Acesso ao Grafana
export INGRESS_PORT=$(kubectl -n istio-system get service grafana -o jsonpath='{.spec.ports[?()].nodePort}')
echo "Acessar Grafana: http://$INGRESS_HOST:$INGRESS_PORT"
echo ""
