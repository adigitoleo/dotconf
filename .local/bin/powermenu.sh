#!/bin/bash

rofi_command='rofi -theme mellow'

power_off='power down'
reboot='reboot'
lock='lock session'
quit='quit session'

# TODO: Add polybar, sxhkd and WM reloaders, add WM quit.

options="$power_off\n$reboot\n$lock\n$quit"

chosen="$(echo -e "$options" | $rofi_command -dmenu -p "Session:" \
    -selected-row 2 -width 20 -no-show-match -no-sort)"
case $chosen in
    $power_off )
        sleep 0.3 && systemctl poweroff ;;
    $reboot )
        sleep 0.3 && systemctl reboot ;;
    $lock )
        sleep 0.3 && loginctl lock-session ;;
    $quit )
        sleep 0.3 && loginctl terminate-session \
            $(loginctl session-status|awk 'NR==1{print $1}')  ;;
esac

# Open terminal to run a single fzf search. Result returned as string to
# caller.
# alacritty -e bash -c "fzf $* < /proc/$$/fd/0 > /proc/$$/fd/1"
