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
set -e
source "$(dirname $0)/../util/util.sh"

config="https://github.com/i-curve/config.git"

UtilCheck

# Install 执行安装
function Install() {
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

	cat >>~/.bashrc <<EOF
 # >>> linux initialize >>>
alias tm='tmux'
alias rm='rm -i'
export GOPROXY=https://goproxy.io
# <<< linux initialize <<<
EOF

	#3. vimrc配置
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

	cd ~
	git clone $config
	ln -s $(pwd)/config/vimrc $(pwd)/.vimrc
	ln -s $(pwd)/config/tmux $(pwd).tmux.conf
}

#start 入口
function start() {
	UtilEchoHead "linux初始配置"
	echo
	green " ====================="
	yellow " 1. 一键初始化"
	green " ====================="
	yellow " 0. 退出"
	echo
	read -p "请输入数字：" num
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
