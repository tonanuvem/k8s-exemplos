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
SENHAELASTIC=$(kubectl get secret fiap-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo)
echo $SENHAELASTIC

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
kubectl describe secret apm-server-fiap-apm-token
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
            - name: ELASTIC_APM_SECRET_TOKEN
              valueFrom:
                secretKeyRef:
                  name: apm-server-fiap-apm-token
                  key: secret-token
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

# Deploy Beats
cat <<EOF | kubectl apply -f -
apiVersion: beat.k8s.elastic.co/v1beta1
kind: Beat
metadata:
  name: fiap
spec:
  type: filebeat
  version: 7.9.2
  elasticsearchRef:
    name: fiap
  config:
    filebeat.inputs:
    - type: container
      paths:
      - /var/log/containers/*.log
  daemonSet:
    podTemplate:
      spec:
        dnsPolicy: ClusterFirstWithHostNet
        hostNetwork: true
        securityContext:
          runAsUser: 0
        containers:
        - name: filebeat
          volumeMounts:
          - name: varlogcontainers
            mountPath: /var/log/containers
          - name: varlogpods
            mountPath: /var/log/pods
          - name: varlibdockercontainers
            mountPath: /var/lib/docker/containers
        volumes:
        - name: varlogcontainers
          hostPath:
            path: /var/log/containers
        - name: varlogpods
          hostPath:
            path: /var/log/pods
        - name: varlibdockercontainers
          hostPath:
            path: /var/lib/docker/containers
EOF

# kubectl get beat
while [ $(kubectl get beat | grep green | wc -l) != '1' ]; do { printf .; sleep 1; } done
kubectl get pods -o wide | grep fiap-beat-filebeat
echo "   Verificando se achou o FILEBEAT no ElasticSearch usando a senha : $PASSWORD"
kubectl run debug --image=yauritux/busybox-curl -it --rm --restart=Never -- curl -u "elastic:$PASSWORD" -k "https://fiap-es-http:9200/filebeat-*/_search"

# Instalar Beats: AWS
curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.9.2-amd64.deb
sudo dpkg -i metricbeat-7.9.2-amd64.deb
sudo mv /etc/metricbeat/metricbeat.yml /etc/metricbeat/metricbeat.bkp
sudo cat >> /etc/metricbeat/metricbeat.yml << EOF
output.elasticsearch:
  hosts: ["fiap-es-http:9200"]
  username: "elastic"
  password: "PASSWORD"
setup.kibana:
  host: "fiap-kb-http:5601"
  username: "elastic"
  password: "PASSWORD"
EOF

sudo metricbeat modules enable kubernetes
sudo metricbeat setup
sudo service metricbeat start

# Acessar UI Kibana
IP=curl checkip.amazonaws.com
echo "   Acessar UI Kibana https://$IP:32561 com usuario elastic e senha $SENHAELASTIC"
