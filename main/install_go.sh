#!/usr/bin/env bash

aim=go1.13.9.linux-amd64.tar.gz

now=$(pwd) && \
cd /usr/local && \
wget https://studygolang.com/dl/golang/$aim && \
tar xzf $aim && \
rm -rf $aim && \
echo export PATH=$PATH:/usr/local/go/bin >> /root/.bashrc && \
echo export GOPROXY=https://goproxy.cn >> /root/.bashrc && \
echo export go111module=on >> /root/.bashrc  && \
source /root/.bashrc
cd $now