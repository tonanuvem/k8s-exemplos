#!/bin/bash
echo "Aguardando criação do DynaKube..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=dynatrace-operator -n dynatrace --timeout=120s

# 1. Remove o mount do AppArmor caso exista no array do KSPM (evita depender do índice 4 fixo)
APPARMOR_INDEX=$(kubectl get dynakube kubernetes -n dynatrace -o json | jq '.spec.kspm.mappedHostPaths | index("/sys/kernel/security/apparmor")')

if [ "$APPARMOR_INDEX" != "null" ] && [ -n "$APPARMOR_INDEX" ]; then
  echo "Removendo /sys/kernel/security/apparmor no índice $APPARMOR_INDEX..."
  kubectl patch dynakube kubernetes -n dynatrace --type=json \
    -p="[{\"op\":\"remove\",\"path\":\"/spec/kspm/mappedHostPaths/$APPARMOR_INDEX\"}]"
fi

# 2. Reduzir o request de memória do ActiveGate do DynaKube
kubectl patch dynakube kubernetes -n dynatrace --type=json \
  -p='[{"op":"replace","path":"/spec/activeGate/resources/requests/memory","value":"1Gi"},
       {"op":"replace","path":"/spec/activeGate/resources/limits/memory","value":"2Gi"}]'

# 3. Atualiza a imagem do ActiveGate para a versão homologada no ECR Public
AG_IMAGE="public.ecr.aws/dynatrace/dynatrace-activegate:1.349.80.20261105-202347"
kubectl patch dynakube kubernetes -n dynatrace --type=json \
  -p="[{\"op\":\"replace\",\"path\":\"/spec/activeGate/image\",\"value\":\"$AG_IMAGE\"}]"

echo "Aguardando pods ficarem Running..."
kubectl rollout status statefulset/kubernetes-activegate -n dynatrace
