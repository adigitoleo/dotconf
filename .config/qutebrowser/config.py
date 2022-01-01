# type: ignore
"""Configuration file for qutebrowser."""

import os
import subprocess
from pathlib import Path

import yaml

from qutebrowser.api import interceptor  # type: ignore

c = c  # pylint: disable=undefined-variable,self-assigning-variable
config = config  # pylint: disable=undefined-variable,self-assigning-variable


# General settings.
########################################################################################

# This works on at least Arch and Void...
with open("/etc/os-release") as file:
    OSNAME = file.readline()

if "Arch" in OSNAME:
    c.url.start_pages = ["https://www.archlinux.org/"]
elif "void" in OSNAME:
    c.url.start_pages = ["https://voidlinux.org/news/"]
 
c.url.default_page = "qute://history/"
c.auto_save.session = True
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
# TODO: Re-enable after setting up a notifications daemon?
c.content.notifications.enabled = False

if "THIS_IS_A_LAPTOP" in os.environ and os.environ["THIS_IS_A_LAPTOP"]:
    c.qt.highdpi = True
    c.zoom.default = "85%"

# https://github.com/qutebrowser/qutebrowser/issues/1476
c.qt.force_software_rendering = "qt-quick"


# Hardening (at least a little bit...)
########################################################################################

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
c.tabs.new_position.unrelated = "prev"
c.tabs.title.format_pinned = "{audio}{index}: {current_title}"


# Appearance settings.
########################################################################################

with (Path.home() / ".config/alacritty/alacritty.yml").open() as file:
    term_config = yaml.safe_load(file)

normal_colors = lambda name: list(term_config["schemes"][name]["normal"].values())
bright_colors = lambda name: list(term_config["schemes"][name]["bright"].values())

light_theme = normal_colors("mellow_light") + bright_colors("mellow_light")
dark_theme = normal_colors("mellow_dark") + bright_colors("mellow_dark")

c.fonts.default_size = str(term_config["font"]["size"]) + "pt"
c.fonts.default_family = "monospace"

c.colors.webpage.darkmode.algorithm = "lightness-cielab"
c.colors.webpage.darkmode.policy.images = "smart"
c.colors.webpage.darkmode.threshold.background = 100
c.colors.webpage.darkmode.threshold.text = 200

THEME = subprocess.run(["theme", "-q"], capture_output=True, check=True).stdout
if "dark" in str(THEME):
    c.colors.webpage.darkmode.enabled = True
    c.colors.webpage.preferred_color_scheme = "dark"
    # Set the default bg to a dark color as well to prevent white flashes.
    c.colors.webpage.bg = dark_theme[8]
    c.colors.statusbar.normal.bg = dark_theme[5]
    c.colors.tabs.bar.bg = dark_theme[5]
    c.colors.tabs.odd.bg = dark_theme[5]
    c.colors.tabs.even.bg = dark_theme[13]
    c.colors.tabs.pinned.odd.bg = dark_theme[6]
    c.colors.tabs.pinned.even.bg = dark_theme[14]

    c.colors.tabs.odd.fg = dark_theme[11]
    c.colors.tabs.even.fg = dark_theme[11]
    c.colors.tabs.pinned.odd.fg = dark_theme[0]
    c.colors.tabs.pinned.even.fg = dark_theme[0]
    c.colors.tabs.selected.even.fg = dark_theme[7]
    c.colors.tabs.selected.odd.fg = dark_theme[7]
else:
    c.colors.webpage.bg = light_theme[15]
    c.colors.statusbar.normal.bg = light_theme[5]
    # c.content.user_stylesheets = ["~/.config/qutebrowser/off-white-bg.css"]


# Custom key bindings.
########################################################################################

config.unbind("J")
config.unbind("K")
config.unbind("<Ctrl-N>")
config.unbind("<Ctrl-P>")

# Change tab-next to plain Tab, requires the following issue to be solved:
# https://github.com/qutebrowser/qutebrowser/issues/4579
config.bind("<Ctrl-N>", "tab-next")
config.bind("<Ctrl-P>", "tab-prev")

config.bind("<Space>r", "restart")
config.bind("<Space>t", "config-cycle tabs.show always never")

config.bind("<Ctrl-l>", "search")  # Clears search highlighting.
config.bind("¶", "clear-keychain ;; search ;; fullscreen --leave")

for m in ["caret", "command", "hint", "insert", "prompt", "register", "yesno"]:
    config.bind("<Alt-;>", "mode-leave", mode=m)


# Don't load the autoconfig, maintain all configuration here (must be last).
config.load_autoconfig(False)
