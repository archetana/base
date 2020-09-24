FROM python:3.7-slim-buster as base
FROM base as builder

RUN apt-get update && apt-get install -y \
    g++ \
    unixodbc-dev \
    build-essential \
    cmake \
    git \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*


RUN git clone git://git.samba.org/nss_wrapper.git /tmp/nss_wrapper && \
    mkdir /tmp/nss_wrapper/build && \
    cd /tmp/nss_wrapper/build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/lib64 .. && \
    make && \
    make install && \
    rm -rf /tmp/nss_wrapper

from base
COPY --from=builder /usr/local/lib64/lib /usr/local/lib
  
ENV USER_NAME=root \
    NSS_WRAPPER_PASSWD=/tmp/passwd \
    NSS_WRAPPER_GROUP=/tmp/group \
    PATH=/root/.local/bin:/usr/lib/jvm/java-8-openjdk-amd64/bin:${PATH} \
    HOME=/tmp \
    SPARK_HOME=/root/.local/lib/python3.7/site-packages/pyspark \
    PYTHONPATH=/root/.local/lib/python3.7/site-packages



RUN for path in "$NSS_WRAPPER_PASSWD" "$NSS_WRAPPER_GROUP"; do \
  touch $path && chmod 666 $path ; done

COPY nss-wrap.sh /nss-wrap.sh

ENTRYPOINT ["/nss-wrap.sh"]
