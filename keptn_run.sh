# pre-req : cluster + istio
# minikube addons enable ingress

# instalar cli do keptn
curl -sL https://get.keptn.sh | KEPTN_VERSION=0.8.2 bash
#keptn --help

# instalar Keptn no cluster
keptn install --endpoint-service-type=NodePort --use-case=continuous-delivery
kubectl get deployments -n keptn

# configurar Istio + Keptn
# We have provided some scripts for your convenience.
curl -o configure-istio.sh https://raw.githubusercontent.com/keptn/examples/release-0.8.0/istio-configuration/configure-istio.sh
# After that you need to make the file executable using the chmod command.
chmod +x configure-istio.sh
# Finally, let's run the configuration script to automatically create your Ingress resources.
./configure-istio.sh

# Testar endpoint
API_PORT=$(kubectl get svc api-gateway-nginx -n keptn -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
#EXTERNAL_NODE_IP=$(kubectl get nodes -o jsonpath='{ $.items[0].status.addresses[?(@.type=="ExternalIP")].address }')
EXTERNAL_NODE_IP=$(curl checkip.amazonaws.com)
INTERNAL_NODE_IP=$(kubectl get nodes -o jsonpath='{ $.items[0].status.addresses[?(@.type=="InternalIP")].address }')
KEPTN_ENDPOINT=http://${EXTERNAL_NODE_IP}:${API_PORT}/api
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath='{.data.keptn-api-token}' | base64 --decode)
keptn auth --endpoint=$KEPTN_ENDPOINT --api-token=$KEPTN_API_TOKEN
echo "Acessar o Swagger (Openapi) $KEPTN_ENDPOINT"
