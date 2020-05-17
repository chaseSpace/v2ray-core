#!/usr/bin/env bash

now=$(pwd)

which git > /dev/null || apt-get install git -y

if [[ -z "$GOPATH" ]]; then
  sh install_go.sh
  mkdir /v2ray &> /dev/null
  export GOPATH=/v2ray
fi

mkdir -p '/etc/v2ray' '/var/log/v2ray' '/usr/bin/v2ray'

PJ_NAME="v2ray-core"

if [[ ! -e ${PJ_NAME} ]];then
    PROJECT_URL="https://github.com/chaseSpace/$PJ_NAME.git"
    git clone ${PROJECT_URL}
fi

pj_dir=$(pwd)/${PJ_NAME}

cd ${pj_dir}/main && go build -o $GOPATH/bin/v2ray
cd ${pj_dir}/infra/control/main &&  go build -o $GOPATH/bin/v2ctl

cd ${now}

/bin/cp -rf $GOPATH/bin/v2ray /usr/bin/v2ray/
/bin/cp -rf $GOPATH/bin/v2ctl /usr/bin/v2ray/

/bin/cp -rf ${pj_dir}/release/config/systemd/v2ray.service /etc/systemd/system

jsonCfg='/etc/v2ray/config.json'

if [ ! -e $jsonCfg ];then
    cp ${pj_dir}/main/config.json ${jsonCfg}
fi

syste mctl enable v2ray.service