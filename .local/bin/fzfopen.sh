#!/bin/sh
set -eu

fzf --height 100% --bind "enter:execute(setsid xdg-open {} 2>/dev/null &)+abort" \
    --preview "fzfpreview.sh {}" --preview-window "down:60%:sharp"
