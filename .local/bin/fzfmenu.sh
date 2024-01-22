#!/bin/sh
set -eu
helpf() {
    echo 'Select and run a desktop application using gio(1).'
    echo 'The application list is built using `.desktop` files from'
    echo '`/usr/share/applications`. Also requires find(1) and fzf(1).'
}
while getopts "h" OPT; do
    case "$OPT" in
        h ) helpf ; exit 0 ;;
        * ) helpf ; exit 1 ;;
    esac
done

if 1>/dev/null 2>&1 command -v gio;  then
    find /usr/share/applications -type f -name '*.desktop'| \
        while IFS= read -r line; do basename -s .desktop "$line"; done|fzf --height 100% \
        --bind "enter:execute(setsid -f gio launch /usr/share/applications/{}.desktop)+abort"
else
    >&2 printf '%s\n' 'Requires `gio launch` from https://gitlab.gnome.org/GNOME/glib/'
fi
