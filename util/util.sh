#!/bin/bash
## bash
# @Author: curve
# @Date: 2021-12-14 20:16:04
# @Last Modified by: curve
# @Last Modified time: 2021-12-14 23:56:42
##

set -e

########################const variable
filename=$0
filepath=$(dirname $0)
##############################

yellow() {
    echo -e "\033[33m\033[01m$1\033[0m"
}
green() {
    echo -e "\033[32m\033[01m$1\033[0m"
}
red() {
    echo -e "\033[31m\033[01m$1\033[0m"
}

# check 检查系统是否符合
function UtilCheck() {
    green "check system"
    if cat /etc/issue | grep -Eqi "debian|ubuntu|kali|deepin"; then
        systemPackage="apt-get"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        systemPackage="yum"
    else
        red "系统不匹配"
        exit 1
    fi
}

# UtilGetVersion (  url flags)更新脚本
function UtilGetVersion() {
    local version=$(curl -sL $1 | grep $2 | cut -d'=' -f2)
    echo $version
}

# UtilEchoHead $1:target 输出message头部
function UtilEchoHead() {
    clear
    green "======================================="
    green "======================================="
    green " Author:curve"
    green " Target:$1"
    green " System：centos7+/debian9+/ubuntu18.04+"
    green "======================================="
}
