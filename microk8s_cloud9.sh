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

# instalando kubeflow:
microk8s enable kubeflow --bundle lite --password admin
