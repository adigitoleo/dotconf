#!/bin/sh
# Generate output for wayland status bars. See swaybar-protocol(7).
set -eu
readonly SCRIPTNAME="${0##*/}"

warn() { >&2 printf '%s\n' "$SCRIPTNAME: $1"; }

STATUS_CMD=
BATTERY_INFO_DIR="/sys/class/power_supply/BAT0"
if [ -d "$BATTERY_INFO_DIR" ]; then
    ENERGY_NOW_FILE="$BATTERY_INFO_DIR/energy_now"
    ENERGY_FULL_FILE="$BATTERY_INFO_DIR/energy_full"
    BATTERY_STATUS_FILE="$BATTERY_INFO_DIR/status"
    if [ -r "$ENERGY_NOW_FILE" ]; then
        IFS= read -r ENERGY_NOW <"$ENERGY_NOW_FILE"
    else
        warn "cannot read from file: '$ENERGY_NOW_FILE'"; exit 1
    fi
    if [ -r "$ENERGY_FULL_FILE" ]; then
        IFS= read -r ENERGY_FULL <"$ENERGY_FULL_FILE"
        ENERGY_PERCENT=$(( 100 * $ENERGY_NOW / ENERGY_FULL ))
    else
        warn "cannot read from file: '$ENERGY_FULL_FILE'"; exit 1
    fi
    if [ -r "$BATTERY_STATUS_FILE" ]; then
        IFS= read -r BATTERY_STATUS <"$BATTERY_STATUS_FILE"
        case "$BATTERY_STATUS" in
            Charging ) STATUS_CMD="ϟ $ENERGY_PERCENT% |";;
            Discharging ) STATUS_CMD="$ENERGY_PERCENT% |";;
        esac
    else
        warn "cannot read from file: '$BATTERY_STATUS_FILE'"; exit 1
    fi
fi

STATUS_CMD="$STATUS_CMD $(date +'%A %Y-%m-%d %I:%M %p ')"
printf '%s\n' "$STATUS_CMD"
