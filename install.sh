#!/bin/bash
# Author: Jrohy
# Github: https://github.com/Jrohy/nodejs-install

# cancel centos alias
[[ -f /etc/redhat-release ]] && unalias -a

INSTALL_VERSION=""

FORCE_MODE=0

LATEST=0

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
        -f)
        FORCE_MODE=1
        echo -e "强制更新nodejs..\n"
        ;;
        -l)
        LATEST=1
        echo -e "准备安装最新当前发布版nodejs..\n"
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

sysArch(){
    ARCH=$(uname -m)
    if [[ "$ARCH" == "i686" ]] || [[ "$ARCH" == "i386" ]]; then
        VDIS="linux-386"
    elif [[ "$ARCH" == *"armv7"* ]] || [[ "$ARCH" == "armv6l" ]]; then
        VDIS="linux-armv7l"
    elif [[ "$ARCH" == *"armv8"* ]] || [[ "$ARCH" == "aarch64" ]]; then
        VDIS="linux-arm64"
    elif [[ "$ARCH" == *"s390x"* ]]; then
        VDIS="linux-s390x"
    elif [[ "$ARCH" == "ppc64le" ]]; then
        VDIS="linux-ppc64le"
    elif [[ "$ARCH" == *"darwin"* ]]; then
        VDIS="darwin-x64"
    elif [[ "$ARCH" == "x86_64" ]]; then
        VDIS="linux-x64"
    fi
}

installNodejs(){
    if [[ -z $INSTALL_VERSION ]];then
        [[ $LATEST == 0 ]] && echo "正在获取最新长期支持版nodejs..." || echo "正在获取最新当前发布版nodejs..."
        ALL_VERSION=`curl -s -H 'Cache-Control: no-cache' https://nodejs.org/zh-cn/|grep downloadbutton`
        if [[ $LATEST == 0 ]]; then
            INSTALL_VERSION=`echo "$ALL_VERSION"|sed -n '1p'|grep -oP 'v\d*\.\d\d*\.\d+'|head -n 1`
        else
            INSTALL_VERSION=`echo "$ALL_VERSION"|sed -n '2p'|grep -oP 'v\d*\.\d\d*\.\d+'|head -n 1`
        fi
        if [[ $INSTALL_VERSION == "" ]];then
            [[ $LATEST == 0 ]] && echo "获取最新长期支持版失败, 正在获取最新当前发布版.."
            INSTALL_VERSION=`curl -H 'Cache-Control: no-cache'  "https://api.github.com/repos/nodejs/node/releases/latest" | grep 'tag_name' | cut -d\" -f4`
        fi
        echo "最新版nodejs: `colorEcho $BLUE $INSTALL_VERSION`"
        if [[ $FORCE_MODE == 0 && `command -v node` ]];then
            if [[ `node -v` == $INSTALL_VERSION ]];then
                return
            fi
        fi
    fi
    BASENAME="node-$INSTALL_VERSION-$VDIS"
    FILE_NAME=`[[ "$ARCH" == *"darwin"* ]] && echo "$BASENAME.tar.gz" || echo "$BASENAME.tar.xz"`
    curl -L https://nodejs.org/dist/$INSTALL_VERSION/$FILE_NAME -o $FILE_NAME
    [[ "$ARCH" == *"darwin"* ]] && tar xzvf $FILE_NAME || tar xJvf $FILE_NAME
    if [[ ! $? -eq 0 ]]; then 
        colorEcho $RED "下载安装失败!"
        rm -rf $BASENAME*
        exit 1
    else 
        cp -rf $BASENAME/* /usr/local/
    fi
    rm -rf $BASENAME*
}

main(){
    checkSys
    sysArch
    installNodejs
    setupProxy
    echo -e "nodejs `colorEcho $BLUE $INSTALL_VERSION` 安装成功!"
}

main