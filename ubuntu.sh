#!/bin/bash
#author: curve
#名称:ubuntu初始系统一键配置大全,包括更新脚本,bash配置,vim配置
#System:Ubuntu 18.04
#
if cat /etc/issue | grep -Eqi "debian|ubuntu";then
	echo "系统检测成功,准备安装";
else
	echo "系统不匹配";
	exit 1;
fi
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y git vim
#更新脚本
cat > ~/update.sh <<EOF
sudo apt-get update
sudo apt-get -y upgrade
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
if [[ -z "$st" ]];then st=ubuntu;fi
echo "export PS1=\"\\u@$st>\" " >> ~/.bashrc

#添加github的hosts文件信息,防止下载失败
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
