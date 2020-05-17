#!/usr/bin/env bash

INSTALL_DIR=$HOME

which git > /dev/null || apt-get install git -y

# install golang
if [[ -z "$GOPATH" ]]; then
  sh install_go.sh
  mkdir /v2ray &> /dev/null
  export GOPATH=/v2ray
fi

PJ_NAME="v2ray-core"
PROJECT_URL="https://github.com/chaseSpace/$PJ_NAME.git"

pj_dir=$HOME/${PJ_NAME}

dir_etc_v2='/etc/v2ray'
dir_log_v2='/var/log/v2ray'
dir_usrbin_v2='/usr/bin/v2ray'

use_json_cfg='/etc/v2ray/config.json'

__copy_config(){
    force=$1
    if [[ ${force} = '-f' ]];then
        /bin/cp ${pj_dir}/main/config.json ${use_json_cfg}
    else
        if [[ ! -e ${use_json_cfg} ]];then
            cp ${pj_dir}/main/config.json ${use_json_cfg}
        fi
    fi
}

__compile_and_overwrite_old(){
    git pull origin
    now=$(pwd)

    cd ${pj_dir}/main && go build -o $GOPATH/bin/v2ray
    cd ${pj_dir}/infra/control/main &&  go build -o $GOPATH/bin/v2ctl

    cd ${now}

    /bin/cp -rf $GOPATH/bin/v2ray $dir_usrbin_v2/
    /bin/cp -rf $GOPATH/bin/v2ctl $dir_usrbin_v2/
    /bin/cp -rf ${pj_dir}/release/config/*.* $dir_usrbin_v2/

    /bin/cp -rf ${pj_dir}/release/config/systemd/v2ray.service /etc/systemd/system/
}

install (){
    mkdir -p $dir_etc_v2 $dir_log_v2 $dir_usrbin_v2

    if [[ ! -e ${PJ_NAME} ]];then
        git clone ${PROJECT_URL}
    fi

    __compile_and_overwrite_old

    # overwrite if file exists
    __copy_config -f

    export V2RAY_LOCATION_TOOL=$dir_usrbin_v2
    export V2RAY_LOCATION_ASSET=$dir_usrbin_v2

    systemctl restart v2ray
}


update(){
    cd ${pj_dir}

    __compile_and_overwrite_old

    # it will cancel if file exists(not force)
    __copy_config

    systemctl restart v2ray
}

main(){
    arg=$1
    case $arg in
    '-i') echo 'start install...'
        install ;;
    '-u') echo 'start update...'
        update ;;
    *) echo 'You must input args what you want!'
        ;;
    esac
}

main $1