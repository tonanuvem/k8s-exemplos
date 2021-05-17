# https://microcks.io/documentation/installing/kubernetes/
IP=$(curl checkip.amazonaws.com)
helm repo add microcks https://microcks.io/helm
kubectl create namespace microcks
helm install microcks microcks/microcks —-version 1.1.0 --namespace microcks --set microcks.url=microcks.$IP.nip.io --set keycloak.url=keycloak.$IP.nip.io
kubectl patch -n kube-system deployment/ingress-nginx-controller --type='json' -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enable-ssl-passthrough"}]'
