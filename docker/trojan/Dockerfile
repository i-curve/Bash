FROM nginx:latest

EXPOSE 443 80

# COPY html /usr/share/nginx/html
# COPY trojan /root/trojan

RUN apt update && apt install -y zip tar wget

RUN wget https://github.com/i-curve/storage-room/releases/download/trojan/trojan-web.zip
RUN unzip -o -d /usr/share/nginx/html trojan-web.zip && rm trojan-web.zip

RUN wget https://github.com/i-curve/storage-room/releases/download/trojan/trojan-server.tar.xz 
RUN tar -xf trojan-server.tar.xz -C /root/ && rm trojan-server.tar.xz

COPY start.sh /root/trojan/

WORKDIR /root/trojan

CMD  nginx && bash start.sh