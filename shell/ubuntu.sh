#!/bin/bash
#author: curve
#名称:ubuntu初始系统一键配置大全,包括更新脚本,bash配置,vim配置
#System:Ubuntu 18.04
#
url_vim="https://raw.githubusercontent.com/i-curve/config/master/vimrc"
url_hosts="https://raw.githubusercontent.com/i-curve/config/master/githubhosts"
url_tmux="https://raw.githubusercontent.com/i-curve/config/master/tmux"
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
if cat /etc/issue | grep -Eqi "debian|ubuntu";then
	systemPackage="apt-get"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat";then
	systemPackage="yum"
else
	red "系统不匹配";
	exit 1;
fi
}
check
function install(){
sudo $systemPackage update
sudo $systemPackage -y upgrade
sudo $systemPackage install -y git vim tmux
#更新配置
cat > ~/update.sh <<EOF
sudo $systemPackage update
sudo $systemPackage -y dist-upgrade
EOF
chmod +x ~/update.sh

#bashrc.sh配置
cat >> ~/.bashrc <<EOF
alias tm='tmux'
alias python='python3'
alias pip='pip3'
alias ipython='ipython3'
export GOPROXY=https://goproxy.io
EOF
read -p "Please type the name:" -t 10 st
if [[ -z "$st" ]];then st=linux;fi
echo "export PS1=\"\\u@$st>\" " >> ~/.bashrc

# #添加github的hosts文件信息,防止下载失败
# if cat /etc/hosts|grep -Eqi "github.com";then
# 		echo ""
# else
# hosts=`curl -s $url_hosts`
# echo "$hosts" >> /etc/hosts
# fi

#vimrc配置
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -o ~/.vimrc $url_vim
mkdir -p /etc/Bash

#tmux.con配置
curl $url_tmux >> ~/.tmux.conf

cat > /etc/Bash/ubuntu <<EOF
version
EOF

}
function remove(){
	if [[ -e /etc/Bash/ubuntu ]];then
	rm -rf ~/update.sh
	rm -rf ~/.vimrc
	rm -rf ~/.vim
	rm -rf ~/.tmux.conf
	rm -rf /etc/ubuntu
	L=$(cat ~/.bashrc |grep -in "tmux"|cut -d: -f1)
	k=$(cat ~/.bashrc |grep -in "export ps1"|cut -d: -f1)
	sed -i "$L,${k}d" ~/.bashrc
    # L=$(cat /etc/hosts|grep -in "github start"|cut -d: -f1)
    # k=$(cat /etc/hosts|grep -in "github end"|cut -d: -f1)
    # sed -i "$L,${k}d" /etc/hosts
	else
		echo "未安装"
	fi
}
start(){
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
		yellow " 2. 一键卸载"
		green " ====================="
		yellow " 0. 退出"
		echo
		read -p "请输入数字：" num
		case "$num" in
			1)
				install
				;;
			2)
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
