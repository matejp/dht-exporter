#!/usr/bin/env bash

fail () {
    echo "$1"
    exit $2
}

## Python 2:
sudo apt-get update
sudo apt-get install python-pip python-prometheus-client
retVal=$?
if [ $retVal -ne 0 ]; then
    fail "Error installing python-pip python-prometheus-client" $retVal
fi

sudo python -m pip install --upgrade pip setuptools wheel
retVal=$?
if [ $retVal -ne 0 ]; then
    fail "Error installing setuptools wheel" $retVal
fi

sudo pip install Adafruit_DHT
retVal=$?
if [ $retVal -ne 0 ]; then
    fail "Error installing Adafruit_DHT" $retVal
fi

# TODO: detect python version 
## Python 3:
#sudo apt-get update
#sudo apt-get install python3-pip python3-prometheus-client
#sudo python3 -m pip install --upgrade pip setuptools wheel
#sudo pip3 install Adafruit_DHT



read -p " Enter GPIO pin number the sensor is connected to: " GPIO_PINS
read -p " Enter room name: " ROOMS

# echo $GPIO_PINS
# echo $ROOMS

export GPIO_PINS
export ROOMS
export REFRESH_EVERY_S

cat dht_exporter.service | envsubst > /etc/systemd/system/dht_exporter.service
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error creating /etc/systemd/system/dht_exporter.service"
fi

mkdir -p /opt/dht_exporter
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error creating folder /opt/dht_exporter"
fi

cp -r dht_exporter.py /opt/dht_exporter/dht_exporter.py
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error copying to /opt/dht_exporter/dht_exporter.py"
fi

systemctl enable dht_exporter.service

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error enabling dht_exporter.service"
fi
