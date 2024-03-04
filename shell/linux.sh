#!/bin/bash
## bash
# @Author: i-curve
# @Date: 2020-03-21 20:16:04
# @Last Modified by: curve
# @Name: linux初始化
##
set -e

# shellcheck source=/root/Bash/util/util.sh
source "$(dirname $0)/../util/util.sh"
source "$(dirname $0)/../util/data.sh"

InitEnvironment

# Install 执行安装
function Install() {
    cat >>~/.bashrc <<EOF
 # >>> linux initialize >>>
alias tm='tmux'
alias rm='rm -i'
export GOPROXY=https://proxy.golang.com.cn,direct
# <<< linux initialize <<<
EOF
    InstallShip
    InstallVim
    InstallUpdate
    InstallGoPPA
    InstallNVM
    InstallShfmt
}

# InstallShip 安装ship
function InstallShip() {
    sh -c "$(curl -fsSL $Ship)" || ErrorExit 2 "starship 下载失败, 请检查网络"
    cat >>~/.bashrc <<EOF
eval "$(starship init bash)" 
EOF
}

# InstallVim 配置vim
function InstallVim() {
    green "开始安装vim..."
    cd ~
    if [[ ! -d .vim ]]; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs ${VimPlug} ||
            ErrorExit 3 "vim-plug 下载失败, 请检查网络(外网)"
    fi
    if [[ ! -d config ]]; then
        git clone $Config || ErrorExit 10 "$Config 克隆失败, 请检查网络"
    fi
    ln -s "$(pwd)/config/vimrc" "$(pwd)/.vimrc"
    ln -s "$(pwd)/config/tmux" "$(pwd)/.tmux.conf"
    ln -s "$(pwd)/config/.ycm_extra_conf.py" "$(pwd)/.ycm_extra_conf.py"
    green "vim安装成功"
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
# InstallGoPPA go 换源
function InstallGoPPA() {
    green "开始安装ppa..."
    if grep -qi "ubuntu" /etc/issue; then
        # c++ 换源         # go 换源
        sudo $systemPackage install software-properties-common
        sudo add-apt-repository ppa:longsleep/golang-backports
        sudo apt-get update
    fi
}

# InstallNVM 安装nvm
function InstallNVM() {
    curl -o- $Nvm | bash || ErrorExit 4 "NVM 安装失败, 请检查网络(外网)"
}

# InstallShfmt 安装shfmt
function InstallShfmt() {
    curl -sS $Shfmt | bash || ErrorExit 5 "shfmt 安装失败, 请检查网络"
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
    yellow " 5. 安装nvm"
    green " ====================="
    yellow " 6. 安装shfmt"
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
    5)
        InstallNVM
        ;;
    6)
        InstallShfmt
        ;;
    *)
        exit 0
        ;;
    esac
}
Start
