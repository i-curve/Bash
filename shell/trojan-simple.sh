#!/bin/bash
## bash
# @Author: i-curve
# @Date: 2023-12-11 22:53:13
# @Last Modified by: i-curve
# @Name:
##
set -e

source "$(dirname $0)/../util/util.sh"
source "$(dirname $0)/../util/data.sh"

InitEnvironment

function install_dependency() { # install_dependency 安装依赖
    green "安装依赖项"
    $systemPackage update && $systemPackage upgrade
    $systemPackage install -y zip tar nginx
}

function check_domain() { # check_domain 验证域名
    green "请输入绑定到本VPS的域名" && read your_domain
    real_addr=$(ping ${your_domain} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')

    local_addr=$(curl getip.cc)
    if [[ "$real_addr" != "$local_addr" ]]; then # 如果域名验证失败
        ErrorExit 3 "域名验证失败,域名解析地址与本VPS IP地址不一致"
    fi
    green "域名解析正常" # 域名验证成功
}

function check_port() { # check_port 检查端口是否占用
    green "请输入trojan的端口" && read your_port
    if netstat -lnp | grep $your_port; then
        ErrorExit 5 "端口被占用，请切换端口"
    fi
}

function install_web() { # install_web 安装web服务
    green "安装web服务..."
    cat >/etc/nginx/sites-enabled/trojan <<-EOF
server {
    listen       80;
    server_name  $your_domain;
    root /var/www/trojan;
    index index.html index.htm;
}
EOF
    mkdir -p /var/www/trojan && cd /var/www/trojan
    wget ${TrojanWeb} && unzip trojan-web.zip && rm trojan-web.zip
    service nginx restart
}

function install_trojan_server() { # install_trojan_server 安装trojan服务端
    green "安装 trojan 服务端..."
    wget ${TrojanServer} || ErrorExit 4 "trojan服务端下载失败"
    tar xf trojan-* && rm -rf trojan-server.*

    trojan_passwd=$(cat /dev/urandom | head -1 | md5sum | head -c 12)
    sed -i 's/443/'${your_port}'/;s/your_passwd/'${trojan_passwd}'/' /etc/trojan/trojan/server.json

    cat >${sysPwd}/trojan.service <<-EOF
[Unit]  
Description=trojan  
After=network.target  
   
[Service]  
Type=simple  
PIDFile=/etc/trojan/trojan/trojan.pid
ExecStart=/etc/trojan/trojan/trojan -c "/etc/trojan/trojan/server.json"  
ExecReload=/bin/kill -HUP \$MAINPID
# Restart=on-failure
# RestartSec=1s
   
[Install]  
WantedBy=multi-user.target
EOF
    chmod +x ${sysPwd}/trojan.service
    systemctl enable trojan.service
}

function install_trojan() { # install_trojan 安装trojan

    install_dependency # 安装依赖项
    check_domain       # 核对域名
    check_port         # 核对端口
    install_web        # 安装web服务

    mkdir -p /etc/trojan && cd /etc/trojan && install_trojan_server # 安装trojan服务端

    green "服务端安装成功, 稍后进入配置"
    sleep 3
    clear
    yellow "把证书复制到/root/trojan-cert目录下: 并分别重命名为private.key, fullcahin.cer"
    yellow "然后运行 systemctl start trojan.service"
    green "复制trojan链接:"
    yellow "trojan://${trojan_passwd}@${your_domain}:${your_port}?security=tls&type=tcp&headerType=none#trojan"
}

function remove_trojan() { # remove_trojan 移除trojan
    red "正在卸载trojan..."
    systemctl stop trojan.service
    systemctl disable trojan.service       #停止正在运行的trojan服务
    rm -rf ${sysPwd}/trojan.service        # 删除trojan服务
    rm -rf /etc/trojan                     # 删除trojan文件
    rm -rf /etc/nginx/sites-enabled/trojan # 删除nginx中的配置
    rm -rf /var/www/trojan                 # 删除网站
    service nginx restart                  # 重启nginx服务

    green "trojan 卸载完毕"
}

function change_port() { # change_port 修改trojan端口
    if [[ ! -f /etc/trojan/trojan/server.json ]]; then
        ErrorExit 5 "配置文件不存在, 请先确认是否安装trojan"
    fi
    green "请输入你要绑定的端口:"
    read local_port
    sed -i 's/"local_port":.*/"local_port": '$local_port',/g' /etc/trojan/trojan/server.json
    systemctl restart trojan.service && green "端口修改成功"
}

function change_passwd() { # 修改密码
    if [[ ! -f /etc/trojan/trojan/server.json ]]; then
        ErrorExit 5 "配置文件不存在, 请先确认是否安装trojan"
    fi
    green "请输入你的新密码:"
    read local_passwd
    sed -i 's/"password":.*/"password": ["'$local_passwd'"],/g' /etc/trojan/trojan/server.json
    systemctl restart trojan.service && green "密码修改成功"
}

function start_menu() { # start_menu 脚本入口
    UtilEchoHead "Trojan 一键安装自动脚本"
    echo
    red " ===================================="
    yellow " 1. 安装 Trojan"
    red " ===================================="
    yellow " 2. 卸载 Trojan"
    red " ===================================="
    yellow " 3. 修改端口"
    red " ===================================="
    yellow " 4. 修改密码"
    red " ===================================="
    yellow " 0. 退出脚本"
    red " ===================================="
    echo && read -p "请输入数字:" num
    case "$num" in
    1)
        install_trojan
        ;;
    2)
        remove_trojan
        ;;
    3)
        change_port
        ;;
    4)
        change_passwd
        ;;
    *)
        exit 0
        ;;
    esac
}

start_menu
