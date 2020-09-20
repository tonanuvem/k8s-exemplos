# Inicializar o Master utilizando o KUBEADM:

kubeadm version

sudo kubeadm config images pull

sudo kubeadm init

#	Configurar o cliente kubectl:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
#source <(kubectl completion bash)

# Configurar a rede:

sh ~/k8s-exemplos/config_network_weave.sh
