#!/bin/sh
set -eu
helpf() {
    echo 'Select and run a desktop application using gtk-launch(1).'
    echo 'The application list is built using `.desktop` files from'
    echo '`/usr/share/applications`. Also requires find(1) and fzf(1).'
}
while getopts "h" OPT; do
    case "$OPT" in
        h ) helpf ; exit 0 ;;
        * ) helpf ; exit 1 ;;
    esac
done

find /usr/share/applications -type f -name '*.desktop' | \
    while IFS= read -r line || [ -n "$line" ];
        do grep '^Name=' "$line"|sed 's/Name=//';
    done|fzf --height 100% \
    --bind "enter:execute(grep 'Name={}'|setsid gtk-launch 2>/dev/null &)+abort"
