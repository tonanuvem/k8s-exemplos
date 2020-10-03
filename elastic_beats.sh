# https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-beat-configuration-examples.html

# https://github.com/elastic/cloud-on-k8s/tree/master/config/recipes/beats

kubectl apply -f https://download.elastic.co/downloads/eck/1.2.1/all-in-one.yaml

# Metricbeat for Kubernetes
kubectl apply -f https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.2/config/recipes/beats/metricbeat_hosts.yaml

# Filebeat with autodiscover
kubectl apply -f https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.2/config/recipes/beats/filebeat_autodiscover.yaml

# Elasticsearch and Kibana Stack Monitoring
kubectl apply -f https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.2/config/recipes/beats/stack_monitoring.yaml

# Heartbeat monitoring Elasticsearch and Kibana health
kubectl apply -f https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.2/config/recipes/beats/heartbeat_es_kb_health.yaml

# Auditbeatedit
kubectl apply -f https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.2/config/recipes/beats/auditbeat_hosts.yaml

# Journalbeat
kubectl apply -f https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.2/config/recipes/beats/journalbeat_hosts.yaml

# Packetbeat monitoring DNS and HTTP trafficedit
kubectl apply -f https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.2/config/recipes/beats/packetbeat_dns_http.yaml

# Usuario ELASTIC:
PASSWORD=$(kubectl get secret elasticsearch-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')

kubectl patch svc elasticsearch-es-http -p '{"spec": {"type": "NodePort"}}' && kubectl get svc

# Acessar UI Kibana
IP=$(curl checkip.amazonaws.com)
echo "   Acessar UI Kibana https://$IP:32561 com usuario elastic e senha $PASSWORD"
