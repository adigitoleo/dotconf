#!/usr/bin/env bash
SYNOPSIS="Usage: ${0##*/} [-h] WINDOW_MANAGER"
echoerr() { printf "${0##*/}: %s\n" "$*" >&2; echo $SYNOPSIS; }
echohelp() {
    echo
    echo 'Launch polybar statusbars.'
    echo 'To restart, use: polybar-msg cmd restart.'
}

launch_polybars() {
    # Close existing polybar instances.
    # Bars should have 'enable-ipc = true'.
    if [[ -n "$(pgrep -x polybar)" ]]; then
        polybar-msg cmd quit; sleep 1
    fi

    # Launch a statusbar for each connected monitor.
    for m in $(polybar --list-monitors | cut -d ":" -f1); do
        # Requires `monitor = ${env:MONITOR:}` in polybar config.
        MONITOR=$m polybar --reload $BAR >&2 &
        sleep 1
    done
}

case "$1" in
    "-h" | "--help" ) echo $SYNOPSIS; echohelp; exit 0 ;;

    # Requires corresponding [bar-<wm>] configs in polybar config.
    "bspwm" ) BAR="bar-bsp" launch_polybars && exit 0 ;;
    "i3" | "i3wm" ) BAR="bar-i3" launch_polybars && exit 0 ;;

    *) echoerr "missing or unsupported window manager '$1'"; exit 1 ;;
esac
