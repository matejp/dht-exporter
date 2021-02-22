#!/usr/bin/env bash

fail () {
    echo "$1"
    exit $2
}

## Python 2:
sudo apt-get update
sudo apt-get install python-pip
retVal=$?
if [ $retVal -ne 0 ]; then
    fail "Error installing python-pip" $retVal
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

sudo pip install paho-mqtt
retVal=$?
if [ $retVal -ne 0 ]; then
    fail "Error installing paho-mqtt" $retVal
fi

# TODO: detect python version 
## Python 3:
#sudo apt-get update
#sudo apt-get install python3-pip python3-prometheus-client
#sudo python3 -m pip install --upgrade pip setuptools wheel
#sudo pip3 install Adafruit_DHT



read -p " Enter GPIO pin number the sensor is connected to: " GPIO_PINS
read -p " Enter room name: " ROOMS

read -p " Refresh every this many seconds: " REFRESH_EVERY_S
read -p " Enter MQTT server IP: " MQTT_IP
read -p " Enter MQTT server Port: " MQTT_PORT
read -p " Enter Prefix for MQTT subject: " MQTT_PREFIX

# echo $GPIO_PINS
# echo $ROOMS

export GPIO_PINS
export ROOMS
export REFRESH_EVERY_S
export MQTT_IP
export MQTT_PORT
export MQTT_PREFIX

cat dht_to_mqtt.service | envsubst | sudo tee /etc/systemd/system/dht_to_mqtt.service
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error creating /etc/systemd/system/dht_to_mqtt.service"
fi

sudo mkdir -p /opt/dht_exporter
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error creating folder /opt/dht_exporter"
fi

sudo cp -r dht_to_mqtt.py /opt/dht_exporter/dht_to_mqtt.py
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error copying to /opt/dht_exporter/dht_to_mqtt.py"
fi

sudo systemctl enable dht_to_mqtt.service

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error enabling dht_to_mqtt.service"
fi
