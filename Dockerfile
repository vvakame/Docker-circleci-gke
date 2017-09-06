FROM ubuntu:17.04
MAINTAINER vvakame <vvakame@gmail.com>

# GKE build & testing environment for Circle CI 2.0

ENV NODEJS_VERSION v8
ENV DOCKER_VERSION 17.05.0-ce

RUN mkdir /work
WORKDIR /work

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        vim \
        curl ca-certificates \
        build-essential git unzip \
        openjdk-8-jdk-headless \
        python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# setup Google Cloud SDK
ENV PATH=/work/google-cloud-sdk/bin:$PATH
RUN curl -o google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-158.0.0-linux-x86_64.tar.gz && \
    tar -zxvf google-cloud-sdk.tar.gz && \
    rm google-cloud-sdk.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \
    gcloud components update --quiet && \
    gcloud --quiet components install docker-credential-gcr kubectl

# setup node.js environment
ENV PATH=/root/.nodebrew/current/bin:$PATH
RUN curl -L git.io/nodebrew | perl - setup && nodebrew install-binary ${NODEJS_VERSION} && nodebrew use ${NODEJS_VERSION}

# setup openjdk environment
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# setup docker client
RUN curl -L -o /tmp/docker.tgz https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz && \
    tar -xz -C /tmp -f /tmp/docker.tgz && \
    mv /tmp/docker/* /usr/bin && \
    rm -rf /tmp/docker /tmp/docker.tgz