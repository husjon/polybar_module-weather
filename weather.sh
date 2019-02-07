#!/bin/bash

cd $(dirname $(realpath $0))

source ./config

TMP_FILE=$(mktemp)

curl "http://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=${UNIT}" 2>/dev/null > $TMP_FILE

TEMPERATURE=$(cat $TMP_FILE | jq '.main.temp')
TEMP_INT=$(echo "scale=0; $TEMPERATURE/1" | bc 2>/dev/null)

WEATHER=$(cat $TMP_FILE | jq '.weather[-1].main' -r)

RED=$(xrdb_q color1)
ORANGE=$(xrdb_q color3)
BLUE=$(xrdb_q color4)

case "$WEATHER" in
    "Sunny")
        WEATHER_ICON="";;  # https://fontawesome.com/icons/sun?style=solid
    "Rain")
        WEATHER_ICON="";;  # https://fontawesome.com/icons/sun?style=solid
    "Snow")
        WEATHER_ICON="";;
    "Clouds")
        WEATHER_ICON="";;
    "")
        WEATHER_ICON="%{F#$RED}";;
    *)
        WEATHER_ICON=$WEATHER;;
esac

if (( TEMP_INT > 15 )); then
    TEMP_COLOR=${RED}
elif (( TEMP_INT > -5 && TEMP_INT < 15 )); then
    TEMP_COLOR=${ORANGE}
else
    TEMP_COLOR=${BLUE}
fi

[[ ! $TEMPERATURE ]] && TEMPERATURE="--"
echo "$WEATHER_ICON %{F#$TEMP_COLOR}$TEMPERATURE°C"

rm $TMP_FILE
