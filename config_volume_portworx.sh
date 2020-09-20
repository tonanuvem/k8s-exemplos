# Cada Worker possui um disco extra (/dev/xvdb) criado pelo Terraform:

lsblk

VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')

curl -L -s -o px-spec.yaml "https://install.portworx.com/2.6?mc=false&kbver=${VER}&b=true&s=%2Fdev%2Fxvdb&c=px-fiap&stork=true&st=k8s"

# Configurar replicação dos discos utilizando a ferramenta Portworx:

kubectl apply -f px-spec.yaml
