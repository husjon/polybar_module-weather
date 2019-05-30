#!/bin/bash

cd $(dirname $(realpath $0))

source ./config

TMP_FILE=$(mktemp)

curl --connect-timeout 1 "http://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=${UNIT}" 2>/dev/null > $TMP_FILE

TEMPERATURE=$(cat $TMP_FILE | jq '.main.temp')
TEMP_INT=$(echo "scale=0; $TEMPERATURE/1" | bc 2>/dev/null)

WEATHER=$(cat $TMP_FILE | jq '.weather[-1].main' -r)

rm $TMP_FILE

RED=$(xrdb_q color1)
GREEN=$(xrdb_q color2)
ORANGE=$(xrdb_q color3)
BLUE=$(xrdb_q color4)

case "$WEATHER" in
    "Sunny"|"Clear")
        WEATHER_ICON="";;              # https://fontawesome.com/icons/sun?style=solid
    "Rain"|"Drizzle")
        WEATHER_ICON="";;              # https://fontawesome.com/icons/cloud-rain?style=solid
    "Snow")
        WEATHER_ICON="";;              # https://fontawesome.com/icons/snowflake?style=solid
    "Clouds")
        WEATHER_ICON="";;              # https://fontawesome.com/icons/cloud?style=solid
    "Fog"|"Mist")
        WEATHER_ICON="";;              # https://fontawesome.com/icons/smog?style=solid
    "") # In case of errors
        WEATHER_ICON="%{F#$RED}";;     # https://fontawesome.com/icons/poo-storm?style=solid
    *)  # Fallback to text
        WEATHER_ICON=$WEATHER;;
esac

if (( TEMP_INT > 20 )); then
    TEMP_COLOR=${RED}
elif (( TEMP_INT >= 10 && TEMP_INT < 20 )); then
    TEMP_COLOR=${ORANGE}
elif (( TEMP_INT >= 5 && TEMP_INT < 10 )); then
    TEMP_COLOR=${GREEN}
elif (( TEMP_INT < 5 )); then
    TEMP_COLOR=${BLUE}
fi

[[ ! $TEMPERATURE ]] && TEMPERATURE="--"
echo "$WEATHER_ICON %{F#$TEMP_COLOR}$TEMPERATURE°C"
