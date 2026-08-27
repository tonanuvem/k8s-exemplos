#!/bin/sh

echo ""
echo "========================================"
echo "        INSTALANDO ISTIO"
echo "========================================"
echo ""

curl -L https://istio.io/downloadIstio | sh -

cd istio-*

export PATH=$PWD/bin:$PATH

echo ""
echo "Instalando Istio com profile demo..."
echo ""

istioctl install --set profile=demo --skip-confirmation

echo ""
echo "========================================"
echo "        CONFIGURANDO ISTIO"
echo "========================================"
echo ""

kubectl create -f samples/addons

kubectl label namespace default istio-injection=enabled --overwrite

kubectl patch svc kiali -n istio-system \
  -p '{"spec":{"type":"NodePort"}}'

echo ""
echo "Serviço Kiali:"
kubectl get svc kiali -n istio-system

echo ""
echo "Porta do Kiali:"
kubectl get svc kiali -n istio-system | grep 20001 || true

echo ""
echo "========================================"
echo "        ACESSO AO KIALI"
echo "========================================"
echo ""

KIALI_PORT=$(kubectl get svc kiali -n istio-system \
  -o jsonpath='{.spec.ports[?(@.port==20001)].nodePort}')

echo ""
echo "Acessar Kiali:"
echo "  PORTA : $KIALI_PORT"
echo ""

echo "========================================"
echo "   CONFIGURAÇÕES REALIZADAS. FIM."
echo "========================================"
echo ""

printf "\n\n"
