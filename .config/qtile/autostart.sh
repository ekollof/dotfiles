#!/bin/sh

xrdb -I$HOME ~/.Xresources

compton --config ~/.config/compton/compton.conf &
xscreensaver -nosplash &

(dex -a )

wallpaper.sh -w -b ~/Wallpapers/widescreen_wallpapers
urxvtd -q -o -f
dunst &
