FROM python:3.7-slim-buster as base
FROM base as builder

COPY requirements.txt /app/python/requirements.txt
COPY install-pyrequirements.sh .

RUN sed -i '/messagebus /d' /var/lib/dpkg/statoverride && \
    apt-get update &&  apt-get upgrade -y && apt-get install -y\
    procps \
    ca-certificates \
    gnupg2 \
    curl \
    wget \
    unixodbc-dev \
    build-essential \
    g++ \
    cmake \
    git \
    openssh-client \
    libenchant1c2a && \ 
    curl -fsSL https://deb.nodesource.com/setup_12.x  | bash - && \
    curl -L -o openjdk.tar.gz \
        https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz &&\
    mkdir -p /opt/jdk &&\
    tar zxf openjdk.tar.gz -C /opt/jdk --strip-components=1 &&\
     rm -rf openjdk.tar.gz &&\
    ln -sf /opt/jdk/bin/* /usr/local/bin/ &&\
    rm -rf /var/lib/apt/lists/* &&\
    java  --version &&\
    javac --version &&\
    jlink --version &&\
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - &&\
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list &&\
    apt-get update && ACCEPT_EULA=Y apt-get install -y \
    msodbcsql17 \
    nodejs &&\
    npm install --global yarn &&\
    ./install-pyrequirements.sh &&\
    wget https://mirrors.estointernet.in/apache/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz &&\
    tar xvf apache-maven-3.8.1-bin.tar.gz &&\
    mv apache-maven-3.8.1 /usr/local/lib/maven &&\
    ln -s /usr/local/lib/maven/bin/mvn /usr/bin/mvn &&\
    rm apache-maven-3.8.1-bin.tar.gz &&\
    git clone git://git.samba.org/nss_wrapper.git /tmp/nss_wrapper && \
    mkdir /tmp/nss_wrapper/build && \
    cd /tmp/nss_wrapper/build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/lib64 .. && \
    make && \
    make install && \
    rm -rf /tmp/nss_wrapper

ADD spark-defaults.conf /venv/lib/python3.7/site-packages/pyspark/conf/spark-defaults.conf
  
ENV USER_NAME=root \
    NSS_WRAPPER_PASSWD=/tmp/passwd \
    NSS_WRAPPER_GROUP=/tmp/group \
    HOME=/tmp \
    SPARK_HOME=/venv/lib/python3.7/site-packages/pyspark \
    PYTHONPATH=/venv/lib/python3.7/site-packages

RUN chgrp -R 0 /tmp/ && \
    chmod -R g=u /tmp/  && \
    chgrp -R 0  /usr/local/ && \
    chmod -R g=u  /usr/local/ && \
    for path in "$NSS_WRAPPER_PASSWD" "$NSS_WRAPPER_GROUP"; do \
      touch $path && chmod 666 $path ; done && \
     chmod +rwx /etc/ssl/openssl.cnf && \
    sed -i 's/TLSv1.2/TLSv1/g' /etc/ssl/openssl.cnf && \
    sed -i 's/SECLEVEL=2/SECLEVEL=1/g' /etc/ssl/openssl.cnf

COPY nss-wrap.sh /nss-wrap.sh

ENTRYPOINT ["/nss-wrap.sh"]
