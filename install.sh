#!/usr/bin/env bash

fail () {
    echo "$1"
    exit $2
}

sudo apt-get update
retVal=$?
if [ $retVal -ne 0 ]; then
    fail "Error running: sudo apt-get update" $retVal
fi

sudo apt install python3-pip libgpiod2
retVal=$?
if [ $retVal -ne 0 ]; then
    fail "Error installing setuptools wheel" $retVal
fi

sudo python3 -m pip install --upgrade pip setuptools wheel
retVal=$?
if [ $retVal -ne 0 ]; then
    fail "Error installing setuptools wheel" $retVal
fi

sudo python3 -m pip install -r requirements.txt
retVal=$?
if [ $retVal -ne 0 ]; then
    fail "Error running: pip3 install -r requirements.txt" $retVal
fi

read -p " Enter GPIO pin number the sensor is connected to [4]: " GPIO_PINS
GPIO_PINS=${GPIO_PINS:-4}

while [ -z "$ROOMS" ]; do
    read -p " Enter room name: " ROOMS
done

read -p " Enter exporter port name [8001]: " PORT
PORT=${PORT:-8001}

# Check if port is in use
exec 6<>/dev/tcp/127.0.0.1/$PORT || echo "No one is listening on port $PORT!"
exec 6>&- # close output connection
exec 6<&- # close input connection


read -p " Pull sensor data every X seconds [20]: " PULLTIME
PULLTIME=${PULLTIME:-20}

export GPIO_PINS
export ROOMS
export PORT
export PULLTIME

cat dht_exporter.service | envsubst | sudo tee /etc/systemd/system/dht_exporter.service
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error creating /etc/systemd/system/dht_exporter.service"
fi

sudo mkdir -p /opt/dht_exporter
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error creating folder /opt/dht_exporter"
fi

sudo cp -r dht_exporter.py /opt/dht_exporter/dht_exporter.py
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error copying to /opt/dht_exporter/dht_exporter.py"
fi

sudo systemctl enable dht_exporter.service
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error enabling dht_exporter.service"
fi

sudo systemctl start dht_exporter.service
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error starting dht_exporter.service"
fi
