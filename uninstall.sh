#!/usr/bin/env bash

fail () {
    echo "$1"
    exit $2
}

sudo systemctl stop dht_exporter.service
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error stopping dht_exporter.service"
fi

sudo systemctl disable dht_exporter.service
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error disabling dht_exporter.service"
fi

sudo rm -rf /opt/dht_exporter /etc/systemd/system/dht_exporter.service
retVal=$?
if [ $retVal -ne 0 ]; then
    fail "Error deleting /opt/dht_exporter /etc/systemd/system/dht_exporter.service" $retVal
fi

sudo systemctl daemon-reload
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error running systemctl daemon-reload"
fi

sudo systemctl reset-failed
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error running systemctl reset-failed"
fi