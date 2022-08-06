# Notes for Arch + Wayland

Wiki link: <https://wiki.archlinux.org/index.php/Wayland>

Complementary reference: <https://arewewaylandyet.com/>

The reference compositor is **weston** <https://wayland.freedesktop.org/>.
It's in the Arch community repo and
could be worth keeping around as a fallback.

A port of dwm called **dwl** <https://github.com/djpohly/dwl> (in beta)
provides a nice, lightweight and simple tiling WM experience.
The AUR package is maintained by the core dev.

Compiling dwl with XWayland support is possible
(`sed -i -e '/-DXWAYLAND/s/^#//' config.mk`),
which allows to run legacy X11 programs using **xorg-xwayland** <https://xorg.freedesktop.org>.

These dotfiles also support a minimal `sway` setup.
Not as light as dwl but has a larger community,
and you can reload the configuration without recompiling.
Dwl also doesn't have stacked (tabbed) containers.
Sway has `swaymsg` which is a live diagnostic cli tool.
However, the tiling algorithm in dwl is better (automatic).
Check the sway configs here and also the [autotiling](https://github.com/nwg-piotr/autotiling) script on GitHub for some attempts to make it better.
Things still fall apart when you resize containers though...


## Compatibility

*   **qt5-wayland**: needed for proper wayland support of (some) qt5 apps
    <https://www.qt.io>
*   **waypipe**: a proxy for Wayland clients, needed for GUI over ssh/network
    <https://gitlab.freedesktop.org/mstoeckl/waypipe>

Because the current "wisdom" on how to escape dependency hell
involves copious amounts of bundling/vendoring,
some programs that ship with their own graphical frameworks (e.g. Qt)
still don't work even after installing these compatibility layers.
For example, to fix Plots.jl for Julia it is necessary to tell it
to use the system installed version of the GR library rather than its own:

```
ENV["JULIA_GR_PROVIDER"] = "GR"
using Pkg; Pkg.build("GR")
```


## Desktop programs

*   **alacritty**: terminal emulator
    <https://github.com/jwilm/alacritty>
*   **qutebrowser**: web browser (IMPORTANT: install qt5-wayland first)
    <https://www.qutebrowser.org/>
*   **zathura**: document (e.g. PDF) viewer
    <https://pwmt.org/projects/zathura/>
    *   **zathura-pdf-mupdf**: use mupdf backend for PDF (bundles custom mupdf)
        <https://pwmt.org/projects/zathura-pdf-mupdf/>
*   **scribus**: document publishing, good for posters (vector graphics)
    <https://www.scribus.net/>
*   **gimp-devel** (AUR): image editor (raster graphics)
    <https://www.gimp.org/>
    NOTE: Building the AUR package can take some time, don't rush updates
*   **libreoffice-still**: MS office clone, should support wayland for v5+
    <https://www.libreoffice.org/>
    *   **libreoffice-draw** is a pretty nice vector graphics editor
*   **obs-studio** with **wlrobs** (AUR): screen recording
    <https://obsproject.com>
    <https://hg.sr.ht/~scoopta/wlrobs>
*   **musescore**: music engraving
    <https://musescore.org/>


## CLI tools and dev libraries

*   **swaybg**: set desktop background (not only for sway)
    <https://github.com/swaywm/swaybg>
*   **wlsunset**: gamma adjustments for wayland (replaces `redshift`)
    <https://sr.ht/~kennylevinsen/wlsunset>
*   **slurp**: select a region in a wayland compositor
    <https://github.com/emersion/slurp>
*   **grim**: screenshot utility for wayland
    <https://github.com/emersion/grim>
    *   *TIP*: works well with slurp like `grim -g "$(slurp)"`
*   **wlr-randr** (AUR): video output diagnostics (replaces `xrandr`)
    <https://github.com/emersion/wlr-randr>
*   **kanshi**: automatic profiles for monitors (same author as wlr-randr)
    <https://wayland.emersion.fr/kanshi/>


## Unstable support

*   **darktable-git** (AUR): professional photo editor (raster graphics)
    <http://www.darktable.org/>
    NOTE: Building the AUR package can take some time, don't rush updates
    Wayland support: https://github.com/darktable-org/darktable/issues/3655
