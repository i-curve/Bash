#!/bin/bash
#curve
#安装dns服务器
version=1.1
url="https://raw.githubusercontent.com/i-curve/Bash/master/shell/dns.sh"

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
function check(){
    green "正在进行操作系统版本检测..."
    if cat /etc/issue|grep -Eqi "ubuntu|debian";then
        systemPackage="apt-get"
    elif cat /ets/issue|grep -Eqi "centos|red hat|redhat";then
        systemPackage="yum"
        echo "非ubuntu操作系统"
        exit 0
    else
        echo "未能检测到linux操作系统版本，已退出"
        exit 1
    fi
    green "OK"
    sleep 1
}
check


function Install(){
$systemPackage update
$systemPackage -y upgrade
$systemPackage install -y bind9

cd /etc/bind/
cat > m.txt <<EOF
forwarders{
	223.5.5.5;
	223.6.6.6;
	8.8.8.8;
	8.8.4.4;
};
listen-on port 53 {any;};
allow-query {any;}; 
EOF
sed -i '16r m.txt' named.conf.options
sed -i 's/dnssec-validation auto/dnssec-validation no/' named.conf.options
rm m.txt
service bind9 restart
}
function Uninstall(){
    red "正在卸载..."
    $systemPackage remove bind9
    red "卸载成功"
}
function Update(){
    version_local=$version
    version_hub="curl $url|grep ^version\>|cut -d'=' -f2"
    if [[ "$version_local" = "$version_hub" ]];then
        green "已是最新版本"
    else
        yellow "正在更新"
        curl -O $url
        yellow "更新成功"
        exit 0
    fi
}
start(){
    clear
    green "============================="
    red "      Author:curve           "
    green "   Shell:DNS服务器安装脚本"
    red "   OS:ubuntu16.04+"
    green "============================="
    echo
    green "============================"
    red " 1. 安装DNS服务器"
    green "============================"
    red " 2. 卸载脚本"
    green "============================"
    red " 3. 更新脚本"
    grenn "============================"
    red " 0. 退出脚本"
    green "============================"
    echo
    read -p "请输入数字:" num
    case "$num" in
        1)
            Install
            ;;
        0)
            exit
            ;;
        8)
            red "请输入正确数字"
            sleep 2
            start
            ;;
    esac
}
start
