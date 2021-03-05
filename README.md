# nodejs-install
![](https://img.shields.io/github/stars/Jrohy/nodejs-install.svg)
![](https://img.shields.io/github/forks/Jrohy/nodejs-install.svg) 
![](https://img.shields.io/github/license/Jrohy/nodejs-install.svg)  
一键安装最新版nodejs, 国内vps自动设置淘宝镜像源([registry.npm.taobao.org](https://registry.npm.taobao.org))

## 安装/更新 最新版nodejs
```
source <(curl -L https://nodejs-install.netlify.app/install.sh)
```

## 安装/更新 指定版本nodejs
```
source <(curl -L https://nodejs-install.netlify.app/install.sh) -v 14.12.0
``` 
## 强制更新nodejs
默认更新策略是已有版本和最新版本一样就不去更新, 要强制更新添加-f
```
source <(curl -L https://nodejs-install.netlify.app/install.sh) -f
```