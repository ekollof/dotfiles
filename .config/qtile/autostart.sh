#!/bin/sh

xrdb -I$HOME ~/.Xresources

compton --config ~/.config/compton/compton.conf &
xscreensaver -nosplash &

(dex -a )

wallpaper.sh -b ~/Wallpapers/lukesmith/Future
urxvtd -q -o -f
dunst &
