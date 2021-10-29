#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse

# import random
import time
import Adafruit_DHT
import paho.mqtt.client as mqtt

# generate client ID with pub prefix randomly
# client_id = f'rpi-dht-mqtt-{random.randint(0, 1000)}'
# username = 'emqx'
# password = 'public'


def connect_mqtt(broker, port, client_id):
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Connected to MQTT Broker!")
        else:
            print("Failed to connect, return code {code}".format(code=rc))

    client = mqtt.Client(client_id)
    client.on_connect = on_connect
    client.connect(broker, port)
    return client


def publish_to_mqtt(mqtt_client, topic, value):
    result = mqtt_client.publish(topic, value)
    # result: [0, 1]

    status = result[0]
    if status == 0:
        print("Send {value} to topic {topic}".format(value=value, topic=topic))
    else:
        print(
            "Failed to send message to topic {topic}: {result}".format(
                topic=topic, result=result
            )
        )


def get_sensor_data(gpio_pin):
    """Get sensor data from gpio pin provided in the argument"""
    humid, temp = Adafruit_DHT.read_retry(Adafruit_DHT.AM2302, gpio_pin)
    humidity, temperature = (None, None)

    if humid is not None:
        if (
            abs(humid) < 100
        ):  # If sensor returns veird value ignore it and wait for the next one
            humidity = "{0:0.1f}".format(humid)

    if temp is not None:
        if (
            abs(temp) < 100
        ):  # If sensor returns veird value ignore it and wait for the next one
            temperature = "{0:0.1f}".format(temp)

    print(
        "humidity: {humidity}, temp: {temp}".format(
            humidity=humidity, temp=temperature
        )
    )
    return (humidity, temperature)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-p",
        "--pull_time",
        type=int,
        default=5,
        help="Pull sensor data every X seconds.",
    )
    parser.add_argument(
        "-g",
        "--gpio",
        type=int,
        nargs="+",
        help="Set GPIO pin id to listen for DHT sensor data.",
        required=True,
    )
    parser.add_argument(
        "-r",
        "--room",
        type=str,
        nargs="+",
        help="Set room name.",
        required=True,
    )
    parser.add_argument(
        "-m",
        "--mqtt",
        type=str,
        default="",
        help="Send data to MQTT server at this address.",
    )
    parser.add_argument(
        "-mp", "--mqtt_port", type=int, default=1883, help="MQTT port"
    )
    parser.add_argument(
        "-t",
        "--topic_prefix",
        type=str,
        default="",
        help="Send data to this MQTT topic prefix (<prefix>-temp, <prefix>-humid).",
    )
    cli_arguments = parser.parse_args()

    if len(cli_arguments.gpio) != len(cli_arguments.room):
        print(
            "The number of gpio pins set needs to be the same as number of rooms set"
            "\n Number of gpio pins: {g}\n Number of rooms: {r}".format(
                g=len(cli_arguments.gpio), r=len(cli_arguments.room)
            )
        )
        exit(1)

    if cli_arguments.topic_prefix != "":
        mqtt_client = connect_mqtt(
            cli_arguments.mqtt,
            cli_arguments.mqtt_port,
            "-".join((cli_arguments.topic_prefix, cli_arguments.room[0])),
        )

    # Update temperature and humidity
    while True:
        for id, gpio_pin in enumerate(cli_arguments.gpio):
            print(gpio_pin)
            humidity, temperature = get_sensor_data(gpio_pin)

            if cli_arguments.topic_prefix != "":
                publish_to_mqtt(
                    mqtt_client,
                    "/".join(
                        (
                            cli_arguments.topic_prefix,
                            cli_arguments.room[id],
                            "temperature",
                        )
                    ),
                    temperature,
                )
                publish_to_mqtt(
                    mqtt_client,
                    "/".join(
                        (
                            cli_arguments.topic_prefix,
                            cli_arguments.room[id],
                            "humidity",
                        )
                    ),
                    humidity,
                )
        time.sleep(cli_arguments.pull_time)


# dht_exporter.py -p 60 -g 4 -r 'balkon' -m x.y.z.w -mp 1883 -t dht_sensor

# dht_sensor/balkon/temperature
# dht_sensor/balkon/humidity
