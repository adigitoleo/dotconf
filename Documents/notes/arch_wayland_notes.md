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
(`sed -i 's/#CFLAGS += -DXWAYLAND/CFLAGS += -DXWAYLAND/' config.mk`),
which allows to run legacy X11 programs using **xorg-xwayland** <https://xorg.freedesktop.org>.


## Compatibility

*   **qt5-wayland**: needed for proper wayland support of (some) qt5 apps
    <https://www.qt.io>
*   **waypipe**: a proxy for Wayland clients, needed for GUI over ssh/network
    <https://gitlab.freedesktop.org/mstoeckl/waypipe>


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
*   **obs-studio** with **wlrobs** (AUR): screen recording
    <https://obsproject.com>
    <https://hg.sr.ht/~scoopta/wlrobs>
*   **musescore**: music engraving
    <https://musescore.org/>


## CLI tools and dev libraries

*   **pyside2**: python qt5 bindings
    <https://www.qt.io>
*   **swaybg**: set desktop background for sway (static image or color)
    <https://github.com/swaywm/swaybg>
*   **wlsunset**: gamma adjustments for wayland (replaces `redshift`)
    <https://sr.ht/~kennylevinsen/wlsunset>
*   **slurp**: select a region in a wayland compositor
    <https://github.com/emersion/slurp>
*   **grim**: screenshot utility for wayland
    <https://github.com/emersion/grim>
    *   *TIP*: works well with slurp like `grim -g "$(slurp)"`
*   **wlr-randr** (AUR): monitor/graphical output management (replaces `xrandr`)
    <https://github.com/emersion/wlr-randr>


## TODO: Verify if these are supported

*   **darktable-git** (AUR): professional photo editor (raster graphics)
    <http://www.darktable.org/>
    NOTE: Building the AUR package can take some time, don't rush updates
*   **pavucontrol-qt**: GUI for pulseaudio, should support wayland (???)
    <https://github.com/lxqt/pavucontrol-qt>
*   **dia**: diagram creation program (vector graphics)
    <http://live.gnome.org/Dia>


## Not supported (might run using xwayland)

*   **krita**: digital painting program (raster graphics)
    <https://krita.org/en/>
    <https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=955730>
*   **inkscape**: vector graphics editor (vector graphics)
    <https://inkscape.org/>
