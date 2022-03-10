#!/bin/sh

# Verificar esse artigo depois:
# https://alesnosek.com/blog/2017/02/14/accessing-kubernetes-pods-from-outside-of-the-cluster/

# Load Balancer : Metal LB : https://metallb.universe.tf/installation/
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml

# Configura o IP de Load Balancer como sendo o IP do MASTER:
# https://kubernetes.github.io/ingress-nginx/deploy/baremetal/

cat <<EOF | sudo tee configlb.yml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - INSERIR_IP/32
EOF
NODE=$(curl checkip.amazonaws.com)
sed -i 's|INSERIR_IP|'$NODE'|' configlb.yml
kubectl apply -f configlb.yml

# script para colocar Ingress Controller NGINX utilizando Helm :
# https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
# https://kubernetes.github.io/ingress-nginx/deploy/
# Helm Repository

kubectl create ns nginx

# Chart NGINX
#helm repo add nginx-stable https://helm.nginx.com/stable
#helm repo update
#helm install ingress-controller nginx-stable/nginx-ingress --namespace nginx

# Chat Kuberneter
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-controller ingress-nginx/ingress-nginx --version 4.0.18 --namespace nginx

# Caddy : proxy para as portas 80 e 443:
mkdir caddy
cat <<EOF | sudo tee caddy/Caddyfile
:80 {
        # Set this path to your site's directory.
        root * /usr/share/caddy

        # Enable the static file server.
        file_server

        # Another common task is to set up a reverse proxy:
        reverse_proxy localhost:32080

        # Or serve a PHP site through php-fpm:
        # php_fastcgi localhost:9000
}
:443 {
        # Set this path to your site's directory.
        root * /usr/share/caddy

        # Enable the static file server.
        file_server

        # Another common task is to set up a reverse proxy:
        reverse_proxy localhost:32443

        # Or serve a PHP site through php-fpm:
        # php_fastcgi localhost:9000
}
EOF
docker run -d -p 80:80 -p 443:443 -v caddy:/etc/caddy caddy

# Lambda Dynamic DNS CONFIG:
# https://github.com/awslabs/route53-dynamic-dns-with-lambda
