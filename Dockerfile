ARG JENKINS_VERSION=lts-slim
FROM jenkins/jenkins:$JENKINS_VERSION

LABEL maintainer="Mehran Torkaman <torkman.mehran@gmail.com>"

##### Install jenkins plugins

RUN jenkins-plugin-cli --plugins \
  configuration-as-code \
  workflow-aggregator \
  job-dsl \
  pipeline-model-definition \
  antisamy-markup-formatter \
  terraform \
  kubernetes \
  kubernetes-cli \
  openshift-client \
  docker-plugin \
  docker-commons \
  docker-workflow \
  git \
  git-parameter \
  github \
  junit \
  cobertura \
  htmlpublisher \
  generic-webhook-trigger \
  ansible \
  credentials \
  credentials-binding \
  rebuild \
  run-condition \
  ssh \
  publish-over-ssh \
  copyartifact \
  metrics \
  prometheus \
  http_request \
  s3 \
  slack \
  mattermost \
  config-file-provider \
  ansicolor \
  keycloak \
  join \
  ws-cleanup \
  ssh-steps \
  ec2 \
  codedeploy \
  permissive-script-security \
  influxdb \
  ssh-credentials \
  matrix-auth \
  durable-task \
  script-security \
  multibranch-scan-webhook-trigger \
  remote-file

USER root

##### Install docker client

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https \
  ca-certificates curl \
  gnupg gnupg2 \
  software-properties-common \
  lsb-release \
  apt-utils

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce-cli

##### Install ansible

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip

RUN pip install wheel && pip install ansible

##### Install kubernetes client

RUN curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
  chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

##### Install helm

RUN curl -fsSL https://baltocdn.com/helm/signing.asc | apt-key add -

RUN apt-add-repository "deb https://baltocdn.com/helm/stable/debian all main"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y helm

##### Install terraform

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -

RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y terraform

##### Install pulumi

RUN curl -LO "https://get.pulumi.com/releases/sdk/pulumi-v$(curl -sL https://www.pulumi.com/latest-version)-linux-x64.tar.gz" && \
  tar -zxf pulumi-v*-linux-x64.tar.gz && \
  mv pulumi/pulumi* /usr/local/bin && \
  rm -rf pulumi-v*-linux-x64.tar.gz pulumi

##### Install maasta

RUN pip install maasta

##### Install go

RUN apt-get install wget
RUN wget https://go.dev/dl/go1.19.3.linux-amd64.tar.gz
RUN tar -C /usr/local -xvzf go1.19.3.linux-amd64.tar.gz

##### Install protoc

RUN apt-get install -y protobuf-compiler 
RUN /usr/local/go/bin/go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
RUN /usr/local/go/bin/go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest
RUN /usr/local/go/bin/go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN /usr/local/go/bin/go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
RUN ln -s /root/go/bin/protoc-gen-go-grpc /usr/local/bin/protoc-gen-go-grpc
RUN ln -s /root/go/bin/protoc-gen-go /usr/local/bin/protoc-gen-go
RUN ln -s /root/go/bin/protoc-gen-grpc-gateway /usr/local/bin/protoc-gen-grpc-gateway
RUN ln -s /root/go/bin/protoc-gen-openapiv2 /usr/local/bin/protoc-gen-openapiv2

##### Install pkg-config
RUN apt-get install -y pkg-config
RUN apt-get install -y libsodium-dev

##### Install tf2

RUN pip install tf2project

USER jenkins

COPY ansible.yaml /tmp/ansible.yaml

RUN ansible-galaxy collection install -r /tmp/ansible.yaml
