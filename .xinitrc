#!/bin/sh

# Start the ssh key caching agent.
eval "$(ssh-agent -s)"

# Merge in defaults and keymaps.

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# Start global plugin scripts for X.

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Set up session timers (hardware dependent, disable if crashing).
xset s off &  # seconds until display blanking/screensaver (or xss-lock).
xset dpms 0 0 0 &  # seconds until standby; suspend; off

# Swap left alt with left win key (undo: setxkbmap -option).
setxkbmap -layout us,pl -option altwin:swap_lalt_lwin &

# Start custom background programs for the user session.
picom -b &  # standalone compositor for X
dxhd -b &  # standalone hotkey daemon for X
unclutter --timeout 1 --jitter 2 --ignore-scrolling &  # auto-hide the X cursor
dunst &  # standalone desktop notification daemon for X
redshift &  # manage day/night display color temperature
mocp -S 1>/dev/null &  # music player server with CLI controls

# start the window manager
exec /usr/bin/bspwm
