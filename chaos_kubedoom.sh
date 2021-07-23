# instalar interface gráfica e VNC server no Ubuntu
# https://o7planning.org/11307/install-gui-and-vnc-for-ubuntu-server
# https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-ubuntu-18-04-pt

sudo apt-get update
sudo apt-get -y install xfce4 xfce4-goodies tightvncserver xfonts-base

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

docker run -p 6080:80 -v /dev/shm:/dev/shm -d dorowu/ubuntu-desktop-lxde-vnc
#docker run -p 6080:80 -p 5900:5900 -v /dev/shm:/dev/shm dorowu/ubuntu-desktop-lxde-vnc
