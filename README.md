# k8s-slackpage

Download dos arquivos que serão usados para fazer o Deployment no K8S e criar o serviço do tipo NodePort (usaremos no minikube)

> git clone https://github.com/tonanuvem/k8s-slackpage.git

> cd k8s-slackpage

Editar o arquivo deploy_fiap.yml para apontar para a imagem publicada na 1a aula (verificar em http://hub.docker.com)

> DE :    &nbsp;&nbsp;&nbsp;&nbsp;      image: "tonanuvem/fiap_slackpage"

> PARA:   &nbsp;&nbsp;&nbsp;&nbsp;      image: "USUARIO/fiap_slackpage"

Criar o Deployment:

> kubectl create -f deploy_fiap.yml

Criar o Serviço:

> kubectl create -f svc_fiap.yml

Verificar quais recursos foram criados:

> kubectl get all

Abrir a página e testar

> minikube service fiapslackpage



Para verificar o significado dos campos no manifesto dos recursos K8S, pode-se usar o comando : kubectl explain

Exemplos: 

> kubectl explain deployment

> kubectl explain deployment.metadata

> kubectl explain deployment.spec

> kubectl explain deployment.spec.replicas

> kubectl explain deployment.spec.template.spec

> kubectl explain deployment.spec.template.spec.containers

> kubectl explain deployment.spec.template.spec.containers.image
