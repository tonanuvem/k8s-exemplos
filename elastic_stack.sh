# https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-elasticsearch.html

kubectl apply -f https://download.elastic.co/downloads/eck/1.2.1/all-in-one.yaml

kubectl -n elastic-system logs -f statefulset.apps/elastic-operator

# Deploy: Elasticsearch cluster.
cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: fiap
spec:
  version: 7.9.2
  nodeSets:
  - name: default
    count: 1
    config:
      node.master: true
      node.data: true
      node.ingest: true
      node.store.allow_mmap: false
EOF

kubectl get elasticsearch
kubectl get pods --selector='elasticsearch.k8s.elastic.co/cluster-name=fiap'
kubectl logs -f fiap-es-default-0

# Request Elasticsearch access: A ClusterIP Service is automatically created for your cluster:
kubectl get service fiap-es-http
# Get the credentials.
PASSWORD=$(kubectl get secret fiap-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
# Request the Elasticsearch endpoint from debug.
echo "   Verificando se achou o ElasticSearch usando a senha  $PASSWORD"
kubectl run debug --image=yauritux/busybox-curl -it --rm --restart=Never -- curl -u "elastic:$PASSWORD" -k "https://fiap-es-http:9200"



# Deploy Kibana instance and associate it with your Elasticsearch cluster:
cat <<EOF | kubectl apply -f -
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: fiap
spec:
  version: 7.9.2
  http:
    service:
      spec:
        type: NodePort
  count: 1
  elasticsearchRef:
    name: fiap
EOF

kubectl get kibana
kubectl get pod --selector='kibana.k8s.elastic.co/name=fiap'
kubectl expose deployment fiap-kb --type=NodePort --port=5601
kubectl get service fiap-kb-http
# Login as the elastic user. The password
echo "   Password do user elastic:"
kubectl get secret fiap-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo

# Exemple to grow the cluster to three Elasticsearch nodes:
cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: fiap
spec:
  version: 7.9.2
  nodeSets:
  - name: default
    count: 3
    config:
      node.master: true
      node.data: true
      node.ingest: true
      node.store.allow_mmap: false
EOF
