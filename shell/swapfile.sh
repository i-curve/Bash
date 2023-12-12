#!/bin/bash
## bash
# @Author: i-curve
# @Date: 2020-03-21 20:16:04
# @Last Modified by: curve
# @Name: swap内存构建
##
set -e

# shellcheck source=/root/Bash/util/util.sh
source "$(dirname $0)/../util/util.sh"

path=/root/shell
config=/etc/swap
status=$(free | grep -i swap | tr -s " " | cut -d' ' -f 2)

function Install() { #1.安装
	CheckRoot && green "开始创建 swap"
	if [[ $status != 0 ]]; then
		echo "虚拟内存已经存在,无法安装,3s后退出..." && sleep 3
		ErrorExit 2 "swap 已经存在"
	fi
	green "状态ok,准备安装..."
	mkdir -p "$path"
	cd "$path" && mkdir swap && cd swap
	read -p "请输入分多少块,默认1块: " count
	if [ -z $count ]; then count=1; fi
	read -p "请输入每块虚拟内存大小,单位M: " bs
	if [ -z $bs ]; then bs=10; fi
	sudo dd if=/dev/zero of=swapfile bs="$bs"M count="$count" >/dev/null
	sudo mkswap swapfile >/dev/null
	sudo swapon swapfile
	if [ $? != 0 ]; then
		ErrorExit 1 "失败..."
	fi
	echo "创建成功,2s后创建启动脚本..." && sleep 2
	echo "$path/swap/swapfile swap swap defaults 0 0" >>/etc/fstab
	echo "OK!"
	mkdir /etc/swap && cd /etc/swap
	cat >config <<EOF
path $path
number $count
size $bs
EOF
}

function Get() { # 查看虚拟内存配置
	cat $config/config
}

function Set() { # 修改虚拟内存配置
	Uninstall
	Install
}

function Uninstall() { # 卸载虚拟内存
	if [[ -e /etc/swap/config ]]; then
		CheckRoot && yellow "正在删虚拟内存"
		path=$(cat /etc/swap/config | grep path | cut -d' ' -f2)
		sudo swapoff $path/swap/swapfile
		rm -rf $config
		rm -rf $path/swap
		sed -i '/swap/d' /etc/fstab
		green "删除成功"
	else
		yellow "未安装本脚本"
	fi
}

function Information() { #本脚本信息
	echo "此脚本用于创建,管理由此脚本创建的虚拟内存"
	echo "系统要求ubuntu18.04+系统"
	echo "======================"
	echo "文件夹:/etc/swap,存放本脚本使用的一些配置信息"
	echo "虚拟内存信息:默认在/root/shell/swap"
}

function Start_menu() {
	UtilEchoHead "虚拟内存自动管理脚本"
	echo
	green " ====================="
	yellow " 1. 安装虚拟内存"
	green " ====================="
	yellow " 2. 查看虚拟内存配置"
	green " ====================="
	yellow " 3. 修改虚拟内存配置"
	green " ====================="
	yellow " 4. 卸载虚拟内存"
	green " ====================="
	yellow " 5. readme"
	green " ====================="
	yellow " 0. 退出"
	echo
	read -p "请输入相应数字:" num
	case $num in
	1)
		Install
		;;
	2)
		Get
		;;
	3)
		Set
		;;
	4)
		Uninstall
		;;
	5)
		Information
		;;
	*)
		exit 0
		;;
	esac
}

Start_menu
