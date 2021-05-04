#!/usr/bin/env python

import json
import os
import pathlib
import time

import requests

def error(msg=''):
    print('%{F#ff0000}', msg)
    exit(0)


def load_config():
    try:
        with open(BASEDIR / 'config.json', 'r') as fh:
            return json.load(fh)
    except FileNotFoundError:
        error('Config missing')
    except json.decoder.JSONDecodeError:
        error('Config invalid')


def weather_icon(string):
    """ Returns an icon representing the current weather """
    if string in ["Sunny", "Clear"]:
        icon = ""          # https://fontawesome.com/icons/sun?style=solid
    elif string in ["Rain", "Drizzle"]:
        icon = ""          # https://fontawesome.com/icons/cloud-rain?style=solid
    elif string in ["Snow"]:
        icon = ""          # https://fontawesome.com/icons/snowflake?style=solid
    elif string in ["Clouds"]:
        icon = ""          # https://fontawesome.com/icons/cloud?style=solid
    elif string in ["Fog", "Mist"]:
        icon = ""          # https://fontawesome.com/icons/smog?style=solid
    elif string in [""]:  # In case of errors
        icon = "%{F#$RED}" # https://fontawesome.com/icons/poo-storm?style=solid
    else:
        icon = string

    return icon


def temperature_color(temperature):
    """ Returns an hex color for the current temperature """
    threshold = CONFIG['threshold']
    if temperature > threshold['high']['value']:
        color = threshold['high']['color']
    elif temperature > threshold['normal']['value']:
        color = threshold['normal']['color']
    elif temperature > threshold['low']['value']:
        color = threshold['low']['color']
    else:
        color = threshold['cold']['color']

    return color


def temperature_unit(unit):
    """ Returns string representing the current temperature unit """
    if unit == 'metric':
        _unit = 'C'
    elif unit == 'imperial':
        _unit = 'F'
    elif unit in ['kelvin', 'default']:
        _unit = 'K'
    return _unit


def fetch_weather_data():
    """ Fetches weather data from Open Weather Maps """
    weather_cache_file = BASEDIR / 'cache.json'

    weather_data = None
    if os.path.exists(weather_cache_file):
        if time.time() - os.path.getmtime(weather_cache_file) < 60:
            with open(weather_cache_file, 'r') as fh:
                weather_data = json.load(fh)

    if not weather_data:
        result = requests.get(API_URL)

        if result.status_code == 200:
            weather_data = json.loads(result.content)
            with open(weather_cache_file, 'w+') as fh:
                json.dump(weather_data, fh)
        else:
            error('No weather')

    weather = weather_data['weather'][-1]['main']
    temperature = round(weather_data['main']['temp'], 1)
    color = '%{{F{}}}'.format(temperature_color(temperature=temperature))

    return {
        "icon": weather_icon(string=weather),
        "color": color,
        "temperature": temperature,
        "unit": temperature_unit(unit=CONFIG['temperature_unit']),
    }


BASEDIR = pathlib.Path(os.path.dirname(os.path.realpath(__file__)))
CONFIG = load_config()
API_URL = (
    "http://api.openweathermap.org/data/2.5/weather"
    "?q={city}&appid={api_key}&units={temperature_unit}"
).format(**CONFIG)


if __name__ == "__main__":
    try:
        DATA = fetch_weather_data()
        print('{icon} {color}{temperature}°{unit}'.format(**DATA))
    except Exception as e:  # pylint: disable=broad-except
        error(f'Error: {e}')  # https://fontawesome.com/icons/poo-storm?style=solid
