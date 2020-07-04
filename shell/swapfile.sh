#!/bin/bash

version=2.0
#变量(variable)
path=/root/shell
config=/etc/swap

function Check(){
	if [[ `whoami` != root ]];then
		echo "涉及高级权限问题,需要用root用户运行"
		sleep 2
		exit 1
	fi
	status=`free|grep -i swap|tr -s " "|cut -d' ' -f 2`
}
Check
#1.安装
function Install(){
	if [[ $status != 0 ]];then
		echo "虚拟内存已经存在,无法安装,3s后退出..."
		sleep 3
		exit 1;
	else
		echo "状态ok,准备安装..."
	fi
	mkdir -p $path
	cd $path && mkdir swap && cd swap
	read -p "请输入分多少块,默认1块: " count
	if [ -z $count ];then count=1;fi
	read -p "请输入每块虚拟内存大小,单位M: " bs
	if [ -z $bs ];then bs=10;fi
	sudo dd if=/dev/zero of=swapfile bs="$bs"M count="$count" > /dev/null
	sudo mkswap swapfile > /dev/null
	sudo swapon swapfile
	if [ $? != 0 ];then echo "失败...";exit 1;fi
	echo "创建成功,2s后创建启动脚本..."
	sleep 2
	echo "$path/swap/swapfile swap swap defaults 0 0" >> /etc/fstab
	echo "OK!"
	mkdir /etc/swap && cd /etc/swap
cat > config <<EOF
path $path
number $count
size $bs
EOF
}
#2.查看虚拟内存配置
function Get(){
	cat $config/config
}
#修改虚拟内存配置
function Set(){
	Uninstall
	Install
}
#卸载虚拟内存
function Uninstall(){
	if [[ -e /etc/swap/config ]];then
		echo "正在删虚拟内存"
		path=$(cat /etc/swap/config |grep path|cut -d' ' -f2)
		sudo swapoff $path/swap/swapfile
		rm -rf $config
		rm -rf $path/swap
		sed -i '/swap/d' /etc/fstab
		echo "删除成功"
	else
		echo "未安装本脚本"
	fi
}
#本脚本信息
function Information(){
	echo "此脚本用于创建,管理由此脚本创建的虚拟内存"
	echo "系统要求ubuntu18.04+系统"
	echo "======================"
	echo "文件夹:/etc/swap,存放本脚本使用的一些配置信息"
	echo "虚拟内存信息:默认在/root/shell/swap"
}
function Start_menu(){
clear
echo " ======================="
echo " ======================="
echo "      名称:虚拟内存自动管理脚本"
echo "      作者:curve             "
echo "      系统:Linux              "
echo " ======================="
echo " ======================="
echo " ================此脚本适用于未曾设置过虚拟内存的设备"
echo " ================建议先按5查看此脚本所将创建的文件"
echo " ================1. 安装虚拟内存"
echo " ================2. 查看虚拟内存配置"
echo " ================3. 修改虚拟内存配置"
echo
echo " ================4. 卸载虚拟内存"
echo " ================5. 此脚本的原理,以及所创建的文件夹配置信息"
echo " ================0. 退出"
read -p "请输入相应数字:" num
case $num in
	0)
	exit 0
	;;
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
	echo "请输入正确数字,2s后将会重新运行"
	sleep 2s
	Start_menu
	;;
esac
}

Start_menu
