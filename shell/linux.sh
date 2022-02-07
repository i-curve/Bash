#!/bin/bash
#author: curve
#名称:linux初始系统一键配置大全,包括更新脚本,bash配置,vim配置
#System:Ubuntu 18.04

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

    cat >>~/.bashrc <<EOF
 # >>> linux initialize >>>
alias tm='tmux'
alias rm='rm -i'
export GOPROXY=https://goproxy.io
# <<< linux initialize <<<
EOF
    InstallShip
    InstallVim
    InstallUpdate
}

# InstallUpdate 安装更新脚本
function InstallUpdate() {
    green "安装更新脚本"
    cat >~/update.sh <<EOF
sudo $systemPackage update
sudo $systemPackage -y dist-upgrade
sudo $systemPackage -y autoremove
EOF
    chmod +x ~/update.sh
    green "更新脚本OK"
}
# InstallShip 安装ship
function InstallShip() {
    bash -c "$(curl -fsSL https://starship.rs/install.sh)"
    echo 'eval "$(starship init bash)"' >>~/.bashrc
}

# InstallVim 配置vim
function InstallVim() {
    green "开始安装vim"
    cd ~
    if [[ ! -d .vim ]]; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || red "vim安装失败" ||
            exit 2
    fi
    if [[ ! -d config ]]; then
        git clone $config
    fi
    ln -s $(pwd)/config/vimrc $(pwd)/.vimrc
    ln -s $(pwd)/config/tmux $(pwd)/.tmux.conf
    green "vim安装OK"
}

# Start 入口
function Start() {
    UtilEchoHead "linux初始配置"
    echo
    green " ====================="
    yellow " 1. 一键初始化"
    green " ====================="
    yellow " 2. 安装starship"
    green " ====================="
    yellow " 3. 安装vim"
    green " ====================="
    yellow " 4. 安装更新脚本"
    green " ====================="
    yellow " 0. 退出"
    echo
    read -p "请输入数字：" num
    case "$num" in
    1)
        Install
        ;;
    2)
        InstallShip
        ;;
    3)
        InstallVim
        ;;
    4)
        InstallUpdate
        ;;
    *)
        exit 0
        ;;
    esac
}
Start
