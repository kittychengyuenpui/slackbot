#!/bin/bash

export HUBOT_OWM_APIKEY="5a4bf46269c387d2d639f0a7a960b3f1";
export HUBOT_WEATHER_UNITS="metric";
export HUBOT_WEATHER_API_URL="http://api.openweathermap.org/data/2.5/weather";

HUBOT_SLACK_TOKEN=xoxb-829042009157-887106699494-06sPcDTe4E5zKhlfkAEeGowy ./bin/hubot --adapter slack