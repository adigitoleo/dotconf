#!/bin/sh
set -eu

ls -I 'Alacritty.*' -I '*.cache' /usr/share/applications|sed -e 's/\.desktop$//'|fzf --height 100% \
    --bind "enter:execute(setsid gtk-launch {} 2>/dev/null &)+abort"
