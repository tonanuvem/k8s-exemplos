# conectar no master e configurar

# ~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") ) { print } }'

MASTER=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_0/) ) { print $1} }')
NODE1=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_1/) ) { print $1} }')
NODE2=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_2/) ) { print $1} }')
NODE3=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_3/) ) { print $1} }')
echo "IPs configurados :"
echo "MASTER = $MASTER"
echo "NODE1 = $NODE1"
echo "NODE2 = $NODE2"
echo "NODE3 = $NODE3"
#MASTER=$(~/environment/ip | awk -Fv '/vm_0/{print $1}')
#NODE1=$(~/environment/ip | awk -Fv '/vm_1/{print $1}')
#NODE2=$(~/environment/ip | awk -Fv '/vm_2/{print $1}')
#NODE3=$(~/environment/ip | awk -Fv '/vm_3/{print $1}')

# reset arquivos vazios dos scripts:
> master.sh
> worker1.sh
> worker2.sh
> worker3.sh

# CONFIGURANDO O MASTER utilizando o KUBEADM INIT:
#echo "sudo hostnamectl set-hostname master" >> master.sh
echo "Aguardando instalação do KUBEADM."
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$MASTER "sudo hostnamectl set-hostname master"
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$MASTER "while [ \$(dpkg -l | grep kubeadm | wc -l) != '1' ]; do { printf .; sleep 1; } done"
#echo "while [ \$(dpkg -l | grep kubeadm | wc -l) != '1' ]; do { printf .; sleep 1; } done" >> master.sh
echo "kubeadm version" >> master.sh
echo "sudo kubeadm config images pull" >> master.sh
echo "sudo kubeadm init" >> master.sh
#	Configurar o cliente kubectl:
echo "mkdir -p $HOME/.kube" >> master.sh
echo "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config" >> master.sh
echo "sudo chown $(id -u):$(id -g) $HOME/.kube/config" >> master.sh
#echo "source <(kubectl completion bash)" >> master.sh

# validar
#cat master.sh

### CONFIGURANDO O MASTER via SSH
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$MASTER 'bash -s' < master.sh
# Get Token
TOKEN=$(ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$MASTER 'sudo kubeadm token create --print-join-command')
printf "\n\n"
echo $TOKEN
printf "\n\n"
echo "   TOKEN ACIMA : KUBEADM JOIN"
printf "\n\n"
echo "Master do Cluster foi inicializado. Agora vamos configurar a rede do cluster."
# Configurar a rede do cluster:
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$MASTER 'bash -s' < config_network_weave.sh

### CONFIGURANDO OS NODES utilizando o KUBEADM JOIN:

# Exemplo:
# kubeadm join 10.0.1.169:6443 --token fdwf9o.om0jvrom7uv3eeg4 \
#    --discovery-token-ca-cert-hash sha256:46abcfc7e371878b78f1071a7e396a3b1f1e851cbec76e65f0030d3f73411fd1
printf "\n\n"
echo "CONFIGURANDO OS NODES utilizando o KUBEADM JOIN:"
#echo "Copie e cole 2 linhas com KUBEADM JOIN exibido acima: (digite ENTER PARA CONCLUIR)"
#echo "Exemplo das 2 linhas a serem copiadas:"
#echo " kubeadm join 10.0.1.169:6443 --token fdwf9o.om0jvrom7uv3eeg4 "
#echo "    --discovery-token-ca-cert-hash sha256:46abcfc7e371878b78f1071a7e396a3b1f1e851cbec76e65f0030d3f73411fd1"
#read TOKEN
#read ENTER

echo "sudo hostnamectl set-hostname worker1" >> worker1.sh
echo "sudo hostnamectl set-hostname worker2" >> worker2.sh
echo "sudo hostnamectl set-hostname worker3" >> worker3.sh

echo "sudo $TOKEN" >> worker1.sh
echo "sudo $TOKEN" >> worker2.sh
echo "sudo $TOKEN" >> worker3.sh

# validar
#cat worker1.sh
printf "\n\n"
echo "   CONFIGURANDO NODE 1: KUBEADM JOIN"
printf "\n\n"
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$NODE1 'bash -s' < worker1.sh
printf "\n\n"
echo "   CONFIGURANDO NODE 2: KUBEADM JOIN"
printf "\n\n"
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$NODE2 'bash -s' < worker2.sh
printf "\n\n"
echo "   CONFIGURANDO NODE 3: KUBEADM JOIN"
printf "\n\n"
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$NODE3 'bash -s' < worker3.sh
printf "\n\n"
echo "   VERIFICANDO NODES NO MASTER :"
printf "\n\n"
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$MASTER 'kubectl get nodes'

### CONFIGURANDO OS VOLUMES 
printf "\n\n"
echo "   CONFIGURANDO OS VOLUMES: PORTWORX"
printf "\n\n"
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$MASTER 'bash -s' < config_volume_portworx.sh
# Cron para detectar rapidamente falha nos nodes
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$MASTER 'bash -s' < config_cron.sh
# configurar um Storage Class default no cluster
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$MASTER 'kubectl create -f https://tonanuvem.github.io/k8s-exemplos/storageclass_default_portworx.yaml'

printf "\n\n"
echo "   CONFIGURAÇÕES REALIZADAS. FIM."
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$MASTER 'kubectl get nodes'
printf "\n\n"
