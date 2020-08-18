# Escolher se quer executar no modo NODEPORT ou LOADBALANCER
echo "Digite 1 ou 2 para escolher se quer executar no modo NODEPORT ou LOADBALANCE:"
echo "1) NODEPORT"  
echo "2) LOADBALANCE"
read MODO
if [[ "$MODO" -eq 1 ]]; then
    echo "NODEPORT:"
    # Executar stack modo NODEPORT:
    kubectl create -f microservice-demo-weaveworks-socks.yaml
    kubectl get svc -n sock-shop
    kubectl create -f chat_deploy_svc.yml
    kubectl get svc -n fiap-chat
    kubectl create -f deploy_fiap.yml
    kubectl create -f svc_fiap.yml
    kubectl get svc -n fiap-service  
elif [[ "$MODO" -eq 2 ]]; then
    echo "LOADBALANCE:"
    # Executar stack modo LOADBALANCE:
    kubectl create -f microservice-demo-weaveworks-socks.yaml
    kubectl get svc -n sock-shop
    kubectl create -f chat_deploy_svc.yml
    kubectl get svc -n fiap-chat
    kubectl create -f deploy_fiap.yml
    kubectl create -f svc_fiap_gcp.yml
    kubectl get svc -n fiap-service      
else echo "Voce precisa escolher 1 ou 2."
fi
