#!/bin/bash
# Author: Jrohy
# Github: https://github.com/Jrohy/nodejs-install

# cancel centos alias
[[ -f /etc/redhat-release ]] && unalias -a

INSTALL_VERSION=""

#######color code########
RED="31m"      
GREEN="32m"  
YELLOW="33m" 
BLUE="36m"
FUCHSIA="35m"

colorEcho(){
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

#######get params#########
while [[ $# > 0 ]];do
    KEY="$1"
    case $KEY in
        -v|--version)
        INSTALL_VERSION="$2"
        echo -e "准备安装$(colorEcho ${BLUE} $INSTALL_VERSION)版本nodejs..\n"
        shift
        ;;
        *)
                # unknown option
        ;;
    esac
    shift # past argument or value
done
#############################

ipIsConnect(){
    ping -c2 -i0.3 -W1 $1 &>/dev/null
    if [ $? -eq 0 ];then
        return 0
    else
        return 1
    fi
}

checkSys() {
    #检查是否为Root
    [ $(id -u) != "0" ] && { colorEcho ${RED} "Error: You must be root to run this script"; exit 1; }
    # 缺失/usr/local/bin路径时自动添加
    [[ -z `echo $PATH|grep /usr/local/bin` ]] && { echo 'export PATH=$PATH:/usr/local/bin' >> /etc/profile; source /etc/profile; }
}

setupProxy(){
    ipIsConnect "www.google.com"
    if [[ ! $? -eq 0 && -z `npm config list|grep taobao` ]]; then
        npm config set registry https://registry.npm.taobao.org
        colorEcho $GREEN "当前网络环境为国内环境, 成功设置淘宝代理!"
    fi
}

installNodejs(){
    if [[ -z $INSTALL_VERSION ]];then
        echo "正在获取最新版nodejs..."
        INSTALL_VERSION=`curl -H 'Cache-Control: no-cache'  "https://api.github.com/repos/nodejs/node/releases/latest" | grep 'tag_name' | cut -d\" -f4`
        echo "最新版nodejs: `colorEcho $BLUE $INSTALL_VERSION`"
        if [[ `command -v node` ]];then
            if [[ `node -v` == $INSTALL_VERSION ]];then
                return
            fi
        fi
    fi
    [[ ! $INSTALL_VERSION =~ "v" ]] && INSTALL_VERSION="v${INSTALL_VERSION}"
    BASENAME="node-$INSTALL_VERSION-linux-x64"
    FILE_NAME="$BASENAME.tar.xz"
    curl -L https://nodejs.org/dist/$INSTALL_VERSION/$FILE_NAME -o $FILE_NAME
    tar xJvf $FILE_NAME
    cp -rf $BASENAME/* /usr/local/
    rm -rf $BASENAME*
}

main(){
    checkSys
    installNodejs
    setupProxy
    echo -e "nodejs `colorEcho $BLUE $INSTALL_VERSION` 安装成功!"
}

main