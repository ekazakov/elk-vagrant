#!/bin/bash

# Functions

DATE() {
  date '+%Y-%m-%d %H:%M:%S'
}

# Variables

# Get IP
IP=`ip -o addr show up primary scope global | while read -r num dev fam addr rest; do echo [$(DATE)] [Info] [System] ${addr%/*}; done`

# Set package version
VERSION="7.5.0"

# Set provision folder
PROVISION_FOLDER="/vagrant"

# Let's go

# Update & Upgrade System
# echo "[$(DATE)] [Info] [System] Updating & Upgrading System..."
# apt update
# apt -y upgrade

# Install Java
if [ $(dpkg-query -W -f='${Status}' openjdk-8-jdk 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "[$(DATE)] [Info] [Java] Installing Java..."
  add-apt-repository -y ppa:openjdk-r/ppa
  apt update
  apt -y install openjdk-8-jdk
fi

# Install Elastic Repository
if ! grep -q "^deb .*7.x" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    echo "[$(DATE)] [Info] [System] Installing Elastic Repository..."
    wget -vO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - 
    apt -y install apt-transport-https
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
    apt update 
fi

# Install Elasticsearch
echo "[$(DATE)] [Info] [Elasticsearch] Installing Elasticsearch..."
apt -y install elasticsearch=$VERSION 

# Copy config, reload daemon and restart Elasticsearch
echo "[$(DATE)] [Info] [Elasticsearch] Copy config, reload daemon and restart Elasticsearch..."
cp -R $PROVISION_FOLDER/elasticsearch/* /etc/elasticsearch/ 
systemctl daemon-reload
systemctl enable elasticsearch 
service elasticsearch restart

# Install Kibana
echo "[$(DATE)] [Info] [Kibana] Installing Kibana..."
apt -y install kibana=$VERSION

# Copy config, reload daemon and restart Kibana
echo "[$(DATE)] [Info] [Kibana] Copy config, reload daemon and restart Kibana..."
cp -R $PROVISION_FOLDER/kibana/* /etc/kibana
systemctl daemon-reload
systemctl enable kibana
service kibana restart

# Install Logstash
echo "[$(DATE)] [Info] [Logstash] Installing Logstash..."
apt -y install logstash=1:$VERSION-1
systemctl enable logstash
 
# Beats Family

# Install Filebeat
echo "[$(DATE)] [Info] [Filebeat] Installing Filebeat..."
apt -y install filebeat=$VERSION
systemctl enable filebeat

# Install Packetbeat
echo "[$(DATE)] [Info] [Packetbeat] Installing Packetbeat..."
apt -y install libpcap0.8
apt -y install packetbeat=$VERSION
systemctl enable packetbeat

# Install Metricbeat
echo "[$(DATE)] [Info] [Metricbeat] Installing Metricbeat..."
apt -y install metricbeat=$VERSION
systemctl enable metricbeat

# Install Heartbeat
echo "[$(DATE)] [Info] [Heartbeat] Installing Heartbeat..."
apt -y install heartbeat-elastic=$VERSION
systemctl enable heartbeat-elastic

# Install Auditbeat
echo "[$(DATE)] [Info] [Auditbeat] Installing Auditbeat..."
apt -y install auditbeat=$VERSION
systemctl enable auditbeat

# Tidying Up

# Clean unneeded packages
echo "[$(DATE)] [Info] [System] Cleaning unneeded packages..."
apt -y autoremove

# Update file search cache
echo "[$(DATE)] [Info] [System] Updating file search cache..."
updatedb

# Prevent package upgrade
echo "[$(DATE)] [Info] [System] Prevent package upgrade..."
apt-mark hold elasticsearch kibana logstash filebeat packetbeat metricbeat heartbeat-elastic auditbeat

# Show IPs
echo "[$(DATE)] [Info] [System] IP Address on the machine..."
echo -e "$IP"

echo "[$(DATE)] [Info] [System] Enjoy it! :)"in/env bash

