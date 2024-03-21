#!/bin/sh
set -u
helpf() {
    echo 'Select and open a binary file using xdg-open(1).'
    echo 'The list of files is built using rg(1), and excludes all text file'
    echo 'types know to that command (see rg --type-list), which can be opened'
    echo 'in a terminal using nvim(1) or similar instead.'
    echo 'Requires the `fzfpreview.sh` script for (some) file previews.'
}
while getopts "h" OPT; do
    case "$OPT" in
        h ) helpf ; exit 0 ;;
        * ) helpf ; exit 1 ;;
    esac
done

rg --files --hidden --binary --type-clear=pdf --type-not=all --no-messages --no-ignore-vcs| \
    fzf --height 100% --bind "enter:execute(setsid xdg-open {} 2>/dev/null &)+abort" \
    --preview "fzfpreview.sh {}" --preview-window "down:60%:sharp"
