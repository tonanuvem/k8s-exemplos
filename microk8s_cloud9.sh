# instalando microk8s:
sudo snap install microk8s --classic --channel=1.21
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
newgrp microk8s
microk8s status --wait-ready
alias kubectl='microk8s kubectl'
microk8s kubectl get nodes

# configurando addons:
microk8s enable dns storage dashboard

# K8S Dashboard
#Get the token for the default user
token=$(kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
kubectl -n kube-system describe secret $token
#Port forward  the K8S Dashboard port 443 to port 10443 onto the EC2.
microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address 0.0.0.0

# instalando kubeflow:
microk8s enable kubeflow --bundle lite --password admin
