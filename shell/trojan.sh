#!/bin/bash
#curve 不影响已经安装的web服务器,或者想要安装自己的服务器
#仅占用本域名访问,ip或其他域名访问不影响
#如果443端口被占用,需要手动修改trojan配置文件端口
#fonts color
version=3.2

# 脚本格式化输出信息
function yellow() {
    echo -e "\033[33m\033[01m$1\033[0m"
}
function green() {
    echo -e "\033[32m\033[01m$1\033[0m"
}
function red() {
    echo -e "\033[31m\033[01m$1\033[0m"
}

# init 初始化
function init() {
    # 验证系统状态是否符合安装条件
    # CHECK=$(grep SELINUX= /etc/selinux/config | grep -v "#")
    # if [ "$CHECK" == "SELINUX=enforcing" ]; then
    #     red "======================================================================="
    #     red "检测到SELinux为开启状态，为防止申请证书失败，请先重启VPS后，再执行本脚本"
    #     red "======================================================================="
    #     read -p "是否现在重启 ?请输入 [Y/n] :" yn
    #     [ -z "${yn}" ] && yn="y"
    #     if [[ $yn == [Yy] ]]; then
    #         sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    #         setenforce 0
    #         echo -e "VPS 重启中..."
    #         reboot
    #     fi
    #     exit
    # elif [ "$CHECK" == "SELINUX=permissive" ]; then
    #     red "======================================================================="
    #     red "检测到SELinux为宽容状态，为防止申请证书失败，请先重启VPS后，再执行本脚本"
    #     red "======================================================================="
    #     read -p "是否现在重启 ?请输入 [Y/n] :" yn
    #     [ -z "${yn}" ] && yn="y"
    #     if [[ $yn == [Yy] ]]; then
    #         sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
    #         setenforce 0
    #         echo -e "VPS 重启中..."
    #         reboot
    #     fi
    #     exit
    # fi

    # 初始化包管理
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        sysPkg="yum"                      # 包管理方式
        sysPwd="/usr/lib/systemd/system/" # systemctl服务位置
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
        sysPkg="apt-get"
        sysPwd="/lib/systemd/system/"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
        sysPkg="apt-get"
        sysPwd="/lib/systemd/system/"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        sysPkg="yum"
        sysPwd="/usr/lib/systemd/system/"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
        sysPkg="apt-get"
        sysPwd="/lib/systemd/system/"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
        sysPkg="apt-get"
        sysPwd="/lib/systemd/system/"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        sysPkg="yum"
        sysPwd="/usr/lib/systemd/system/"
    fi

    # 检测系统最低可容忍版本
    # if [ "$release" == "centos" ]; then
    #     if [ -n "$(grep ' 6\.' /etc/redhat-release)" ]; then
    #         red "==============="
    #         red "当前系统不受支持"
    #         red "==============="
    #         exit
    #     fi
    #     if [ -n "$(grep ' 5\.' /etc/redhat-release)" ]; then
    #         red "==============="
    #         red "当前系统不受支持"
    #         red "==============="
    #         exit
    #     fi
    #     systemctl stop firewalld
    #     systemctl disable firewalld
    #     rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
    # elif [ "$release" == "ubuntu" ]; then
    #     if [ -n "$(grep ' 14\.' /etc/os-release)" ]; then
    #         red "==============="
    #         red "当前系统不受支持"
    #         red "==============="
    #         exit
    #     fi
    #     if [ -n "$(grep ' 12\.' /etc/os-release)" ]; then
    #         red "==============="
    #         red "当前系统不受支持"
    #         red "==============="
    #         exit
    #     fi
    #     systemctl stop ufw
    #     systemctl disable ufw
    #     apt-get update
    # fi
}

# install_dependency 安装依赖
function install_dependency() {
    green "============================="
    green "安装依赖项"
    green "============================="
    $sysPkg update && $sysPkg upgrade
    $sysPkg install -y zip tar nginx
}

# check_domain 验证域名your_name
function check_domain() {
    green "============================="
    green "请输入绑定到本VPS的域名"
    green "============================="
    read your_domain
    real_addr=$(ping ${your_domain} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
    local_addr=$(curl getip.tk)
    # 如果域名验证失败
    if [[ "$real_addr" != "$local_addr" ]]; then
        red "================================"
        red "域名解析地址与本VPS IP地址不一致"
        red "本次安装失败，请确保域名解析正常"
        red "================================"
        exit 3 # 返回码3 域名验证失败
    fi
    # 域名验证成功
    green "=========================================="
    green "域名解析正常                        "
    green "=========================================="

}

# check_port 检查端口是否占用
function check_port() {
    green "============================="
    green "请输入trojan的端口"
    green "============================="
    read your_port
    if netstat -lnp | grep $your_port; then
        red "================================"
        red "端口被占用，请切换端口"
        red "================================"
        exit 5 # 返回码5 端口被占用
    fi
}

# install_cert 安装cert证书
function install_cert() {
    #申请https证书
    mkdir -p ~/trojan-cert
    # curl https://get.acme.sh | sh -s email=wjuncurve@gmail.com
    curl https://get.acme.sh | sh -s email=i-curve@qq.com
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    ~/.acme.sh/acme.sh --issue -d $your_domain --webroot /var/www/trojan
    ~/.acme.sh/acme.sh --installcert -d $your_domain \
        --key-file ~/trojan-cert/private.key \
        --fullchain-file ~/trojan-cert/fullchain.cer \
        --reloadcmd "service nginx force-reload && service trojan restart" \
        --debug

    if [[ ! -s ~/trojan-cert/fullchain.cer ]]; then
        red "================================"
        red "https证书申请失败，本次安装失败"
        red "================================"
        rm -rf ~/trojan-cert
        exit 2 #返回码2  cert证书安装失败
    fi
    # cert证书安装成功
    green "=========================================="
    green "cert证书安装成功                       "
    green "=========================================="
}

# install_web 安装web服务
function install_web() {
    green "=========================================="
    green "安装web服务                       "
    green "=========================================="
    cat >/etc/nginx/sites-enabled/trojan <<-EOF
server {
    listen       80;
    server_name  $your_domain;
    root /var/www/trojan;
    index index.php index.html index.htm;
    location ~ \.php$ {
           include snippets/fastcgi-php.conf;
           # With php-fpm (or other unix sockets):
           fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
           # With php-cgi (or other tcp sockets):
           #fastcgi_pass 127.0.0.1:9000;
    }
}
EOF
    #伪站点,位于/var/www/trojan
    mkdir -p /var/www/trojan && cd /var/www/trojan
    # chown -R www-data /var/www/trojan && chgrp -R www-data /var/www/trojan
    wget https://github.com/i-curve/Trojan/raw/master/web.zip && unzip web.zip && rm web.zip
    service nginx restart
}

# install_trojan_client 安装trojan客户端
function install_trojan_client() {
    wget https://github.com/i-curve/Trojan/raw/master/trojan-cli.zip # 客户端
    if [[ ! $? ]]; then                                              # 如果下载失败则直接退出,返回码为3
        exit 3
    fi
    unzip trojan-cli.zip && rm -f trojan-cli.zip
    cp ~/trojan-cert/fullchain.cer /etc/trojan/trojan-cli/fullchain.cer
    trojan_passwd=$(cat /dev/urandom | head -1 | md5sum | head -c 8)
    cat >/etc/trojan/trojan-cli/config.json <<-EOF
{
    "run_type": "client",
    "local_addr": "127.0.0.1",
    "local_port": 1080,
    "remote_addr": "$your_domain",
    "remote_port": 443,
    "password": [
        "$trojan_passwd"
    ],
    "log_level": 1,
    "ssl": {
        "verify": true,
        "verify_hostname": true,
        "cert": "fullchain.cer",
        "cipher_tls13":"TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
	"sni": "",
        "alpn": [
            "h2",
            "http/1.1"
        ],
        "reuse_session": true,
        "session_ticket": false,
        "curves": ""
    },
    "tcp": {
        "no_delay": true,
        "keep_alive": true,
        "fast_open": false,
        "fast_open_qlen": 20
    }
}
EOF
}

# install_trojan_server 安装trojan服务端
function install_trojan_server() {
    #wget https://github.com/trojan-gfw/trojan/releases/download/v1.14.0/trojan-1.14.0-linux-amd64.tar.xz
    wget https://github.com/i-curve/Trojan/raw/master/trojan-1.16.0-linux-amd64.tar.xz # 服务端
    if [[ ! $? ]]; then                                                                # 如果下载失败,返回码为4
        exit 4
    fi
    tar xf trojan-1.* && rm -f trojan-1.*
    rm -rf /etc/trojan/trojan/server.conf
    cat >/etc/trojan/trojan/server.conf <<-EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": ${your_port},
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "$trojan_passwd"
    ],
    "log_level": 1,
    "ssl": {
        "cert": "/root/trojan-cert/fullchain.cer",
        "key": "/root/trojan-cert/private.key",
        "key_password": "",
        "cipher_tls13":"TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
	"prefer_server_cipher": true,
        "alpn": [
            "http/1.1"
        ],
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "no_delay": true,
        "keep_alive": true,
        "fast_open": false,
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": ""
    }
}
EOF
}

# genernate_startup 生成启动脚本
function genernate_startup() {
    cat >${sysPwd}trojan.service <<-EOF
[Unit]  
Description=trojan  
After=network.target  
   
[Service]  
Type=simple  
PIDFile=/etc/trojan/trojan/trojan.pid
ExecStart=/etc/trojan/trojan/trojan -c "/etc/trojan/trojan/server.conf"  
ExecReload=/bin/kill -HUP \$MAINPID
# Restart=on-failure
# RestartSec=1s
   
[Install]  
WantedBy=multi-user.target
EOF
    chmod +x ${sysPwd}trojan.service
    systemctl enable trojan.service && systemctl start trojan.service
}

# genernate_download 打包客户端以供下载
function genernate_download() {
    cd /etc/trojan/trojan-cli/
    zip -q -r trojan-cli.zip /etc/trojan/trojan-cli/
    trojan_path=$(cat /dev/urandom | head -1 | md5sum | head -c 16)
    mkdir /var/www/trojan/${trojan_path}
    mv /etc/trojan/trojan-cli/trojan-cli.zip /var/www/trojan/${trojan_path}/
}

# install_trojan 安装trojan
function install_trojan() {
    install_dependency # 安装依赖项
    check_domain       # 核对域名
    check_port         # 核对端口
    install_web        # 安装web服务
    if [[ "$?" = "1" ]]; then exit 1; fi
    install_cert #申请https证书
    if [[ "$?" = "2" ]]; then exit 2; fi
    #安装trojan
    mkdir -p /etc/trojan && cd /etc/trojan
    install_trojan_client # 安装trojan客户端
    install_trojan_server # 安装trojan服务端

    genernate_startup  #增加启动脚本
    genernate_download # 打包客户端以供下载

    # 安装成功
    green "======================================================================"
    green "Trojan已安装完成，请使用以下链接下载trojan客户端，此客户端已配置好所有参数"
    green "1、复制下面的链接，在浏览器打开，下载客户端"
    yellow "http://${your_domain}/$trojan_path/trojan-cli.zip"
    green "2、将下载的压缩包解压，打开文件夹，打开start.bat即打开并运行Trojan客户端"
    green "3、打开stop.bat即关闭Trojan客户端"
    green "4、Trojan客户端需要搭配浏览器插件使用，例如switchyomega等"
    green "======================================================================"
}

# remove_trojan 移除trojan
function remove_trojan() {
    red "================================"
    red "即将卸载trojan"
    red "================================"

    systemctl stop trojan && systemctl disable trojan #停止正在运行的trojan服务

    ~/.acme.sh --uninstall
    rm -rf ~/.acme.sh                      # 卸载acme
    rm -f ${sysPwd}trojan.service          # 删除trojan服务
    rm -rf /etc/trojan                     # 删除trojan文件
    rm -rf /root/trojan-cert               # 删除证书
    rm -rf /etc/nginx/sites-enabled/trojan # 删除nginx中的配置
    rm -rf /var/www/trojan                 # 删除网站
    service nginx restart                  # 重启nginx服务

    green "=============="
    green "trojan删除完毕"
    green "=============="
}

# repair_cert 修复证书过期问题
function repair_cert() {
    red "================================="
    red "即将修复证书"
    red "================================="

    install_dependency # 安装依赖项
    check_domain       # 核对域名

    mv ~/trojan-cert ~/trojan-cert.bake
    install_cert # 安装https cert证书
    if [[ "$?" = "2" ]]; then
        mv ~/trojan-cert.bake ~/trojan-cert
        exit 2 # 证书安装失败,复原环境并直接退出程序
    fi
    rm -rf ~/trojan-cert.bake

    cp ~/trojan-cert/fullchain.cer /etc/trojan/trojan-cli/fullchain.cer
    cp ~/trojan-cert/fullchain.cer /var/www/trojan/fullchain.cer
    systemctl reload nginx
    systemctl restart trojan.service

    green "================================"
    green "修复成功"
    red "================================"
}

# change_port 修改trojan端口
function change_port() {
    if [[ ! -f /etc/trojan/trojan/server.conf ]]; then
        yellow " 配置文件不存在, 请先确认是否安装trojan"
        exit 5
    fi
    green "================================="
    green "请输入你要绑定的端口:"
    read local_port
    sed -i 's/"local_port":.*/"local_port": '$local_port',/g' /etc/trojan/trojan/server.conf
    systemctl restart trojan.service
}

# start_menu 脚本入口
function start_menu() {
    init && clear # 执行脚本初始化和清屏
    green " ===================================="
    green ' Author:curve'
    green " Trojan 一键安装自动脚本      "
    green " 系统：centos7+/debian9+/ubuntu16.04+"
    green " ===================================="
    echo
    red " ===================================="
    yellow " 1. 一键安装 Trojan"
    red " ===================================="
    yellow " 2. 一键卸载 Trojan"
    red " ===================================="
    yellow " 3. 修复域名 Trojan"
    red " ===================================="
    yellow " 4. 修改端口 trojan"
    red " ===================================="
    yellow " 0. 退出脚本"
    red " ===================================="
    echo

    read -p "请输入数字:" num
    case "$num" in
    1)
        install_trojan
        ;;
    2)
        remove_trojan
        ;;
    3)
        repair_cert
        ;;
    4)
        change_port
        ;;
    0)
        exit 0
        ;;
    *)
        red "请输入正确数字"
        sleep 2s
        start_menu
        ;;
    esac
}

start_menu
