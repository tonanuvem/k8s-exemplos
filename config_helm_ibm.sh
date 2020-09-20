# Adicionando um Repositório (ex: IBM)

helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/

helm repo update

# Instalando o Chart:

helm install -f ibm-nodejs-values.yaml ibm-charts/ibm-nodejs-express --version 1.0.0 --name-template ibm

helm list
