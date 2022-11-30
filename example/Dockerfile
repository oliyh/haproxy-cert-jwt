FROM ubuntu:22.04

WORKDIR /tmp

RUN \
apt-get update && \
apt-get install -y curl wget make gcc libssl-dev libreadline-dev unzip haproxy git

RUN \
    curl -R -O http://www.lua.org/ftp/lua-5.3.6.tar.gz && \
    tar zxf lua-5.3.6.tar.gz && \
    cd lua-5.3.6 && \
    make linux && make install

RUN \
    wget https://luarocks.org/releases/luarocks-3.9.1.tar.gz && \
    tar zxpf luarocks-3.9.1.tar.gz && \
    cd luarocks-3.9.1 && \
    ./configure && make && make install

WORKDIR /work

RUN \
    git clone https://github.com/oliyh/luajwt.git && \
    luarocks install --tree rocks luajwt/luajwt-1.0-1.rockspec

COPY example .
COPY cert-jwt.lua .
