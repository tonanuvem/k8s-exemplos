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
echo ""
echo "\t\t Digite ENTER para continuar com a CONFIGURAÇÃO de um projeto de testes"
read ENTER

# CRIAR
# Projeto de testes
git clone --branch release-0.8.0 https://github.com/keptn/examples.git --single-branch
cd examples/onboarding-carts
# If you don't want to use a Git upstream, you can create a new project without it but please note that this is not the recommended way:
keptn create project sockshop --shipyard=./shipyard.yaml
#GIT_USER=gitusername
#GIT_TOKEN=gittoken
#GIT_REMOTE_URL=remoteurl
#keptn create project sockshop --shipyard=./shipyard.yaml --git-user=$GIT_USER --git-token=$GIT_TOKEN --git-remote-url=$GIT_REMOTE_URL

# CONFIG
# Onboard first microservice
keptn onboard service carts --project=sockshop --chart=./carts
# Functional tests for dev stage:
keptn add-resource --project=sockshop --stage=dev --service=carts --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
# Performance tests for staging stage:
keptn add-resource --project=sockshop --stage=staging --service=carts --resource=jmeter/load.jmx --resourceUri=jmeter/load.jmx
# Onboard the carts-db service using the keptn onboard service command.
keptn onboard service carts-db --project=sockshop --chart=./carts-db

# Acessar o KEPTN BRIGDE
kubectl patch svc bridge -n keptn -p '{"spec": {"type": "NodePort"}}' && kubectl get svc bridge -n keptn
BRIGDE_PORT=$(kubectl get svc bridge -n keptn -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
KEPTN_ENDPOINT=http://${EXTERNAL_NODE_IP}:${BRIGDE_PORT}/
echo "Acessar o Swagger (Openapi) $KEPTN_ENDPOINT"
echo ""
keptn configure bridge --output
echo ""
echo "\t\t Digite ENTER para continuar com o DEPLOY de um projeto de testes"
read ENTER

# DEPLOY
# Deploy the carts-db service by executing the keptn trigger delivery command:
keptn trigger delivery --project=sockshop --service=carts-db --image=docker.io/mongo --tag=4.2.2 --sequence=delivery-direct
# Deploy the carts service by specifying the built artifact, which is stored on DockerHub and tagged with version 0.12.1:
keptn trigger delivery --project=sockshop --service=carts --image=docker.io/keptnexamples/carts --tag=0.12.1
