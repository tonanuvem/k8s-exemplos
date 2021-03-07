#!/bin/bash

if [ -z "$BASH_VERSION" ]
then
    exec bash "$0" "$@"
fi

# wget https://tonanuvem.github.io/k8s-exemplos/run.sh

# Escolher se quer executar no modo NODEPORT ou LOADBALANCER
echo "Digite 1 ou 2 para escolher se quer executar no modo NODEPORT ou LOADBALANCE:"
echo "1) NODEPORT"  
echo "2) LOADBALANCE"
echo "3) VOLUME PORTWORX: WORDPRESS & CLIENTES"
echo "4) API GATEWAY: KONG & KONGA"
echo "5) KAFKA: PRODUCER & CONSUMER"
echo "6) ELASTIC STACK: ELASTICSEARCH, KIBANA, APM & APP_CLIENT_APM_NODEJS"
echo "7) - DELETAR TUDO"
read MODO
if [[ "$MODO" -eq 1 ]]; then
    echo "   NODEPORT:"
    # Executar stack modo NODEPORT:
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/demo-nodeport-socks.yaml
    kubectl get svc -n sock-shop
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/chat_deploy_svc.yml
    #kubectl get svc -n fiap-chat
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/deploy_fiap.yml
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/svc_fiap.yml
    #kubectl get svc -n fiap-service  
    kubectl get svc
elif [[ "$MODO" -eq 2 ]]; then
    echo "   LOADBALANCE:"
    # Executar stack modo LOADBALANCE:
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/demo-weaveworks-socks.yaml
    #kubectl create -f https://tonanuvem.github.io/k8s-exemplos/demo-loadbalancer-socks.yaml
    kubectl get svc -n sock-shop
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/chat_deploy_svc_loadbalancer.yml
    #kubectl get svc -n fiap-chat
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/deploy_fiap.yml
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/svc_fiap_gcp.yml
    #kubectl get svc -n fiap-service  
    kubectl get svc
elif [[ "$MODO" -eq 3 ]]; then
    echo "   EXEMPLOS COM VOLUME PORTWORX: WORDPRESS & CLIENTES"
    # Executar stacks modo VOLUME PORTWOR:
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/wordpress_mysql.yaml
    kubectl create -f https://tonanuvem.github.io/k8s-clientes-nginx-mongodb/vol_mongo.yaml
    kubectl create -f https://tonanuvem.github.io/k8s-clientes-nginx-mongodb/vol_clientes.yaml
    kubectl get svc
elif [[ "$MODO" -eq 4 ]]; then
    echo "   API GATEWAY: KONG & KONGA"
    sh apigateway_kong_konga.sh
    kubectl get svc
elif [[ "$MODO" -eq 5 ]]; then
    echo "   KAFKA: PRODUCER & CONSUMER"
    sh kafka_helm_install.sh
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/kafka_producer_consumer_deploy.yaml 
    kubectl get svc
elif [[ "$MODO" -eq 5 ]]; then
    echo "   KAFKA: PRODUCER & CONSUMER"
    sh kafka_helm_install.sh
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/kafka_producer_consumer_deploy.yaml 
    kubectl get svc
elif [[ "$MODO" -eq 6 ]]; then
    echo "   ELASTIC STACK: ELASTICSEARCH, KIBANA, APM & APP_CLIENT_APM_NODEJS"
    sh elastic_stack.sh
    kubectl get svc    
elif [[ "$MODO" -eq 7 ]]; then
    echo "- TENTANDO EXCLUIR TUDO"
    # DELETAR 1 e 2
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/demo-nodeport-socks.yaml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/chat_deploy_svc.yml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/deploy_fiap.yml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/svc_fiap.yml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/demo-weaveworks-socks.yaml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/chat_deploy_svc.yml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/deploy_fiap.yml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/svc_fiap_gcp.yml
    # DELETAR 3
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/wordpress_mysql.yaml
    kubectl delete -f https://tonanuvem.github.io/k8s-clientes-nginx-mongodb/vol_mongo.yaml
    kubectl delete -f https://tonanuvem.github.io/k8s-clientes-nginx-mongodb/vol_clientes.yaml
    # DELETAR 4
    helm delete kong
    helm delete konga
    kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
    kubectl delete sa aluno
    kubectl delete clusterrolebindings aluno
    # DELETE 5
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/kafka_producer_consumer_deploy.yaml 
    helm delete kafka
    helm delete zookeeper
    # DELETE 6
    kubectl delete svc appclientapmnodejs-service
    kubectl delete deploy appclientapmnodejs
    # deletar apm
    # deletar kibana
    # deletar elasticsearch
else echo "Voce precisa escolher 1 , 2 , 3, 4, 5, 6 ou 7."
fi
echo ""
kubectl get pod -o wide -n sock-shop
echo ""
kubectl get pod -o wide
