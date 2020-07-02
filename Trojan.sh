#!/bin/bash

#curve 不影响已经安装的web服务器,或者想要安装自己的服务器
#仅占用本域名访问,ip或其他域名访问不影响
#fonts color
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

if [[ -f /etc/redhat-release ]]; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
fi

function install_trojan(){
CHECK=$(grep SELINUX= /etc/selinux/config | grep -v "#")
if [ "$CHECK" == "SELINUX=enforcing" ]; then
    red "======================================================================="
    red "检测到SELinux为开启状态，为防止申请证书失败，请先重启VPS后，再执行本脚本"
    red "======================================================================="
    read -p "是否现在重启 ?请输入 [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
	    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
            setenforce 0
	    echo -e "VPS 重启中..."
	    reboot
	fi
    exit
fi
if [ "$CHECK" == "SELINUX=permissive" ]; then
    red "======================================================================="
    red "检测到SELinux为宽容状态，为防止申请证书失败，请先重启VPS后，再执行本脚本"
    red "======================================================================="
    read -p "是否现在重启 ?请输入 [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
	    sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
            setenforce 0
	    echo -e "VPS 重启中..."
	    reboot
	fi
    exit
fi
if [ "$release" == "centos" ]; then
    if  [ -n "$(grep ' 6\.' /etc/redhat-release)" ] ;then
    red "==============="
    red "当前系统不受支持"
    red "==============="
    exit
    fi
    if  [ -n "$(grep ' 5\.' /etc/redhat-release)" ] ;then
    red "==============="
    red "当前系统不受支持"
    red "==============="
    exit
    fi
    systemctl stop firewalld
    systemctl disable firewalld
    rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
elif [ "$release" == "ubuntu" ]; then
    if  [ -n "$(grep ' 14\.' /etc/os-release)" ] ;then
    red "==============="
    red "当前系统不受支持"
    red "==============="
    exit
    fi
    if  [ -n "$(grep ' 12\.' /etc/os-release)" ] ;then
    red "==============="
    red "当前系统不受支持"
    red "==============="
    exit
    fi
    systemctl stop ufw
    systemctl disable ufw
    apt-get update
fi
#$systemPackage -y install  nginx wget unzip zip curl tar >/dev/null 2>&1
#systemctl enable nginx.service
apt-get install -y zip tar
green "======================="
yellow "请输入绑定到本VPS的域名"
green "======================="
read your_domain
real_addr=`ping ${your_domain} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`
local_addr=`curl ipv4.icanhazip.com`
if [ $real_addr == $local_addr ] ; then
	green "=========================================="
	green "       域名解析正常，开始安装trojan"
	green "=========================================="
	sleep 1s
cat > /etc/nginx/sites-enabled/trojan <<-EOF
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
mkdir /var/www/trojan && cd /var/www/trojan
wget https://github.com/i-curve/Trojan/raw/master/web.zip && unzip web.zip && rm web.zip
service nginx restart
	#申请https证书
	mkdir ~/trojan-cert && mkdir /etc/trojan
	curl https://get.acme.sh | sh
	~/.acme.sh/acme.sh  --issue  -d $your_domain  --webroot /var/www/trojan
    	~/.acme.sh/acme.sh  --installcert  -d  $your_domain   \
        --key-file   ~/trojan-cert/private.key \
        --fullchain-file ~/trojan-cert/fullchain.cer \
        --reloadcmd  "systemctl force-reload  nginx.service"
	if test -s ~/trojan-cert/fullchain.cer; then
        cd /etc/trojan
	#wget https://github.com/trojan-gfw/trojan/releases/download/v1.14.0/trojan-1.14.0-linux-amd64.tar.xz
    wget https://github.com/i-curve/Trojan/raw/master/trojan-1.14.0-linux-amd64.tar.xz
	tar xf trojan-1.* && rm -f trojan-1.*
	#下载trojan客户端
    wget https://github.com/i-curve/Trojan/raw/master/trojan-cli.zip
	unzip trojan-cli.zip && rm -f trojan-cli.zip
	cp ~/trojan-cert/fullchain.cer /etc/trojan/trojan-cli/fullchain.cer
	trojan_passwd=$(cat /dev/urandom | head -1 | md5sum | head -c 8)
	cat > /etc/trojan/trojan-cli/config.json <<-EOF
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
	rm -rf /etc/trojan/trojan/server.conf
	cat > /etc/trojan/trojan/server.conf <<-EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
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
	cd /etc/trojan/trojan-cli/
	zip -q -r trojan-cli.zip /etc/trojan/trojan-cli/
	trojan_path=$(cat /dev/urandom | head -1 | md5sum | head -c 16)
	mkdir /var/www/html/${trojan_path}
	mv /etc/trojan/trojan-cli/trojan-cli.zip /var/www/trojan/${trojan_path}/
	#增加启动脚本
	
cat > ${systempwd}trojan.service <<-EOF
[Unit]  
Description=trojan  
After=network.target  
   
[Service]  
Type=simple  
PIDFile=/etc/trojan/trojan/trojan.pid
ExecStart=/etc/trojan/trojan/trojan -c "/etc/trojan/trojan/server.conf"  
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=1s
   
[Install]  
WantedBy=multi-user.target
EOF

	chmod +x ${systempwd}trojan.service
	systemctl start trojan.service
	systemctl enable trojan.service
	green "======================================================================"
	green "Trojan已安装完成，请使用以下链接下载trojan客户端，此客户端已配置好所有参数"
	green "1、复制下面的链接，在浏览器打开，下载客户端"
	yellow "http://${your_domain}/$trojan_path/trojan-cli.zip"
	red "请记录下面规则网址"
	yellow "http://${your_domain}/trojan.txt"
	green "2、将下载的压缩包解压，打开文件夹，打开start.bat即打开并运行Trojan客户端"
	green "3、打开stop.bat即关闭Trojan客户端"
	green "4、Trojan客户端需要搭配浏览器插件使用，例如switchyomega等"
	green "访问  https://www.v2rayssr.com/trojan-1.html ‎ 下载 浏览器插件 及教程"
	green "======================================================================"
	else
        red "================================"
	red "https证书没有申请成功，本次安装失败"
	red "================================"
	fi
	
else
	red "================================"
	red "域名解析地址与本VPS IP地址不一致"
	red "本次安装失败，请确保域名解析正常"
	red "================================"
fi
}

function remove_trojan(){
    red "================================"
    red "即将卸载trojan"
    red "================================"
    sleep 1
    systemctl stop trojan
    systemctl disable trojan
    rm -f ${systempwd}trojan.service
    rm -rf /etc/trojan
    rm -rf /root/trojan-cert
    rm -rf /etc/nginx/sites-enabled/trojan
    rm -rf /var/www/trojan
    service nginx restart
    green "=============="
    green "trojan删除完毕"
    green "=============="
}
function repair_cert(){
    red "================================="
    red "即将修复证书"
    red "================================="
apt-get install -y zip tar
green "============================="
yellow "请输入绑定到本VPS的域名"
green "============================="
read your_domain
real_addr=`ping ${your_domain} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`
local_addr=`curl getip.tk`
if [ $real_addr == $local_addr ];then
	green "=========================================="
	green "       域名解析正常，开始安装trojan"
	green "=========================================="
	sleep 1s
    mv ~/trojan-cert ~/trojan-cert.bake
	#申请https证书
	mkdir ~/trojan-cert && mkdir /etc/trojan
	curl https://get.acme.sh | sh
	~/.acme.sh/acme.sh  --issue  -d $your_domain  --webroot /var/www/trojan
    	~/.acme.sh/acme.sh  --installcert  -d  $your_domain   \
        --key-file   ~/trojan-cert/private.key \
        --fullchain-file ~/trojan-cert/fullchain.cer \
        --reloadcmd  "systemctl force-reload  nginx.service"
    if test -s ~/trojan-cert/fullchain.cer; then
    cp ~/trojan-cert/fullchain.cer /etc/trojan/trojan-cli/fullchain.cer
    systemctl reload nginx
    systemctl stop trojan.service
    systemctl start trojan.service
    rm -rf ~/trojan-cert.bake
    red "================================"
    red "安装成功"
    red "================================"
    else
    red "================================"
	red "https证书没有申请成功，本次安装失败"
	red "================================" 
    rm -rf ~/trojan-cert 
    mv ~/trojan-cert.bake ~/trojan-cert
    fi
else
	red "================================"
	red "域名解析地址与本VPS IP地址不一致"
	red "本次安装失败，请确保域名解析正常"
	red "================================"
fi
}
start_menu(){
    clear
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
    yellow " 3. 一件修复 Trojan"
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
    0)
    exit 1
    ;;
    *)
    clear
    red "请输入正确数字"
    sleep 1s
    start_menu
    ;;
    esac
}

start_menu