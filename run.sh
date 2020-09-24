# wget https://tonanuvem.github.io/k8s-exemplos/run.sh
# Escolher se quer executar no modo NODEPORT ou LOADBALANCER
echo "Digite 1 ou 2 para escolher se quer executar no modo NODEPORT ou LOADBALANCE:"
echo "1) NODEPORT"  
echo "2) LOADBALANCE"
echo "3) EXEMPLOS COM VOLUME PORTWORX"
echo "4) - DELETAR TUDO"
read MODO
if [[ "$MODO" -eq 1 ]]; then
    echo "NODEPORT:"
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
    echo "LOADBALANCE:"
    # Executar stack modo LOADBALANCE:
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/demo-weaveworks-socks.yaml
    #kubectl create -f https://tonanuvem.github.io/k8s-exemplos/demo-loadbalancer-socks.yaml
    kubectl get svc -n sock-shop
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/chat_deploy_svc.yml
    #kubectl get svc -n fiap-chat
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/deploy_fiap.yml
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/svc_fiap_gcp.yml
    #kubectl get svc -n fiap-service  
    kubectl get svc
elif [[ "$MODO" -eq 3 ]]; then
    echo "EXEMPLOS COM VOLUME PORTWORX: WORDPRESS & CLIENTES"
    # Executar stacks modo VOLUME PORTWOR:
    kubectl create -f https://tonanuvem.github.io/k8s-exemplos/wordpress_mysql.yaml
    kubectl create -f https://tonanuvem.github.io/k8s-clientes-nginx-mongodb/vol_mysql.yaml
    kubectl create -f https://tonanuvem.github.io/k8s-clientes-nginx-mongodb/vol_clientes.yaml
    kubectl get svc
elif [[ "$MODO" -eq 4 ]]; then
    echo "- TENTANDO EXCLUIR TUDO"
    # DELETAR
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/demo-nodeport-socks.yaml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/chat_deploy_svc.yml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/deploy_fiap.yml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/svc_fiap.yml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/demo-weaveworks-socks.yaml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/chat_deploy_svc.yml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/deploy_fiap.yml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/svc_fiap_gcp.yml
    kubectl delete -f https://tonanuvem.github.io/k8s-exemplos/wordpress_mysql.yaml
    kubectl delete -f https://tonanuvem.github.io/k8s-clientes-nginx-mongodb/vol_mysql.yaml
    kubectl delete -f https://tonanuvem.github.io/k8s-clientes-nginx-mongodb/vol_clientes.yaml
else echo "Voce precisa escolher 1 , 2 ou 3."
fi
