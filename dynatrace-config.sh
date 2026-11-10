#!/bin/bash
# =============================================================================
# Configuração do Dynatrace depois do Auto Discovery (dtwiz)
# =============================================================================
# O Auto Discovery deixa o cluster monitorado, mas para antes de quatro
# coisas. As quatro foram medidas neste laboratório, não deduzidas:
#
#   1. o DynaKube de agentes fica com a imagem PADRÃO do ActiveGate, enquanto
#      este script fixa a imagem só do principal. O coletor OTLP entrega
#      através do ActiveGate do "-agents" -- com as versões desencontradas,
#      ele recusa com 403 em traces e 401 em métricas, citando escopo de
#      token. Não é token: o mesmo token, testado direto contra o tenant,
#      responde 200 nos três endpoints;
#   2. a injeção de code module acontece no webhook, na CRIAÇÃO do pod, e não
#      é retroativa: quem já estava rodando nunca recebe instrumentação;
#   3. o assistente instala applicationMonitoring, não cloudNativeFullStack --
#      sem a camada de host e processo no Smartscape;
#   4. ninguém verifica se o dado CHEGOU. Pod Ready não prova entrega: aqui
#      foram 729 spans descartados com todos os pods saudáveis e nenhuma
#      linha de erro na aplicação.
#
# -----------------------------------------------------------------------------
# Sobre o `set -Eeuo pipefail`
# -----------------------------------------------------------------------------
#   -e           aborta no primeiro comando que falhar
#   -u           aborta ao usar variável não definida
#   -o pipefail  o pipeline falha se QUALQUER etapa falhar, não só a última
#   -E           faz o `trap ... ERR` valer dentro de funções e subshells
#
# Os quatro juntos são boa disciplina, mas `-e` + `pipefail` têm uma armadilha
# neste script: um pipeline como `kubectl get ... | grep ... | head -1` falha
# quando o grep NÃO ACHA nada -- e isso é um resultado legítimo, não um erro.
# Pior: numa atribuição `VAR=$(pipeline)`, o script morre ali, antes do seu
# próprio `if [[ -z "$VAR" ]]` com a mensagem amigável. O `head` fechando o
# pipe cedo também pode gerar SIGPIPE e derrubar tudo.
#
# Por isso, aqui, todo pipeline que pode legitimamente não achar nada termina
# com `|| true`. E o `-E` só ganha utilidade porque existe um trap ERR de
# verdade, logo abaixo -- sem ele, o `-E` não faz nada.
# =============================================================================
set -Eeuo pipefail

trap 'echo "ERRO na linha $LINENO: comando \"$BASH_COMMAND\" (saída $?)" >&2' ERR

NAMESPACE="dynatrace"
TIMEOUT=300
AG_IMAGE="public.ecr.aws/dynatrace/dynatrace-activegate:1.349.80.20261105-202347"

# Namespace da aplicação a reinjetar, e migração opcional para full-stack.
NS_APP="${NS_APP:-fiap-bank}"
FULLSTACK="${FULLSTACK:-false}"

echo "=========================================="
echo " Configuração Dynatrace"
echo " Namespace: $NAMESPACE"
echo "=========================================="

# -----------------------------------------------------------------------------
# 1. Aguarda o Operator ficar Ready
# -----------------------------------------------------------------------------
echo "Aguardando Dynatrace Operator..."

kubectl wait \
  --for=condition=Ready pod \
  -l app.kubernetes.io/name=dynatrace-operator \
  -n "$NAMESPACE" \
  --timeout="${TIMEOUT}s"

# -----------------------------------------------------------------------------
# 2. Identifica os DOIS DynaKube
# -----------------------------------------------------------------------------
# O principal é o que NÃO tem oneAgent (só monitora o cluster); o de agentes é
# o que tem. Descobrimos pela característica, não pelo sufixo do nome, porque
# o assistente já mudou esse sufixo entre versões.
#
# O `|| true` não é zelo excessivo: sem ele, o `grep` que não acha nada mata o
# script antes da mensagem de erro logo abaixo.
DYNAKUBE_NAME=$(kubectl get dynakube -n "$NAMESPACE" \
  -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.oneAgent}{"\n"}{end}' 2>/dev/null \
  | awk 'NF==1 {print $1; exit}' || true)

DK_AGENTES=$(kubectl get dynakube -n "$NAMESPACE" \
  -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.oneAgent}{"\n"}{end}' 2>/dev/null \
  | awk 'NF>1 {print $1; exit}' || true)

if [[ -z "$DYNAKUBE_NAME" ]]; then
    echo "ERRO: Nenhum DynaKube principal encontrado em $NAMESPACE."
    kubectl get dynakube -A || true
    exit 1
fi

echo "DynaKube principal: $DYNAKUBE_NAME"
echo "DynaKube de agentes: ${DK_AGENTES:-<nenhum>}"

AG_STATEFULSET="${DYNAKUBE_NAME}-activegate"

# -----------------------------------------------------------------------------
# 3. Remove o mount do AppArmor, caso exista
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# 4. Ajusta recursos e imagem do ActiveGate principal
# -----------------------------------------------------------------------------
echo "Aplicando ajustes no ActiveGate principal..."

kubectl patch dynakube "$DYNAKUBE_NAME" \
  -n "$NAMESPACE" --type=merge \
  -p="{
    \"spec\": {
      \"activeGate\": {
        \"resources\": {
          \"requests\": { \"memory\": \"1Gi\", \"cpu\": \"50m\" },
          \"limits\":   { \"memory\": \"2Gi\" }
        },
        \"image\": \"$AG_IMAGE\"
      }
    }
  }"

# -----------------------------------------------------------------------------
# 5. Aguarda a criação do StatefulSet
# -----------------------------------------------------------------------------
echo "Aguardando criação do StatefulSet $AG_STATEFULSET..."

START=$SECONDS
until kubectl get statefulset "$AG_STATEFULSET" -n "$NAMESPACE" >/dev/null 2>&1; do
    if (( SECONDS - START >= TIMEOUT )); then
        echo "ERRO: StatefulSet $AG_STATEFULSET não foi criado."
        kubectl get all -n "$NAMESPACE"
        exit 1
    fi
    sleep 5
done

# -----------------------------------------------------------------------------
# 6. Aguarda o ActiveGate principal ficar disponível
# -----------------------------------------------------------------------------
echo "Aguardando ActiveGate ficar Ready..."

kubectl rollout status statefulset/"$AG_STATEFULSET" \
  -n "$NAMESPACE" \
  --timeout="${TIMEOUT}s"

# -----------------------------------------------------------------------------
# 7. A MESMA imagem no ActiveGate do DynaKube de agentes
# -----------------------------------------------------------------------------
# Este é o passo que faltava. O coletor OTLP entrega pelo ActiveGate do
# "-agents" (capability routing). Com ele numa versão mais velha que a do
# principal, a entrega é recusada e os dados são descartados em silêncio --
# com uma mensagem que fala de escopo de token e manda você caçar no lugar
# errado.
if [[ -n "$DK_AGENTES" ]]; then
    IMG_AGENTES=$(kubectl get dynakube "$DK_AGENTES" -n "$NAMESPACE" \
                  -o jsonpath='{.spec.activeGate.image}' 2>/dev/null || true)

    if [[ "$IMG_AGENTES" != "$AG_IMAGE" ]]; then
        echo "Alinhando o ActiveGate de $DK_AGENTES"
        echo "  de:   ${IMG_AGENTES:-<padrão>}"
        echo "  para: $AG_IMAGE"

        kubectl patch dynakube "$DK_AGENTES" -n "$NAMESPACE" --type=merge \
          -p="{\"spec\":{\"activeGate\":{\"image\":\"$AG_IMAGE\"}}}"

        kubectl rollout status "statefulset/${DK_AGENTES}-activegate" \
          -n "$NAMESPACE" --timeout="${TIMEOUT}s" || true

        # O coletor só volta a tentar depois de reiniciar. O que já foi
        # descartado não volta.
        kubectl rollout restart "statefulset/${DK_AGENTES}-otel-collector" \
          -n "$NAMESPACE" >/dev/null 2>&1 || true
        echo "Coletor OTLP reiniciado."
    else
        echo "ActiveGate de $DK_AGENTES já está na imagem fixada."
    fi

    # -------------------------------------------------------------------------
    # 8. Full-stack, se pedido (FULLSTACK=true)
    # -------------------------------------------------------------------------
    if [[ "$FULLSTACK" == "true" ]]; then
        MODO=$(kubectl get dynakube "$DK_AGENTES" -n "$NAMESPACE" \
               -o jsonpath='{.spec.oneAgent}' 2>/dev/null || true)
        if [[ "$MODO" == *applicationMonitoring* ]]; then
            echo "Migrando para cloudNativeFullStack (sobe DaemonSet de OneAgent)..."
            kubectl patch dynakube "$DK_AGENTES" -n "$NAMESPACE" --type=json -p \
              '[{"op":"remove","path":"/spec/oneAgent/applicationMonitoring"},
                {"op":"add","path":"/spec/oneAgent/cloudNativeFullStack","value":{}}]'
        else
            echo "oneAgent já não está em applicationMonitoring."
        fi
    fi
fi

# -----------------------------------------------------------------------------
# 9. Reinjeção nos workloads da aplicação
# -----------------------------------------------------------------------------
# A injeção acontece na CRIAÇÃO do pod. Pod que já rodava quando o DynaKube
# ficou pronto não recebe code module sozinho -- nunca.
if kubectl get ns "$NS_APP" >/dev/null 2>&1; then
    TOTAL=$(kubectl get pods -n "$NS_APP" --no-headers 2>/dev/null | wc -l | tr -d ' ')
    COM=$(kubectl get pods -n "$NS_APP" \
          -o jsonpath='{range .items[*]}{.spec.initContainers[*].name}{"\n"}{end}' 2>/dev/null \
          | grep -c dynatrace || true)

    echo "Injeção em $NS_APP: $COM de $TOTAL pod(s) com code module"
    if [[ "${COM:-0}" -lt "${TOTAL:-0}" ]]; then
        echo "Reiniciando os Deployments de $NS_APP..."
        kubectl rollout restart deploy -n "$NS_APP" || true
    fi
else
    echo "Namespace $NS_APP não existe -- suba a aplicação DEPOIS do agente."
fi

# -----------------------------------------------------------------------------
# 10. O dado está chegando? -- o passo que distingue instalado de funcionando
# -----------------------------------------------------------------------------
COLETOR=$(kubectl get statefulset -n "$NAMESPACE" -o name 2>/dev/null \
          | grep otel-collector | head -1 || true)

if [[ -z "$COLETOR" ]]; then
    echo "Sem coletor OTLP (telemetryIngest desligado)."
else
    echo "Conferindo a entrega em $COLETOR (últimos 5 min)..."
    DESCARTES=$(kubectl logs "$COLETOR" -n "$NAMESPACE" --since=5m 2>/dev/null \
                | grep "Dropping data" | tail -2 || true)

    if [[ -z "$DESCARTES" ]]; then
        echo "  OK: nenhum descarte. O dado está chegando ao Dynatrace."
    else
        echo "  ATENÇÃO: o coletor está DESCARTANDO dado."
        echo "$DESCARTES" \
          | sed 's/.*"otelcol.signal": "\([a-z]*\)".*"error": "\([^"]*\)".*"dropped_items": \([0-9]*\).*/    \1: \3 descartados -- \2/' \
          | cut -c1-180
        echo
        echo "  Antes de culpar o token: teste o MESMO token direto contra o"
        echo "  tenant. Se responder 200, o token está bom e o problema está"
        echo "  no caminho (versão do ActiveGate, rede, TLS):"
        echo "    AMB=\$(kubectl get dynakube $DK_AGENTES -n $NAMESPACE -o jsonpath='{.spec.apiUrl}' | sed 's#/api\$##')"
        echo "    curl -s -o /dev/null -w '%{http_code}\\n' -X POST \$AMB/api/v2/otlp/v1/traces \\"
        echo "      -H \"Authorization: Api-Token \$TOKEN\" --data-binary ''"
    fi
fi

echo "=========================================="
echo " Dynatrace configurado"
echo "=========================================="

kubectl get dynakube -n "$NAMESPACE"
kubectl get pods -n "$NAMESPACE"
