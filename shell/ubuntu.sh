#!/bin/bash
#author: curve
#名称:ubuntu初始系统一键配置大全,包括更新脚本,bash配置,vim配置
#System:Ubuntu 18.04
#
version=2
url_vim="https://raw.githubusercontent.com/i-curve/language/master/LINUX/vim/.vimrc"

url="https://raw.githubusercontent.com/i-curve/Bash/master/shell/ubuntu.sh"
l=6
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
sudo $systemPackage install -y git vim
#更新脚本
cat > ~/update.sh <<EOF
sudo $systemPackage update
sudo $systemPackage -y upgrade
EOF
chmod +x ~/update.sh

#bashrc.sh脚本
cat >> ~/.bashrc <<EOF
alias tm='tmux'
alias python='python3'
alias pip='pip3'
alias ipython3='ipython3'
export GOPROXY=https://goproxy.io
EOF
read -p "Please type the name:" -t 5 st
if [[ -z "$st" ]];then st=linux;fi
echo "export PS1=\"\\u@$st>\" " >> ~/.bashrc

#添加github的hosts文件信息,防止下载失败
if cat /etc/hosts|grep -Eqi "github.com";then
		echo ""
else
cat >> /etc/hosts <<EOF
# GitHub Start
52.74.223.119 github.com
192.30.253.119 gist.github.com
54.169.195.247 api.github.com
185.199.111.153 assets-cdn.github.com
151.101.76.133 raw.githubusercontent.com
151.101.108.133 user-images.githubusercontent.com
151.101.76.133 gist.githubusercontent.com
151.101.76.133 cloud.githubusercontent.com
151.101.76.133 camo.githubusercontent.com
151.101.76.133 avatars0.githubusercontent.com
151.101.76.133 avatars1.githubusercontent.com
151.101.76.133 avatars2.githubusercontent.com
151.101.76.133 avatars3.githubusercontent.com
151.101.76.133 avatars4.githubusercontent.com
151.101.76.133 avatars5.githubusercontent.com
151.101.76.133 avatars6.githubusercontent.com
151.101.76.133 avatars7.githubusercontent.com
151.101.76.133 avatars8.githubusercontent.com
# GitHub End
EOF
fi
#vim脚本
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -o ~/.vimrc $url_vim
mkdir -p /etc/ubuntu
cat > /etc/ubuntu/version <<EOF
$version
EOF
}
function remove(){
	if [[ -e /etc/ubuntu/version ]];then
	rm -rf ~/update.sh
	rm -rf ~/.vimrc
	rm -rf ~/.vim
	rm -rf /etc/ubuntu
	L=$(cat ~/.bashrc |grep -in "tmux"|cut -d: -f1)
	k=$(cat ~/.bashrc |grep -in "export ps1"|cut -d: -f1)
	sed -i "$L,${k}d" ~/.bashrc
    L=$(cat /etc/hosts|grep -in "github start"|cut -d: -f1)
    k=$(cat /etc/hosts|grep -in "github end"|cut -d: -f1)
    sed -i "$L,${k}d" /etc/hosts
else
		echo "未安装"
	fi
}
function update(){
	echo "正在更新脚本..."
	version_local=$version
	version_hub=$(curl $url|grep "^version\>"|cut -d'=' -f2)
	if [[ "$version_local" = "$version_hub" ]];then
			echo "已经是最新版本"
	else
			wget -O ubuntu.sh $url
			echo "更新成功"
			exit 0
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
		yellow " 3. 一键更新脚本"
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
		3)
				update
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
