#!/usr/bin/bash
SYNOPSIS="Usage: ${0##*/} [-h]"
echoerr() { printf "${0##*/}: %s\n" "$*" >&2; echo $SYNOPSIS; }
echohelp() {
    echo
    echo 'Save screenshot to /tmp folder.'
    echo 'Requires imagemagick, and optionally a notification daemon.'
    echo 'notify-send will be used to send the notification.'
}

case "$1" in
    "-h" | "--help" ) echo $SYNOPSIS; echohelp; exit 0 ;;
esac

if command -v notify-send >/dev/null; then
    notify-send 'select window or region' 'image will be saved to /tmp folder'
    sleep 1
    import /tmp/$(date +%F_%H%M%S_%N).png
fi
