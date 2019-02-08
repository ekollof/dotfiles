#!/bin/sh

xrdb -I$HOME ~/.Xresources

compton --config ~/.config/compton/compton.conf &

(dex -a -e i3)

feh --randomize --bg-scale ~/.config/qtile/wallpapers/*/*
urxvtd -q -o -f
dunst &
