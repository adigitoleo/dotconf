#!/bin/sh
set -euo pipefail

ls -I 'Alacritty.*' -I '*.cache'|fzf --layout=reverse \
    --bind "backward-eof:abort,tab:down,shift-tab:up,alt-;:cancel" \
    --bind "enter:execute(setsid gtk-launch {} 2>/dev/null &)+abort" \
    --color "fg:12,bg:-1,hl:1,fg+:-1,bg+:-1,hl+:1,preview-fg:3" \
    --color "prompt:2,gutter:-1,pointer:-1,marker:6,spinner:3,info:3" \
    --color "border:12,header:12" \
