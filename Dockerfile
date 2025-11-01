FROM eclipse-temurin:25-jre-alpine
RUN apt-get update && apt-get install -y wget unzip curl iputils-ping dnsutils
WORKDIR /minecraft
COPY entrypoint.sh /entrypoint.sh
RUN apt-get update && apt-get install -y tinyproxy
RUN echo "Allow 127.0.0.1" >> /etc/tinyproxy/tinyproxy.conf
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
