#!/bin/sh

## WM-INDEPENDENT HOTKEYS {{{1

## Adjust screen backlight uising function keys.
# XF86MonBrightness{Up,Down}
xbacklight -{inc 5,dec 5}

## Adjust pulseaudio volume using function keys.
## Requires pavolume script (pactl wrapper).
# XF86Audio{RaiseVolume,LowerVolume,Mute}
pavolume {+5%,-5%,toggle}

## Toggle pulseaudio source (mute/unmute) using function key.
## Function key to mute mic is not very common.
# XF86AudioMicMute
pactl set-source-mute @DEFAULT_SOURCE@ toggle

## Launch screenshot command using PrintScreen key.
## Requires imagemagick.
# Print
capture.sh

## Cycle keyboard layouts.
# super + space
xkb-switch -n

## Launch terminal emulator.
# super + Return
alacritty

## Launch a GUI picker menu.
# super + m
rofi -show combi

## Launch terminal intended for short-lived operations.
## # super + b
## alacritty --working-directory /usr/bin --class=launcher,launcher

# super + shift + m
rofi-open

## X session control.
# super + shift + s
powermenu.sh

## Make dxhd reload its configuration files.
## FIXME: Trigger notify-send on reload automatically.
# super + Escape
pkill -USR1 -x dxhd && notify-send -t 1200 "Reloaded dxhd" "Refreshed  keyboard bindings"


## COMMON BSPWM HOTKEYS {{{1

## quit/restart bspwm
## FIXME: Trigger notify-send on reload automatically.
# super + shift + {q,Escape}
bspc {quit,wm -r && notify-send -t 1200 "Reloaded bspwm" "Refreshed window manager"}

## close and kill
# super + {_,shift +}d
bspc node -{c,k}

## set the window state
# super + {t,shift + t,s,f}
bspc node -t {tiled,pseudo_tiled,floating,fullscreen}

## focus or swap with the node in the given direction
# super + {_,shift + }{h,j,k,l}
bspc node -{f,s} {west,south,north,east}

## Rotate tiled layout
# super + r
bspc node @/ -R 90
# super + shift + r
bspc node @/ -R -90

## focus the most recent desktop that is occupied (current monitor)
# super + Tab
bspc desktop -f last.local.occupied

## focus the next/previous window or the next/previous desktop (current monitor)
# super + bracket{left,right}
bspc desktop -f {prev,next}.local.occupied

## cycle window focus in current desktop
# super + {_, shift + }c
bspc node -f {next,prev}.local.!hidden.window

## focus or send to the given desktop
# super + {_,shift + }{1-9,0}
bspc {desktop -f,node -d} '^{1-9,10}'

## expand a window by moving one of its side outward
# super + ctrl + {h,j,k,l}
bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}

## contract a window by moving one of its side inward
# super + ctrl + shift + {h,j,k,l}
bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}

## move a floating window (to resize, drag corner while holding right mouse)
# super + {Left,Down,Up,Right}
bspc node -v {-20 0,0 20,0 -20,20 0}


## ADVANCED BSPWM HOTKEYS {{{1

## focus or send to the next unoccupied desktop in the current monitor
# super + {_,shift + }n
bspc {desktop -f,node -d} next.!occupied

## set the node flags
# super + ctrl + {m,x,y,z}
bspc node -g {marked,locked,sticky,private}

## focus the node for the given path jump
# super + {p,b,comma,period}
bspc node -f @{parent,brother,first,second}

## focus the older or newer node in the focus history
# super + {o,i}
bspc wm -h off; bspc node {older,newer} -f; bspc wm -h on

## preselect the direction
# super + alt + {h,j,k,l}
bspc node -p {west,south,north,east}

## preselect the ratio
# super + alt + {1-9}
bspc node -o 0.{1-9}

## cancel the preselection for the focused node
# super + alt + semicolon
bspc node -p cancel

## cancel the preselection for the focused desktop
# super + alt + shift + semicolon
bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel
