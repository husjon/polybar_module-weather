#!/bin/bash

CITY=""
API_KEY=""
UNIT="metric"

SUNNY=""       # https://fontawesome.com/icons/sun?style=solid
SUN_CLOUD=""   # https://fontawesome.com/icons/cloud-sun?style=solid

TEMP_C=$(curl "http://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=${UNIT}" 2>/dev/null | jq '.main.temp')

RED=$(xrdb_q color1)
ORANGE=$(xrdb_q color3)
BLUE=$(xrdb_q color4)
case "$WEATHER" in
    "clear sky")
        WEATHER=""
        ;;
    *)
        WEATHER=""
esac

echo "$WEATHER %{F#$BLUE}$TEMP_C°C"

