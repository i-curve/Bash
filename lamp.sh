#!/bin/bash
# Author:curve
# 名称:初始vps网站搭建一件安装脚本 lamp
# System:Ubuntu 18.04
# 
if cat /etc/issue | grep -Eiq "debian|ubuntu";then
	echo "系统检测完成,准备安装";
else
	echo "非ubuntu系列,退出...";
	exit 1;
fi
sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get install -y wget apache2 mysql-server php7.2 php-mysql
cd /var/www
wget https://wordpress.org/latest.zip && unzip latest.zip && rm latest.zip
chown -R www-data wordpress/
chgrp -R www-data wordpress/

sed -i 's/html/wordpress/' /etc/apache2/sites-enabled/000-default.conf
service apache2 restart

mysql -uroot <<EOF
create database wordpress;
create user curve identified by 'haha123haha';
grant all privileges on wordpress.* to curve@'%';
EOF

clear
echo "全部搞定"
echo "请打开浏览器,访问本站ip,输入下面数据库的信息(也可以自己去新建)"
echo "============"
echo "数据库:wordpress"
echo "用户名:curve"
echo "密码:haha123haha"
echo
echo "如果忘记,请查看/var/www/info文件"
cat > /var/www/info << EOF
"数据库:wordpress"
"用户名:curve"
"密码:haha123haha"
EOF
