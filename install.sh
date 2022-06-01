#!/bin/bash
# Author: Jrohy
# Github: https://github.com/Jrohy/nodejs-install

# cancel centos alias
[[ -f /etc/redhat-release ]] && unalias -a

latest=0

force_mode=0

install_version=""

#######color code########
red="31m"      
green="32m"  
yellow="33m" 
blue="36m"
fuchsia="35m"

color_echo(){
    echo -e "\033[$1${@:2}\033[0m"
}

#######get params#########
while [[ $# > 0 ]];do
    case "$1" in
        -v|--version)
        install_version="$2"
        [[ $install_version && ${install_version:0:1} != "v" ]] && install_version="v$install_version"
        echo -e "准备安装$(color_echo ${blue} $install_version)版本nodejs..\n"
        shift
        ;;
        -f)
        force_mode=1
        echo -e "强制更新nodejs..\n"
        ;;
        -l)
        latest=1
        echo -e "准备安装最新当前发布版nodejs..\n"
        ;;
        *)
                # unknown option
        ;;
    esac
    shift # past argument or value
done
#############################

ip_is_connect(){
    ping -c2 -i0.3 -W1 $1 &>/dev/null
    if [ $? -eq 0 ];then
        return 0
    else
        return 1
    fi
}

check_sys() {
    #检查是否为Root
    [ $(id -u) != "0" ] && { color_echo ${red} "Error: You must be root to run this script"; exit 1; }
    # 缺失/usr/local/bin路径时自动添加
    [[ -z `echo $PATH|grep /usr/local/bin` ]] && { echo 'export PATH=$PATH:/usr/local/bin' >> /etc/profile; source /etc/profile; }
}

setup_proxy(){
    ip_is_connect "www.google.com"
    if [[ ! $? -eq 0 && -z `npm config list|grep taobao` ]]; then
        npm config set registry https://registry.npm.taobao.org
        color_echo $green "当前网络环境为国内环境, 成功设置淘宝代理!"
    fi
}

sys_arch(){
    arch=$(uname -m)
    if [[ "$arch" == "i686" ]] || [[ "$arch" == "i386" ]]; then
        vdis="linux-386"
    elif [[ "$arch" == *"armv7"* ]] || [[ "$arch" == "armv6l" ]]; then
        vdis="linux-armv7l"
    elif [[ "$arch" == *"armv8"* ]] || [[ "$arch" == "aarch64" ]]; then
        vdis="linux-arm64"
    elif [[ "$arch" == *"s390x"* ]]; then
        vdis="linux-s390x"
    elif [[ "$arch" == "ppc64le" ]]; then
        vdis="linux-ppc64le"
    elif [[ "$arch" == *"darwin"* ]]; then
        vdis="darwin-x64"
    elif [[ "$arch" == "x86_64" ]]; then
        vdis="linux-x64"
    fi
}

install_nodejs(){
    if [[ -z $install_version ]];then
        [[ $latest == 0 ]] && echo "正在获取最新长期支持版nodejs..." || echo "正在获取最新当前发布版nodejs..."
        all_version=`curl -s -H 'Cache-Control: no-cache' https://nodejs.org/zh-cn/|grep downloadbutton`
        if [[ $latest == 0 ]]; then
            install_version=`echo "$all_version"|sed -n '1p'|grep -oP 'v\d*\.\d\d*\.\d+'|head -n 1`
        else
            install_version=`echo "$all_version"|sed -n '2p'|grep -oP 'v\d*\.\d\d*\.\d+'|head -n 1`
        fi
        if [[ $install_version == "" ]];then
            [[ $latest == 0 ]] && echo "获取最新长期支持版失败, 正在获取最新当前发布版.."
            install_version=`curl -H 'Cache-Control: no-cache'  "https://api.github.com/repos/nodejs/node/releases/latest" | grep 'tag_name' | cut -d\" -f4`
        fi
        echo "最新版nodejs: `color_echo $blue $install_version`"
    fi
    if [[ $force_mode == 0 && `command -v node` ]];then
        if [[ `node -v` == $install_version ]];then
            return
        fi
    fi
    base_name="node-$install_version-$vdis"
    file_name=`[[ "$arch" == *"darwin"* ]] && echo "$base_name.tar.gz" || echo "$base_name.tar.xz"`
    curl -L https://nodejs.org/dist/$install_version/$file_name -o $file_name
    [[ "$arch" == *"darwin"* ]] && tar xzvf $file_name || tar xJvf $file_name
    if [[ ! $? -eq 0 ]]; then 
        color_echo $red "下载安装失败!"
        rm -rf $base_name*
        exit 1
    else 
        cp -rf $base_name/* /usr/local/
    fi
    rm -rf $base_name*
}

main(){
    check_sys
    sys_arch
    install_nodejs
    setup_proxy
    echo -e "nodejs `color_echo $blue $install_version` 安装成功!"
}

main