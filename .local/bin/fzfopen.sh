#!/usr/bin/sh

rg --files --hidden --no-messages|fzf --layout=reverse \
    --bind "backward-eof:abort,tab:down,shift-tab:up,alt-;:cancel" \
    --bind "alt-j:preview-down,alt-k:preview-up" \
    --bind "enter:execute(setsid xdg-open {} 2>/dev/null &)+abort" \
    --preview "fzfpreview.sh {}" \
    --preview-window "down:60%:sharp" \
    --color "fg:12,bg:-1,hl:1,fg+:-1,bg+:-1,hl+:1,preview-fg:3" \
    --color "prompt:2,gutter:-1,pointer:-1,marker:6,spinner:3,info:3" \
    --color "border:12,header:12" \
