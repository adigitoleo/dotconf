# type: ignore
"""Configuration file for qutebrowser."""

import os
import subprocess
from pathlib import Path

import yaml

c = c  # pylint: disable=undefined-variable,self-assigning-variable
config = config  # pylint: disable=undefined-variable,self-assigning-variable


# General settings.
########################################################################################

c.url.start_pages = ["https://start.duckduckgo.com"]
c.url.default_page = "qute://history/"
c.auto_save.session = True
c.statusbar.position = "top"
c.completion.shrink = True
c.session.lazy_restore = True
c.content.autoplay = False
c.content.prefers_reduced_motion = True
c.content.register_protocol_handler = False
c.editor.command = [
    "alacritty",
    "--class=floating-terminal,floating-terminal",
    "-e",
    "nvim",
    "{file}",
]
c.fileselect.handler = "external"
c.fileselect.single_file.command = [
    "alacritty",
    "--class=floating-terminal,floating-terminal",
    "--working-directory=/",
    "-e",
    "fzf",
    "--height",
    "100%",
    "--bind",
    "enter:execute(realpath {1} >{})+abort",
    "--preview",
    "fzfpreview.sh {1}",
    "--preview-window",
    "down:60%:sharp",
]
c.fileselect.multiple_files.command = [
    "alacritty",
    "--class=floating-terminal,floating-terminal",
    "--working-directory=/",
    "-e",
    "fzf",
    "--height",
    "100%",
    "--multi",
    "--bind",
    "enter:execute(realpath {+} >{})+abort",
    "--preview",
    "fzfpreview.sh {+}",
    "--preview-window",
    "down:60%:sharp",
]
c.downloads.remove_finished = 1000
c.content.notifications.enabled = True
c.content.notifications.presenter = "libnotify"

if "QB_FORCE_HIDPI" in os.environ and bool(os.environ["QB_FORCE_HIDPI"]):
    c.qt.highdpi = True
    c.zoom.default = "85%"

# https://github.com/qutebrowser/qutebrowser/issues/1476
# c.qt.force_software_rendering = "qt-quick"
# https://github.com/qutebrowser/qutebrowser/issues/7147
# c.qt.workarounds.remove_service_workers = True


# Hardening (at least a little bit...)
########################################################################################

if "QB_TOR_PORT" in os.environ:
    c.content.proxy = f"socks://localhost:{os.environ['QB_TOR_PORT']}/"
    c.url.start_pages = ["http://ahmiacawquincyw7d4kmsopfi667eqdhuva3sxfpxiqymmojzb7fchad.onion/"]

c.content.webrtc_ip_handling_policy = "default-public-interface-only"
c.content.webgl = False
c.content.cookies.accept = "no-3rdparty"
c.content.cookies.store = False
c.content.dns_prefetch = False


# Tab settings.
########################################################################################

c.tabs.last_close = "startpage"
c.tabs.mousewheel_switching = False
c.tabs.position = "left"
c.tabs.new_position.related = "next"
c.tabs.new_position.unrelated = "next"
c.tabs.select_on_remove = "prev"
c.tabs.title.format_pinned = "{audio}{index}: {current_title}"


# Appearance settings.
########################################################################################

with (Path.home() / ".config/alacritty/alacritty.yml").open() as file:
    term_config = yaml.safe_load(file)


def get_colors(name):
    return (
        list(term_config["schemes"][name]["normal"].values())
        + list(term_config["schemes"][name]["bright"].values())
    )


c.fonts.default_size = str(term_config["font"]["size"]) + "pt"
c.fonts.default_family = "monospace"
c.fonts.web.size.default_fixed = 14
c.fonts.web.size.minimum = 14

c.colors.hints.bg = "rgba(200, 200, 200, 0.6)"
c.colors.hints.fg = "black"
c.colors.hints.match.fg = "darkRed"

THEME = subprocess.run(["theme", "-q"], capture_output=True, check=True).stdout
if "dark" in str(THEME):
    colors = get_colors("mellow_dark")
    # Optional Qt dark mode, works for all sites not just those with dark CSS option,
    # however overwrites dark CSS, looks more ugly and requires a restart to turn off.
    if "QB_QT_DARKMODE" in os.environ and bool(os.environ["QB_QT_DARKMODE"]):
        c.colors.webpage.darkmode.enabled = True
    else:
        c.colors.webpage.preferred_color_scheme = "dark"

    # Set the default bg to a darker color as well to prevent white flashes.
    # But not too dark so that crappy sites that don't set a background/font color
    # aren't unreadable without forced Qt dark mode.
    c.colors.webpage.bg = colors[13]

    c.colors.statusbar.normal.bg = colors[5]
    c.colors.tabs.bar.bg = colors[5]
    c.colors.tabs.odd.bg = colors[5]
    c.colors.tabs.even.bg = colors[13]
    c.colors.tabs.pinned.odd.bg = colors[6]
    c.colors.tabs.pinned.even.bg = colors[14]
    c.colors.tabs.odd.fg = colors[11]
    c.colors.tabs.even.fg = colors[11]
    c.colors.tabs.pinned.odd.fg = colors[0]
    c.colors.tabs.pinned.even.fg = colors[0]
    c.colors.tabs.selected.even.fg = colors[7]
    c.colors.tabs.selected.odd.fg = colors[7]
else:
    colors = get_colors("mellow_light")
    c.colors.webpage.bg = colors[15]
    c.colors.statusbar.normal.bg = colors[5]


# Custom key bindings.
########################################################################################

config.unbind("J")
config.unbind("K")
config.unbind("<Ctrl-N>")
config.unbind("<Ctrl-P>")

config.unbind("<Ctrl-Q>")

config.bind("<Ctrl-N>", "tab-next")
config.bind("<Ctrl-P>", "tab-prev")

config.bind("gr", "restart")
config.bind("tt", "config-cycle tabs.show always switching")

config.bind("<Ctrl-l>", "search")  # Clears search highlighting.
config.bind("¶", "clear-keychain ;; search ;; fullscreen --leave")
config.bind("<Ctrl-c>", "clear-keychain ;; search ;; fullscreen --leave")

for m in ["caret", "command", "hint", "insert", "prompt", "register", "yesno"]:
    config.bind("¶", "mode-leave", mode=m)
    config.bind("<Ctrl-c>", "mode-leave", mode=m)


# Don't load the autoconfig, maintain all configuration here (must be last).
config.load_autoconfig(False)
