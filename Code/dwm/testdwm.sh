#!/bin/sh

Xephyr :3 -ac -screen 1280x1024 -br -reset -terminate 2> /dev/null &
export DISPLAY=:3.0
sleep 2

touch .restart
while true; do
    if [ ! -x .restart ]; then
        env DISPLAY=:3.0 ./dwm
    fi
done
rm .restart
