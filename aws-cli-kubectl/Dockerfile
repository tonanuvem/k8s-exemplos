FROM infrastructureascode/aws-cli
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux
RUN apk -v --no-cache --update add \
        curl \
        && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 
#       && \
#    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
#    kubectl version --client
VOLUME /root/.kube
