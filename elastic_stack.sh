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
  http:
    tls:
      selfSignedCertificate:
        disabled: true
EOF

kubectl get kibana
kubectl get pod --selector='kibana.k8s.elastic.co/name=fiap'
kubectl expose deployment fiap-kb --type=NodePort --port=5601
kubectl get service fiap-kb-http
# Login as the elastic user. The password
echo "   Password do user elastic:"
kubectl get secret fiap-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo

# Deploy APM
cat <<EOF | kubectl apply -f -
apiVersion: apm.k8s.elastic.co/v1
kind: ApmServer
metadata:
  name: apm-server-fiap
  namespace: default
spec:
  version: 7.9.2
  count: 1
  elasticsearchRef:
    name: fiap
  kibanaRef:
    name: fiap
  http:
    tls:
      selfSignedCertificate:
        disabled: true
EOF

kubectl get apmservers
kubectl get pods --selector='apm.k8s.elastic.co/name=apm-server-fiap'
kubectl get service --selector='common.k8s.elastic.co/type=apm-server'
kubectl get secret/apm-server-fiap-apm-token -o go-template='{{index .data "secret-token" | base64decode}}'

# Deploy APP Client APM NodeJS (app-client-apm-nodejs)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: appclientapmnodejs
  labels:
    app: appclientapmnodejs
spec:
  replicas: 1
  selector:
    matchLabels:
      app: appclientapmnodejs
  template:
    metadata:
      labels:
        app: appclientapmnodejs
    spec:
      containers:
        - name: consumer
          image: "tonanuvem/app-client-apm-nodejs"
          env:
            - name: APM
              value: "apm-server-fiap-apm-http"
          ports:
            - name: http
              containerPort: 3000
---
kind: Service
apiVersion: v1
metadata:
  name: appclientapmnodejs-service
spec:
  selector:
    app: appclientapmnodejs
  ports:
    - protocol: "TCP"
      port: 3000
      targetPort: 3000
      nodePort: 32300
  type: NodePort
EOF
