FROM golang:1.19.4-bullseye

ARG CUBEFS_VERSION
ENV CUBEFS_VERSION ${CUBEFS_VERSION:-v3.2.0}
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Asia/Shanghai
ENV MAVEN_VERSION=3.8.2
ENV MAVEN_HOME=/usr/local/maven
ENV PATH=${PATH}:${MAVEN_HOME}/bin

RUN \
    set -eux && \
    apt update -y && \
    apt install build-essential tzdata ca-certificates psmisc procps gpg wget tar automake autoconf libtool make curl git unzip sudo libreadline-dev lsb-release gawk -y && \
    mkdir -p /usr/local/src/cubefs && \
    git clone --verbose --progress --depth 1 --branch ${CUBEFS_VERSION} https://github.com/cubefs/cubefs.git /usr/local/src/cubefs && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt update -y && \
    apt install temurin-8-jdk -y && \
    mkdir -p ${MAVEN_HOME} && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xvz --strip-components 1 -C ${MAVEN_HOME}


RUN \
    apt install -y cmake zlib1g-dev libbz2-dev liblz4-dev

RUN \
    cd /usr/local/src/cubefs && \
    cat ./build.sh && \
    ./build.sh
