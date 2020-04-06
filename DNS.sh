#!/bin/bash
#curve
#安装dns服务器
apt-get update
apt-get -y upgrade
apt-get install -y bind9

cd /etc/bind/
cat > m.txt <<EOF
forwarders{
	223.5.5.5;
	223.6.6.6;
	8.8.8.8;
	8.8.4.4;
};
listen-on port 53 {any;};
allow-query {any;}; 
EOF
sed -i '16r m.txt' named.conf.options
sed -i 's/dnssec-validation auto/dnssec-validation no/' named.conf.options
rm m.txt
service bind9 restart
