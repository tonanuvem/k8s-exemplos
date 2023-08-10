# Volume: Exemplo baseado em : https://github.com/killercoda/scenarios-kubernetes/tree/main/persistentVolumes
# Helm Wordpress: https://docs.bitnami.com/kubernetes/get-started-aks/#step-5-access-the-kubernetes-dashboard
# Criar os volumes nos nodes : volumes criados em todos os nodes via ansible.

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
kubectl get pod
