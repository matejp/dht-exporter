#!/usr/bin/env bash

## Python 2:
sudo apt-get update
sudo apt-get install python-pip
sudo python -m pip install --upgrade pip setuptools wheel
sudo pip install Adafruit_DHT

# TODO: detect python version 
## Python 3:
#sudo apt-get update
#sudo apt-get install python3-pip
#sudo python3 -m pip install --upgrade pip setuptools wheel
#sudo pip3 install Adafruit_DHT

mkdir -p /opt/dht_exporter
cp dht_exporter.py /opt/dht_exporter/dht_exporter.py

cp dht_exporter.service /etc/systemd/system/dht_exporter.service

systemctl enable dht_exporter.service
