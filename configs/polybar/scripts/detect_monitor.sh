#!/bin/env bash

##
# Author : Willow P. (drizzy)
# Github : @drizzy
#
# Script - Detect monitor
##

MONITOR=$(xrandr --listmonitors | awk '/\*/ {print $2}')

export MONITOR