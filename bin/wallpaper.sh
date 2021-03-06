#!/usr/bin/env bash

usage() {
	cat << EOF
Selects a random wallpaper from a folder and also runs pywal on it.
Requires feh and pywal.

Usage:
	$0 -w -b <path>

	-w	widescreen
	-b	path to wallpapers
EOF
}

reload_gtk() {
  theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
  icons=$(gsettings get org.gnome.desktop.interface icon-theme)
  gsettings set org.gnome.desktop.interface gtk-theme ''
  gsettings set org.gnome.desktop.interface icon-theme ''
  sleep 1
  gsettings set org.gnome.desktop.interface gtk-theme "$theme"
  gsettings set org.gnome.desktop.interface icon-theme "$icons"
}


WIDESCREEN=0
while getopts ":hwb:" opt; do
	case $opt in
		h)
			usage
			exit 0
			;;
		b)
            echo "Using ${OPTARG}"
			WALLDIR=$OPTARG
			;;
		w)
			WIDESCREEN=1
			;;
        :)
            usage
            ;;
	esac
done

if [ -z "${WALLDIR}" ]; then
    echo "Can't find wallpaper."
	usage
	exit 1
fi


BG="$(find ${WALLDIR} | shuf -n 1)"

if [ ${WIDESCREEN} == 1 ]; then
	feh --bg-fill --no-xinerama "$BG"
else
	feh --bg-scale --randomize "$WALLDIR"
fi

echo $BG >> ~/.wallpaper

## Set colors
wal --backend wal -n -i "$BG" -a "60" --saturate 1.0 --vte
## Set widget colors
oomox-cli /home/ekollof/.cache/wal/colors-oomox
oomox-gnome-colors-icons-cli ~/.config/oomox/colors/wal
sleep 1
reload_gtk
