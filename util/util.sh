#!/bin/bash
## bash
# @Author: i-curve
# @Date: 2021-12-14 20:16:04
# @Last Modified by: curve
# @Name: util script
##

########################const variable
version=5.0
filename=$0
filepath=$(dirname "$0")
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
function InitEnvironment() {
    sysVer=$(cat /etc/issue | cut -d' ' -f2|cut -d'.' -f1)
    if [[ -z $sysVer || $sysVer -lt "22" ]];then
        ErrorExit 1 "系统版本过低, 请使用ubuntu22.04+"
    fi
    if grep -Eqi "debian|ubuntu|kali|deepin" /etc/issue ||
        grep -Eqi "debian|ubuntu|kali|deepin" /proc/version; then
        systemPackage="apt"
        sysPwd="/lib/systemd/system"
    elif grep -Eqi "centos|red hat|redhat" /etc/issue ||
        grep -Eqi "centos|red hat|redhat" /proc/version; then
        systemPackage="yum"
        sysPwd="/usr/lib/systemd/system"
    else
        ErrorExit 1 "系统不匹配"
    fi
    green "check system ok"
}

# UtilEchoHead $1:target 输出message头部
function UtilEchoHead() {
    green "======================================="
    green "======================================="
    green " Author: i-curve"
    green " Target: $1"
    green " System：ubuntu22.04+"
    green "======================================="
}

function CheckRoot() { #核对是否root用户
    if [[ $(whoami) != root ]]; then
        echo "涉及高级权限问题,需要用root用户运行" && sleep 2
        ErrorExit 1 "权限不足"
    fi
}

# ErrorExit $1 $2: 程序异常退出
# $1: errorCode 程序退出码
# $2: errorMsg 程序错误信息
function ErrorExit() {
    red "ERROR: $2" && exit "$1"
}

function GetIPCountry() {
    local ip=$(curl -s getip.cc)
    local country=$(curl -s https://country.getip.cc?ip="${ip}")
    echo "$country"
}
