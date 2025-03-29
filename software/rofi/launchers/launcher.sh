#!/usr/bin/env bash

dir="$HOME/.config/rofi/launchers/"
theme='style-2'

## Run
wofi \
    -show drun \
    -theme ${dir}/${theme}.rasi
