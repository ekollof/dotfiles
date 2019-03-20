#!/bin/sh

MONCOUNT=$(xrandr --listmonitors | sed '1 d' | awk 'NF>1{print $NF}' | wc -l)

xrdb -I$HOME ~/.Xresources

compton --config ~/.config/compton/compton.conf &

urxvtd -q -o -f &

dunst &

if (( MONCOUNT > 1 ))
then
    ~/bin/wallpaper.sh -w -b ~/Wallpapers/widescreen_wallpapers
else
    ~/bin/wallpaper.sh -b ~/Wallpapers/lukesmith/Tech
fi


xscreensaver -nosplash &

dex -a -e qtile &

