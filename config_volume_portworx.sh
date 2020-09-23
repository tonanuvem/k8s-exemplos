# Cada Worker possui um disco extra (/dev/xvdb) criado pelo Terraform:

echo "Configuraçoes de disco: "
lsblk
VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
curl -L -s -o px-spec.yaml "https://install.portworx.com/2.6?mc=false&kbver=${VER}&b=true&s=%2Fdev%2Fxvdb&c=px-fiap&stork=true&st=k8s"

# Aguardando cluster:
echo "Verificando se todos os nodes estao com status Ready: "
while [ "$(kubectl get node | grep Ready | wc -l)" != "4" ]; do
  printf "."
  sleep 1
done


# Configurar replicação dos discos utilizando a ferramenta Portworx:
kubectl apply -f px-spec.yaml
sleep 10
kubectl get pods -o wide -n kube-system -l name=portworx

# Aguadar até: Ready 1/1 (Demora uns 4 min) --> Para sair, CTRL + C
echo "Aguardando PORTWORX: GERENCIAMENTO DE VOLUMES (geralmente 4 min): "
while [ "$(kubectl get pods -o wide -n kube-system -l name=portworx | grep 1/1 | wc -l)" != "3" ]; do
  printf "."
  sleep 1
done

echo "Gerenciador de volumes Portworx está executando em todo o cluster."
echo "Verificando status : "
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
