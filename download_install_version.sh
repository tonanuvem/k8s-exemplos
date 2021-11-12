#!/bin/bash

# https://cloud.ibm.com/docs/containers?topic=containers-cs_cli_install

echo "Digite qual uma versão específica (exemplos: 1.17.11 ou 1.20.6)"
read VERSAO

curl -s "https://storage.googleapis.com/kubernetes-release/release/$VERSAO/bin/linux/amd64/kubectl"
curl -s "https://storage.googleapis.com/kubernetes-release/release/$VERSAO/bin/linux/amd64/kubeadm"
curl -s "https://storage.googleapis.com/kubernetes-release/release/$VERSAO/bin/linux/amd64/kubelet"

chmod +x kubectl
chmod +x kubeadm
chmod +x kubelet

sudo mv kubectl /usr/bin
sudo mv kubeadm /usr/bin
sudo mv kubelet /usr/bin
