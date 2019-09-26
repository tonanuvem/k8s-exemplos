# k8s-slackpage

Download dos arquivos que serão usados para fazer o Deployment no K8S e criar o serviço do tipo NodePort (usaremos no minikube)

> https://github.com/tonanuvem/k8s-slackpage.git

> cd k8s-slackpage

Editar o arquivo deploy_fiap.yml para apontar para a imagem publicada na 1a aula (verificar em http://hub.docker.com)

> DE :          image: "tonanuvem/fiap_slackpage"

> PARA:         image: "USUARIO/fiap_slackpage"

Criar o Deployment:

> kubectl create -f deploy_fiap.yml

Criar o Serviço:

> kubectl create -f svc_fiap.yml

Verificar quais recursos foram criados:

> kubectl get all

Abrir a página e testar

> minikube service
