# instalar interface gráfica e VNC server no Ubuntu
# https://o7planning.org/11307/install-gui-and-vnc-for-ubuntu-server
# https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-ubuntu-18-04-pt

sudo apt-get update
sudo apt-get -y install xfce4 xfce4-goodies tightvncserver xfonts-base

# https://chaos-mesh.org/interactive-tutorial

# https://www.katacoda.com/kuber-ru/courses/kubernetes-chaos/kubeinvaders
# instalar kubeinvaders
# https://github.com/lucky-sideburn/KubeInvaders

helm repo add kubeinvaders https://lucky-sideburn.github.io/helm-charts/
kubectl create namespace kubeinvaders
helm install kubeinvaders --set-string target_namespace="namespace1\,namespace2" \
-n kubeinvaders kubeinvaders/kubeinvaders --set ingress.hostName=kubeinvaders.io --set image.tag=v1.7

# Kata: 
# Install KubeInvaders
# Create a namespace for the game application.
kubectl create namespace kubeinvaders
# Grab the source code that contains the Helm chart.
git clone https://github.com/lucky-sideburn/KubeInvaders && cd KubeInvaders
# Install the game using the Helm chart.
helm install kubeinvaders ./helm-charts/kubeinvaders \
--version 0.1.1 \
--namespace kubeinvaders \
--set service.type=NodePort \
--set ingress.enabled=false \
--set target_namespace="default\,more-apps" \
--set route_host=2886795298-30016-jago01.environments.katacoda.com
# Set NodePort value
kubectl patch service kubeinvaders -n kubeinvaders --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30016}]'

# First, add a few simple NGINX Pods to the default namespace.
kubectl create deployment nginx --image=nginx
kubectl scale deployment/nginx --replicas=
# Next, add a few more Pods (aliens) to a second namespace.
kubectl create namespace more-apps
kubectl create deployment ghost --namespace more-apps --image=ghost:3.11.0-alpine
kubectl scale deployment/ghost --namespace more-apps --replicas=4
# Label the Deployments and Pods so you can watch their status.
kubectl label deployment,pod app-purpose=chaos -l app=nginx --namespace default
kubectl label deployment,pod app-purpose=chaos -l app=ghost --namespace more-apps
# In the next step, kill and observe the aliens!



# instalar Kube Doom
# https://github.com/Alynder/kubedoom
# https://opensource.com/article/21/6/kube-doom

git clone https://github.com/Alynder/kubedoom.git
cd kubedoom/helm/
kubectl create ns kubedoom
helm install kubedoom kubedoom/ -n kubedoom
kubectl get svc -n kubedoom
kubectl get pod -n kubedoom
# POD=
#kubectl port-forward kubedoom-kubedoom-chart-676bcc5c9c-xkwpp 5900:5900 -n kubedoom &
#vncviewer viewer localhost:5900

# ou rodar com o docker:
# docker run -p5901:5900 --net=host -v ~/.kube:/root/.kube --rm -it --name kubedoom -d storaxdev/kubedoom:0.5.0


# Executar interface web novnc para conectar
# https://github.com/fcwu/docker-ubuntu-vnc-desktop

docker network create doom
docker run --name ubt-desk -p 6080:80 -v /dev/shm:/dev/shm -d dorowu/ubuntu-desktop-lxde-vnc
docker exec -ti ubt-desk "apt update && apt-get install "
#docker run -p 6080:80 -p 5900:5900 -v /dev/shm:/dev/shm dorowu/ubuntu-desktop-lxde-vnc

# https://hub.docker.com/r/nidup/starcraft/
# Pull the image (from the host):
docker pull nidup/starcraft:v118
# Run the image (from the host):
docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --security-opt seccomp=unconfined nidup/starcraft:v118 bash
# Launch the game (from the image):
wine ~/.wine/drive_c/Program\ Files\ \(x86\)/StarCraft/StarCraft.exe
