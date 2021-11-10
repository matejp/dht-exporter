#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse

# import random
import time
import board
import adafruit_dht
from prometheus_client import start_http_server, Gauge


class Dht_exporter:
    def __init__(self, gpio_pin, room, debug_on):
        # Create a metric to track time spent and requests made.
        self.g_temperature = Gauge(
            "dht_temperature",
            "Temperature in celsius provided by dht sensor",
            ["room"],
        )
        self.g_humidity = Gauge(
            "dht_humidity",
            "Humidity in percents provided by dht sensor",
            ["room"],
        )
        gpio_list = {
            1: board.D1,
            2: board.D2,
            3: board.D3,
            4: board.D4,
            5: board.D5,
            6: board.D6,
            7: board.D7,
            8: board.D8,
            9: board.D9,
            10: board.D10,
            11: board.D11,
            12: board.D12,
            13: board.D13,
            14: board.D14,
            15: board.D15,
            16: board.D16,
            17: board.D17,
            18: board.D18,
            19: board.D19,
            20: board.D20,
            21: board.D21,
            22: board.D22,
            23: board.D23,
            24: board.D24,
            25: board.D25,
            26: board.D26,
            27: board.D27,
        }

        self.gpio = gpio_list[gpio_pin]
        self.room = room
        self.debug_on = debug_on

    def get_sensor_data(self):
        """get sensor data from gpio pin"""
        dht = adafruit_dht.DHT22(self.gpio, use_pulseio=False)

        try_count = 0
        while try_count < 5:
            try_count += 1
            try:
                temperature = dht.temperature
                humidity = dht.humidity
                if temperature is None:
                    if self.debug_on:
                        print("Temparature: None")
                    time.sleep(1)
                    continue
                if humidity is None:
                    if self.debug_on:
                        print("Humidity: None")
                    time.sleep(1)
                    continue
                break
            except RuntimeError as e:
                # Reading doesn't always work! Just print error and we'll try again
                if self.debug_on:
                    print("DHT failure: ", e.args)
            time.sleep(1)

        return (humidity, temperature)

    def update_sensor_data(self):
        """Update prometheus metrics data"""

        humidity, temperature = self.get_sensor_data()

        # Print what we got
        if self.debug_on:
            print(
                "Temp: {:.1f} *C \t Humidity: {}%".format(
                    temperature, humidity
                )
            )
        if (
            abs(temperature) < 100
        ):  # If sensor returns weird value ignore it and wait for the next one
            self.g_temperature.labels(self.room).set(
                "{0:0.1f}".format(temperature)
            )

        if (
            abs(humidity) < 100
        ):  # If sensor returns weird value ignore it and wait for the next one
            self.g_humidity.labels(self.room).set("{0:0.1f}".format(humidity))


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
        help="Set GPIO pin id to listen for DHT sensor data.",
        required=True,
    )
    parser.add_argument(
        "-r",
        "--room",
        type=str,
        help="Set room name.",
        required=True,
    )
    parser.add_argument(
        "-P",
        "--port",
        type=int,
        default=8001,
        help="Set the port number where the data is exposed.",
    )
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Turn on debug.",
    )
    cli_arguments = parser.parse_args()

    # Start up the server to expose the metrics.
    start_http_server(cli_arguments.port)

    exporter = Dht_exporter(
        cli_arguments.gpio, cli_arguments.room, cli_arguments.debug
    )

    # Update temperature and humidity prometheus metrics
    while True:
        exporter.update_sensor_data()
        time.sleep(cli_arguments.pull_time)
