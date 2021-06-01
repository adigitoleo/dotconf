#!/bin/bash
SYNOPSIS="Usage: ${0##*/} [-h]"
echoerr() { printf "${0##*/}: %s\n" "$*" >&2; echo $SYNOPSIS; }
echohelp() {
    echo
    echo 'Lock an X session display using i3lock-color.'
    echo 'Uses --nofork for xss-lock compatibility.'
    echo 'Overlays a centered image of $HOME/.lock.png'
    echo 'Deletes any cached keys from the ssh-agent.'
}

case "$1" in
    "-h" | "--help" ) echo $SYNOPSIS; echohelp; exit 0 ;;
esac

# Delete cached ssh keys from ssh-agent.
if [ -n $SSH_AUTH_SOCK ]; then
    ssh-add -d
fi

# Image to overlay on the lockscreen.
LOCK=$HOME/.lock.png

i3lock --nofork \
    --clock \
    --datestr="%a, %d %b" \
    --datesize=28 \
    --datecolor=E0CCAE \
    --timestr="%H:%M" \
    --timesize=64 \
    --timecolor=E0CCAE \
    --insidevercolor=66292F \
    --insidewrongcolor=66292F \
    --insidecolor=00000000 \
    --ringvercolor=00000000 \
    --ringwrongcolor=00000000 \
    --ringcolor=00000000 \
    --line-uses-ring \
    --keyhlcolor=84BF40 \
    --bshlcolor=AF0032 \
    --separatorcolor=00000000 \
    --verifcolor=E0CCAE \
    --wrongcolor=FF7477 \
    --radius=100 \
    --blur=0.5 \
    -i $LOCK -C
