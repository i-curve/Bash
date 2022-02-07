FROM wjuncurve/ubuntu

EXPOSE 443 80
RUN apt-get update && apt-get install nginx -y
ADD trojan /usr/bin/
ADD config.json /root/config.json

WORKDIR /root
CMD  nginx && trojan -c /root/config.json 