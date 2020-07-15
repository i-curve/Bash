#!/bin/bash
#author: curve
#名称:ubuntu初始系统一键配置大全,包括更新脚本,bash配置,vim配置
#System:Ubuntu 18.04
#
version=1.1

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
touch ~/.vimrc
cat > ~/.vimrc <<EOF
"This is the annotation

"Set the Row Number
"set number
set termencoding=utf-8

"set hlsearch
"set incsearch

set ts=4
set softtabstop=4
"set shiftwidth=4
"set expandtab

set autoindent

"Set the Map
let mapleader=","
inoremap <leader>w <Esc>:w<cr>
inoremap jj <Esc>
"vnoremap jj <Esc>

"This is the plug: vim-plug
call plug#begin('~/.vim/plugged')
Plug 'mhinz/vim-startify'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'altercation/vim-colors-solarized'
"Plug 'Yggdroot/indentLine'
"Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
"Plug 'yyzybb/cppenv'
"Plug 'xavierd/clang_complete'
"Plug 'suxpert/vimcaps'
Plug 'easymotion/vim-easymotion'
Plug 'scrooloose/nerdtree'
Plug 'kien/ctrlp.vim'
call plug#end()

"Set the Map in Plug
nnoremap <leader>v :NERDTreeFind<cr>
nnoremap <leader>g :NERDTreeToggle<cr>
let g:ctrlp_map = '<c-p>'

nmap ss <Plug>(easymotion-s2)
" python-mode
"
let g:pymode_python = 'python3'
let g:pymode_trim_whitespaces = 1
let g:pymode_rope_goto_definition_bind = '<C-]>'
let g:pymode_lint = 1 
"
"
" g++-mode
"
"let g:clang_library_path='/usr/lib/llvm-3.8/lib'
 "" or path directly to the library file
"let g:clang_library_path='/usr/lib64/libclang.so.3.8'
EOF
mkdir -p /etc/ubuntu
cat > /etc/ubuntu <<EOF
version $version
EOF
}
function remove(){
	if [[ -e /etc/ubuntu ]];then
	rm -rf ~/update.sh
	rm -rf ~/.vimrc
	rm -rf ~/.vim
	rm -rf /etc/ubuntu
	L=$(cat ~/.bashrc|wc -l)
	k=$(($L-$l))
	sed -i "$k,${L}d" ~/.bashrc
    L=$(cat /etc/hosts|grep -in "github start"|cut -d: -f1)
    k=$(cat /etc/hosts|grep -in "github start"|cut -d: -f1)
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
			wget  $url
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
