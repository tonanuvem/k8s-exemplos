# FROM infrastructureascode/aws-cli

# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux
# https://github.com/infrastructure-as-code/docker-aws-cli/blob/master/aws.sh

FROM alpine:latest
ENV AWSCLI_VERSION "1.19.21"
RUN apk -v --no-cache --update add \
        python3 \
        py3-pip \
        groff \
        less \
        mailcap \
        curl \
        && \
    pip --no-cache-dir install --upgrade awscli==${AWSCLI_VERSION} && \
    apk -v --purge del py-pip && \
    rm -rf /var/cache/apk/*
VOLUME /root/.aws
VOLUME /root/.kube
VOLUME /fiap
WORKDIR /fiap
# Executar na maquina que está fazendo o build
#    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 
COPY kubectl /usr/local/bin/

#WORKDIR /usr/local/bin/
#    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
#    kubectl version --client
