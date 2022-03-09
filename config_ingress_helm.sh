#!/bin/sh

# script para colocar Ingress Controller NGINX utilizando Helm :
# https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
# https://kubernetes.github.io/ingress-nginx/deploy/

# Helm Repository
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

helm install ingress-controller nginx-stable/nginx-ingress --namespace nginx
