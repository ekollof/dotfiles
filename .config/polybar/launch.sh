#!/bin/sh

MONITOR_LIST=$(xrandr --listmonitors | sed '1 d' | awk 'NF>1{print $NF}')

killall polybar 2> /dev/null

for mon in $MONITOR_LIST; do
    echo "Launching on monitor $mon"
    env MONITOR=$mon polybar topbar &
done


