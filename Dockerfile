FROM python:3.7.3-stretch
LABEL maintainer="Luke Childs <lukechilds123@gmail.com>"

COPY ./bin /usr/local/bin
COPY ./VERSION /tmp

RUN VERSION=$(cat /tmp/VERSION) && \
    chmod a+x /usr/local/bin/* && \
    apt-get install -yq libsnappy-dev zlib1g-dev libbz2-dev libgflags-dev && \
    wget https://launchpad.net/ubuntu/+archive/primary/+files/leveldb_1.20.orig.tar.gz
    tar -xzvf leveldb_1.20.orig.tar.gz
    pushd leveldb-1.20 && make && sudo mv out-shared/libleveldb.* /usr/local/lib && sudo cp -R include/leveldb /usr/local/include && sudo ldconfig && popd
    pip install aiohttp aiorpcX ecdsa plyvel pycodestyle pylru pytest-asyncio pytest-cov Sphinx tribus-hash websocket && \
    git clone -b $VERSION https://github.com/kyuupichan/electrumx.git && \
    cd electrumx && \
    python setup.py install && \
    apt remove git build-base && \
    rm -rf /tmp/*

VOLUME ["/data"]
ENV HOME /data
ENV ALLOW_ROOT 1
ENV DB_DIRECTORY /data
ENV SERVICES=tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000
ENV SSL_CERTFILE ${DB_DIRECTORY}/electrumx.crt
ENV SSL_KEYFILE ${DB_DIRECTORY}/electrumx.key
ENV HOST ""
WORKDIR /data

EXPOSE 50001 50002 50004 8000

CMD ["init"]
