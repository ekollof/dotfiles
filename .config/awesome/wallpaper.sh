#!/bin/bash

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

WIDESCREEN=0
options=$(getopt -o "hwb:" -a -- "$@")
eval set -- "$options"

while true; do
	case $1 in
		-h)
			usage
			exit 0
			;;
		-b)
			shift
			WALLDIR="$1"
			;;
		-w)
			WIDESCREEN=1
			;;
		--)
			shift
			break;;
	esac
	shift
done

if [ -z "${WALLDIR}" ]; then
	usage
	exit 1
fi


BG="${WALLDIR}/$(ls -1 ${WALLDIR} | shuf -n 1)"

if [ ${WIDESCREEN} == 1 ]; then
	feh --bg-fill --no-xinerama  "$BG"
else
	feh --bg-scale "$BG"
fi

# Set colors
wal -i "$BG"  --saturate 1 -a "75"
# Set widget colors
oomox-cli /home/ekollof/.cache/wal/colors-oomox
oomox-gnome-colors-icons-cli ~/.config/oomox/colors/wal
