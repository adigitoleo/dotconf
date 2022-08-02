#!/bin/sh
set -eu
helpf() {
    echo 'Select and open a file using xdg-open(1).'
    echo 'The list of files is built using the default method of fzf(1),'
    echo 'or may alternatively be provided on the standard input (stdin).'
    echo 'Requires the `fzfpreview.sh` script for file previews.'
}
while getopts "h" OPT; do
    case "$OPT" in
        h ) helpf ; exit 0 ;;
        * ) helpf ; exit 1 ;;
    esac
done

fzf --height 100% --bind "enter:execute(setsid xdg-open {} 2>/dev/null &)+abort" \
    --preview "fzfpreview.sh {}" --preview-window "down:60%:sharp"
