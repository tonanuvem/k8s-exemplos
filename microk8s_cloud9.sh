# instalando microk8s:
echo "iniciando a instalaçãp, aguardar 5 min..."
sudo snap install microk8s --classic --channel=1.21
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
exec newgrp microk8s
sudo microk8s status --wait-ready
alias kubectl='microk8s kubectl'
microk8s kubectl get nodes

# setando o dominio
export INGRESS_HOST=$(curl checkip.amazonaws.com)
export INGRESS_DOMAIN=${INGRESS_HOST}.nip.io
echo $INGRESS_DOMAIN

# K8S Dashboard
microk8s enable dns ingresss metallb:${INGRESS_HOST}-${INGRESS_HOST}
microk8s enable dashboard
#Get the token for the default user
#token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
#microk8s kubectl -n kube-system describe secret $token
#Port forward  the K8S Dashboard port 443 to port 10443 onto the EC2.
#microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address 0.0.0.0 &

#microk8s enable metallb:$(curl ipinfo.io/ip)-$(curl ipinfo.io/ip)

# instalando kubeflow:
microk8s enable kubeflow --bundle lite --password admin --hostname ${INGRESS_HOST}
