#!/bin/bash
#author: curve
#名称:linux初始系统一键配置大全,包括更新脚本,bash配置,vim配置
#System:Ubuntu 18.04
#
# 1. update.sh 更新文件
# 2. .bashrc文件追加环境配置
# 3. .vimrc 配置文件
# 4. .tmux.conf 配置文件
#
url_vim="https://raw.githubusercontent.com/i-curve/config/master/vimrc"
url_tmux="https://raw.githubusercontent.com/i-curve/config/master/tmux"
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
function check() {
	if cat /etc/issue | grep -Eqi "debian|ubuntu"; then
		systemPackage="apt-get"
	elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
		systemPackage="yum"
	else
		red "系统不匹配"
		exit 1
	fi
}
check

# install 执行安装
function install() {
	# 更新软件包
	sudo $systemPackage update
	sudo $systemPackage -y upgrade
	sudo $systemPackage install -y git vim tmux

	#1. update.sh配置
	cat >~/update.sh <<EOF
sudo $systemPackage update
sudo $systemPackage -y dist-upgrade
sudo $systemPackage -y autoremove
EOF
	chmod +x ~/update.sh

	# * 如果更新的话, 这些文件不动
	if [[ "$1" != "update" ]]; then
		#2. bashrc配置
		cat >>~/.bashrc <<EOF
alias tm='tmux'
alias rm='rm -i'
export GOPROXY=https://goproxy.io
EOF
		read -p "Please type the name:" -t 10 st
		if [[ -z "$st" ]]; then st=linux; fi
		echo "export PS1=\"\\u@$st>\" " >>~/.bashrc

		#3. vimrc配置
		curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
			https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	fi
	curl -o ~/.vimrc $url_vim

	#4. tmux.conf配置
	curl -o ~/.tmux.conf $url_tmux
}
# update 执行更新
function update() {
	green "正在卸载就组件"
	remove update
	green "执行安装过程"
	install update
}

# remove 执行删除
function remove() {
	if [[ -e ~/update.sh ]]; then
		rm -rf ~/update.sh
		rm -rf ~/.vimrc
		rm -rf ~/.tmux.conf
		# 如果更新的话就不删不删除该文件
		if [[ "$1" != "update" ]]; then
			rm -rf ~/.vim
			L=$(cat ~/.bashrc | grep -in "tmux" | cut -d: -f1)
			k=$(cat ~/.bashrc | grep -in "export ps1" | cut -d: -f1)
			sed -i "$L,${k}d" ~/.bashrc
		fi
	else
		echo "未安装"
	fi
}

#start 入口
function start() {
	clear
	green "==========================="
	green "==========================="
	green " Author:curve"
	green " Target:linux初始配置"
	green " 系统：centos7+/debian9+/ubuntu16.04+"
	green "==========================="
	echo
	green " ====================="
	yellow " 1. 一键安装"
	green " ====================="
	yellow " 2. 一键升级"
	green " ====================="
	yellow " 3. 一键卸载"
	green " ====================="
	yellow " 0. 退出"
	echo
	read -p "请输入数字：" num
	case "$num" in
	1)
		install
		;;
	2)
		update
		;;
	3)
		remove
		;;
	0)
		exit 0
		;;
	*)
		clear
		red "请输入正确数字"
		sleep 1
		start
		;;
	esac
}
start
