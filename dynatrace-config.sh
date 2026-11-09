#!/bin/bash
set -Eeuo pipefail

NAMESPACE="dynatrace"
DYNAKUBE_NAME="${DYNAKUBE_NAME:-kubernetes}"
TIMEOUT=300

AG_IMAGE="public.ecr.aws/dynatrace/dynatrace-activegate:1.349.80.20261105-202347"
AG_STATEFULSET="${DYNAKUBE_NAME}-activegate"

echo "=========================================="
echo " Configuração Dynatrace"
echo " DynaKube: $DYNAKUBE_NAME"
echo " Namespace: $NAMESPACE"
echo "=========================================="

# 1. Aguarda o Operator ficar Ready
echo "Aguardando Dynatrace Operator..."

kubectl wait \
  --for=condition=Ready pod \
  -l app.kubernetes.io/name=dynatrace-operator \
  -n "$NAMESPACE" \
  --timeout="${TIMEOUT}s"

# 2. Aguarda a criação do DynaKube
echo "Aguardando criação do DynaKube $DYNAKUBE_NAME..."

START=$SECONDS

until kubectl get dynakube "$DYNAKUBE_NAME" -n "$NAMESPACE" >/dev/null 2>&1; do
    if (( SECONDS - START >= TIMEOUT )); then
        echo "ERRO: DynaKube $DYNAKUBE_NAME não foi criado após ${TIMEOUT}s."
        echo "DynaKubes disponíveis:"
        kubectl get dynakube -A || true
        exit 1
    fi

    sleep 5
done

echo "DynaKube encontrado!"

# 3. Remove o mount do AppArmor, caso exista
echo "Verificando configuração AppArmor..."

APPARMOR_INDEX=$(kubectl get dynakube "$DYNAKUBE_NAME" \
  -n "$NAMESPACE" -o json |
  jq -r '.spec.kspm.mappedHostPaths // [] | index("/sys/kernel/security/apparmor")')

if [[ "$APPARMOR_INDEX" != "null" ]]; then
    echo "Removendo AppArmor no índice $APPARMOR_INDEX..."

    kubectl patch dynakube "$DYNAKUBE_NAME" \
      -n "$NAMESPACE" --type=json \
      -p="[{\"op\":\"remove\",\"path\":\"/spec/kspm/mappedHostPaths/$APPARMOR_INDEX\"}]"
else
    echo "AppArmor não encontrado. Nenhuma alteração necessária."
fi

# 4. Ajusta recursos e imagem do ActiveGate
echo "Aplicando ajustes no ActiveGate..."

kubectl patch dynakube "$DYNAKUBE_NAME" \
  -n "$NAMESPACE" --type=merge \
  -p="{
    \"spec\": {
      \"activeGate\": {
        \"resources\": {
          \"requests\": {
            \"memory\": \"1Gi\",
            \"cpu\": \"50m\"
          },
          \"limits\": {
            \"memory\": \"2Gi\"
          }
        },
        \"image\": \"$AG_IMAGE\"
      }
    }
  }"

# 5. Aguarda a criação do StatefulSet
echo "Aguardando criação do StatefulSet $AG_STATEFULSET..."

START=$SECONDS

until kubectl get statefulset "$AG_STATEFULSET" \
    -n "$NAMESPACE" >/dev/null 2>&1; do

    if (( SECONDS - START >= TIMEOUT )); then
        echo "ERRO: StatefulSet $AG_STATEFULSET não foi criado."
        kubectl get all -n "$NAMESPACE"
        exit 1
    fi

    sleep 5
done

# 6. Aguarda o ActiveGate ficar disponível
echo "Aguardando ActiveGate ficar Ready..."

kubectl rollout status statefulset/"$AG_STATEFULSET" \
  -n "$NAMESPACE" \
  --timeout="${TIMEOUT}s"

echo "=========================================="
echo " Dynatrace configurado com sucesso!"
echo "=========================================="

kubectl get dynakube "$DYNAKUBE_NAME" -n "$NAMESPACE"
kubectl get pods -n "$NAMESPACE"
