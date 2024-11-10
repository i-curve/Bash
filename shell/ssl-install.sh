#!/bin/bash

if [[ -z "$1" ]]; then
    echo "需要输入域名" && exit 0
fi
domain=$1
port=8080
if [[ -n "$2" ]]; then
    port=$2
fi

if ! which ~/.acme.sh/acme.sh; then
    curl https://get.acme.sh | sh -s email=wjuncurve@gmail.com
fi

if ! which socat; then
    apt install -y socat
fi

if which nginx; then
    service nginx stop
fi

# 申请证书
~/.acme.sh/acme.sh --issue -d "$domain" --standalone --server letsencrypt --force

# 安装证书
mkdir -p /var/www/ssl/"$domain"

~/.acme.sh/acme.sh --install-cert -d "$domain" \
    --key-file /var/www/ssl/"$domain"/private.key \
    --fullchain-file /var/www/ssl/"$domain"/fullchain.pem

if which nginx; then
    service nginx start
fi

# echo nginx config
cat >"$domain" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    root /var/www/public;
    index index.html index.htm index.nginx-debian.html;
    # rewrite ^(.*) https://\$server_name\$1 permanent;
    location / {
            try_files \$uri \$uri/ =404;
    }
}
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $domain;
    root /var/www/public;
    index index.html index.htm index.nginx-debian.html;
    ssl_certificate /var/www/ssl/$domain/fullchain.pem;
    ssl_certificate_key /var/www/ssl/$domain/private.key;
    location / {
        try_files \$uri \$uri/ =404;
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    # rewrite ^(.*) https://\$server_name\$1 permanent;
    location / { 
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass http://127.0.0.1:$port;
    } 
}
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $domain;
    ssl_certificate /var/www/ssl/$domain/fullchain.pem;
    ssl_certificate_key /var/www/ssl/$domain/private.key;
    location / {
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass http://127.0.0.1:$port;
    }
}
EOF

echo "nginx config has write to $domain"
