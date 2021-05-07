curl -L https://istio.io/downloadIstio | sh - 
cd istio-1.9.4 && export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo
kubectl create -f samples/addons
kubectl label namespace default istio-injection=enabled
kubectl create ns sock-shop
kubectl label namespace sock-shop istio-injection=enabled
sleep 2
kubectl get pod -n istio-system
kubectl patch svc kiali -n istio-system -p '{"spec": {"type": "NodePort"}}' && kubectl get svc kiali -n istio-system
kubectl patch svc prometheus -n istio-system -p '{"spec": {"type": "NodePort"}}' && kubectl get svc prometheus -n istio-system
kubectl patch svc grafana -n istio-system -p '{"spec": {"type": "NodePort"}}' && kubectl get svc grafana -n istio-system
