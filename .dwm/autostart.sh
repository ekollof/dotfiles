#!/bin/sh

MONCOUNT=$(xrandr --listmonitors | sed '1 d' | awk 'NF>1{print $NF}' | wc -l)

compton --config ~/.config/compton/compton.conf &

if (( MONCOUNT > 1 ))
then
    ~/bin/wallpaper.sh -w -b ~/Wallpapers/widescreen_wallpapers
else
    ~/bin/wallpaper.sh -b ~/Wallpapers/lukesmith/Art
fi

dex -a -e dwm &
