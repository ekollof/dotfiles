#!/bin/sh

Xephyr :3 -ac -screen 1280x1024 -br -reset -terminate 2> /dev/null &
export DISPLAY=:3.0
sleep 2
env DISPLAY=:3.0 awesome
