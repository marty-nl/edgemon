FROM debian:buster-slim

ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1


RUN apt-get update && apt-get -y install curl gnupg && \
    curl -sL https://packages.grafana.com/gpg.key | apt-key add - && \
    curl -sL https://repos.influxdata.com/influxdb.key | apt-key add - && \
    echo "deb https://repos.influxdata.com/debian buster stable" | tee /etc/apt/sources.list.d/influxdb.list && \
    echo "deb https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list && \
    echo "deb http://ftp.de.debian.org/debian buster main non-free" | tee /etc/apt/sources.list.d/nonfree.list && \
    apt-get update && apt-get -y install influxdb telegraf snmp snmp-mibs-downloader && \
    apt-get -y upgrade && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY snmp.conf /etc/snmp/
COPY influxdb.conf /etc/influxdb
COPY entrypoint.sh /
