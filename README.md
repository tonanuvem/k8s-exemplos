# k8s (exemplos)

<li> <b>PARTE 1:</b>

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


<hr>

<li> <b>PARTE 2:</b>

Realizando um deploy (Rolling Update) on the fly...

Editar o Deploy:
  
> kubectl edit deployment fiapslackpage

Usar a imagem publicada pelo Vizinho

> DE :    &nbsp;&nbsp;&nbsp;&nbsp;      image: "tonanuvem/fiap_slackpage"

> PARA:   &nbsp;&nbsp;&nbsp;&nbsp;      image: "USUARIO_VIZINHO/fiap_slackpage"

Verificar a nova versão do Deployment que foi gerada, possibilitando um fácil rollback:

> kubectl rollout history deployment/fiapslackpage

Realizar o rollback:

> kubectl rollout undo deployment/fiapslackpage

Verificar novamente o histórico:

> kubectl rollout history deployment/fiapslackpage
<hr>

Link Exemplo StatefulSet : https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/

<li> <b>PARTE 3:</b>

Exemplo: Sock Shop : A Microservice Demo Application
<br><br>
Link: https://github.com/microservices-demo/microservices-demo

Executar a stack:
  
> kubectl create -f microservice-demo-weaveworks-socks.yaml

Verificar os serviços em execução no namespace sock-shop:

> kubectl get svc -n sock-shop

Verificar todos os objetos do namespace sock-shop

> kubectl get all -n sock-shop

Opção 2: Rodando com istio-inject

> kubectl create ns sock-shop
<br>
> kubectl label namespace sock-shop istio-injection=enabled --overwrite
<br>
> kubectl get namespace -L istio-injection
<br>
> kubectl apply -f https://tonanuvem.github.io/k8s-exemplos/demo-weaveworks-socks.yaml

<hr>

<li> <b>PARTE 4:</b>

Exemplo: Chat Websocket
<br><br>

> kubectl create -f https://tonanuvem.github.io/k8s-exemplos/chat_deploy_svc.yml

Exemplo: Wordpress com BD Mysql
<br><br>


> kubectl create -f https://tonanuvem.github.io/k8s-exemplos/wordpress_mysql.yaml

<hr>

<li> <b>PARTE 5:</b>

RUN ALL:
<br><br>


> wget https://tonanuvem.github.io/k8s-exemplos/run.sh

> chmod +x run.sh; ./run.sh

RUN via comandos:

> kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4

> kubectl expose deployment hello-node --type=NodePort --port=8080

> kubectl scale deploy hello-node --replicas=2

<hr>

<i>DEBUG:</i>

> kubectl run debug --image=k8s.gcr.io/busybox -it --rm --restart=Never -- sh

> ping NOME_SERVICO

> kubectl exec -ti NOME_POD_APP -- bash

> curl localhost:PORTA

<hr>

<i>EXTRA:</i>

Para verificar o significado dos campos no manifesto dos recursos K8S, pode-se usar o comando : kubectl explain

Exemplos: 

> kubectl explain deployment

> kubectl explain deployment.metadata

> kubectl explain deployment.spec

> kubectl explain deployment.spec.replicas

> kubectl explain deployment.spec.template.spec

> kubectl explain deployment.spec.template.spec.containers

> kubectl explain deployment.spec.template.spec.containers.image
