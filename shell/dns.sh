#!/bin/bash
## bash
# @Author: curve
# @Date: 2020-03-21 20:16:04
# @Last Modified by: curve
# @Name: 安装dns
##
set -e

# shellcheck source=../util/util.sh
source "$(dirname $0)/../util/util.sh"

UtilCheck

# Install 安装
function Install() {
    $systemPackage update
    $systemPackage -y upgrade
    $systemPackage install -y bind9

    cd /etc/bind/
    cat >m.txt <<EOF
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

start() {
    UtilEchoHead "DNS服务器安装脚本"
    echo
    green "============================"
    yellow " 1. 安装DNS服务器"
    green "============================"
    yellow " 0. 退出脚本"
    green "============================"
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
        Install
        ;;
    *)
        exit 0
        ;;
    esac
}
start
