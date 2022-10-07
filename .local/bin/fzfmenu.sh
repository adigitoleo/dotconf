#!/bin/sh
set -eu
helpf() {
    echo 'Select and run a desktop application using dex(1).'
    echo 'The application list is built using `.desktop` files from'
    echo '`/usr/share/applications`. Also requires find(1) and fzf(1).'
}
while getopts "h" OPT; do
    case "$OPT" in
        h ) helpf ; exit 0 ;;
        * ) helpf ; exit 1 ;;
    esac
done

if 1>/dev/null 2>&1 command -v dex;  then
    # TODO: Preview window with app name?
    # Unfortunately, the xdg-dekstop spec is spectacularly stupid,
    # and forces us to parse the whole .desktop file to find even simple info:
    # %zsh: grep '^Name=' /usr/share/applications/org.qutebrowser.qutebrowser.desktop
    # Name=qutebrowser
    # Name=New Window
    # Name=Preferences
    find /usr/share/applications -type f -name '*.desktop'|fzf --height 100% \
        --bind "enter:execute(setsid dex {})+abort"
else
    >&2 printf '%s\n' 'Requires dex, https://github.com/jceb/dex'
fi
