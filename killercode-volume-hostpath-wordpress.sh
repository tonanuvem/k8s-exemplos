# Volume: Exemplo baseado em : https://github.com/killercoda/scenarios-kubernetes/tree/main/persistentVolumes
# Helm Wordpress: https://docs.bitnami.com/kubernetes/get-started-aks/#step-5-access-the-kubernetes-dashboard

# Criar os volumes nos nodes: controlplane e node01

#controlplane
mkdir /tmp/wordpress-vol
mkdir /tmp/mariadb-vol
sudo chown -R 1001:1001 /tmp/wordpress-vol
sudo chown -R 1001:1001 /tmp/mariadb-vol

#node01
ssh node01 'mkdir /tmp/wordpress-vol'
ssh node01 'mkdir /tmp/mariadb-vol'
ssh node01 'sudo chown -R 1001:1001 /tmp/wordpress-vol'
ssh node01 'sudo chown -R 1001:1001 /tmp/mariadb-vol'


### WORDPRESS 

# Criando PV
# example: https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume
kubectl apply -f - <<EOF

apiVersion: v1
kind: PersistentVolume
metadata:
  name: wordpress-volume #changed
  namespace: default #added
  labels:
    type: local
spec:
  storageClassName: manual #make sure to include
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/wordpress-vol" #changed

EOF

# Criando PVC
#kubectl apply -f - <<EOF

#apiVersion: v1
#kind: PersistentVolumeClaim
#metadata:
#  name: wordpress #changed
#spec:
#  storageClassName: manual #important
#  accessModes:
#    - ReadWriteOnce
#  resources:
#    requests:
#      storage: 100Mi #changed

#EOF


### BANCO DE DADOS: MARIA-DB

# Criando PV
# example: https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume
kubectl apply -f - <<EOF

apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-volume #changed
  namespace: default #added
  labels:
    type: local
spec:
  storageClassName: manual #make sure to include
  capacity:
    storage: 500Mi #changed
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/mariadb-vol" #changed

EOF

# Criando PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-wordpress-mariadb-0 #changed
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi #changed
EOF

# Adicionando um Repositório:
helm repo add azure-marketplace https://marketplace.azurecr.io/helm/v1/repo && helm repo update
helm install wordpress azure-marketplace/wordpress
kubectl patch pvc wordpress -p  '{"spec": {"storageClassName": "manual"}}'
kubectl get pv
kubectl get pvc
kubuctl describe pvc wordpress
kubectl get pod
