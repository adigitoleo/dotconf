# type: ignore
"""Configuration file for qutebrowser."""

import os
import subprocess
from pathlib import Path
import tomllib

c = c  # pylint: disable=undefined-variable,self-assigning-variable
config = config  # pylint: disable=undefined-variable,self-assigning-variable


# General settings.
########################################################################################

c.url.start_pages = ["http://priv.au/?preferences=eJx1WMuO6zgO_ZrJxugAPT1AYxZZDTDbaWB6b9AWbfNaEn31SOL6-qZiO6bj6kUZ0ZFEia9DqlpI2HMgjLcePQawFwu-z9DjDf3Fcgv29Qty4pbdZDHhzeR2LH89X8jJ0noK_Jxvf4aMF4dpYHP743____MSocOIENrh9uslDejwFqnIuASM2aZYs689PuoEze2_YCNeDFMtk2zvGG4MMrxy6C_LtjqmWa5jIIyXFn3CUIOl3jv5ve4HcwffoqnXcxf0Z8Yw1-TrREkEvC5KviNPSYS2ga1dwGVXuVa7WGYWQRbbtEwPnEac481gB3L_i6EIjZXT0PfkxYj_7qGvaxZdwz_--R_wHmJVJNIdFTyNlaMQOGhM9KvkW8XEQS_20LI3UNeUyjAkauV3MXss4zjW9eo6GTbgTQtuqmuXI7UFIUvlr67vZJDjC_L9YZOMq0WikvxCxTmCle-GLFIO0lIjsYBpvWEzNQfhyVCvbNK27S_prvbzhF6cHVGd3U5TwA4DiitXseKkGAWsxV9U8AV7mDtJAKkDZ5w-hmfdCnhQrc3BEup9gpTj56N1Bz9wpyGD-CVh-Da3wZggUdwVNngn8Ekcpy6AcnMy-6IHjWQgwUH0O8vOCqi5k0PU3EFHhT8QysGf4edgUhdHxz9oQkOwY0mifD7Y6denulZnqR2DBgJiFblLDwhYGQqSSiWpFp92gfxIoOO5m2dlFjmGctytK-PEvO7uJZeh2cKDDTYY-m2O2QQEo9QRqBcdT-Za8cnCXPLvvOM141jiTG9zwg-BwFYk6ald009sjA6JAZoA5bPebQDJlrC4ZgFe56wDcqbZr0Cuz9qe5EHdgbz8JM7xe2y7wA-KA-8yhQ8ChLkqPow6UrcJ7irRqRca1npZyf77IUAtNzHhNWx6wJedA7XqZCkG0E7g1wWOnq3lbNQC_hpIy3QP11gN-Mmtu_0MKhLZzBHxg0dAAmzKjUSh5ODLLTtZlHm5DypLFEg2sLLBJM6BnuLGZhOVMoNRJ-9UskKd_BpfXyrtmgmBrcVEKfMGzxm9T20R-t22Q0KLpldhl_WmPx_CMnrXCzjuWKDT2Qt8yowAEkhVI1QVdTwHTqnkoWQAozJdxIlg0_ktZAFKelbls142opMjqa1iO7CFoB0VC1dOpa1QyiQeZ04sgTyWcHrzUdFAZEA-LFboqnk6pFX2UbI6DrokwFCYRRWOAnwwKJCdHZfQUhreyZWgeo8f1ByqhnRQTynLgQ7JUxi_YR7jJ3g4sQA_Myf8XBU5h_aMTti-aOpv4N3IBS5Vl9L8ufrO84fxCyrNn5OMup6C58G2C-DATsOxfFGbvtgfi8Vvv_3-VKUxG_Q6gL48uAMb8A_E8YgID09kOe37PNxLfO6LQm7mHt3GSxNiSLnRZOFKWZPtY-keHtioqRmORb-MzykTsvCUlmjFnFHYQ2MPftLIXpK0irNnPzvU2uIYjvG1QKezFviUnvHHdJ0e2n4pQHuggHjvC78pWXcmI0yen6ttHmDtIPbz2qPibie98cEK2Tk772dJpbgfXPsCztGxwOem8QUflJfqs5eSJbyHnPZ6fiDEsb_2vJHfRYj_0IW_qPKlZVV0ebfOT7p_5sDa36i-b8Bu5EJh7yg1fSUNf3ksLDVFxTiXUl4NeWtD9h5LL8MkrOHlQsr9nQmsO0DpZnYx_doR7CLWXuRk3xU_WHLFvqFWSeMRoi756NxcldzORT08TWWh_hMoFTN9K0TKgsK_flk7ih1yIM8bw_5T7hsfhJWFvvWUebcPIN0ibm3UVu9L2xwxnWq9ZANikpZWFXdTSGBfNsl7jlUCTRSkq2tAXViauVbuRt6gIi6pvK60AErUPG1xJlcypOhJYlkeZce-R2pcO7LQVmf5scVnHHOTfcpbJ1g6Dy8d1PJ-_K5S5glDjm-TyLOZjPTX4eiHmfMH_b2R7T6SCiW4j74SunLSrFdCKz5asYx-sHAwnkZViZlTV8ykXhWPlMKVlIGb9K_tKbi_nSebJW3jrXQKz-s6ug4SY1INsBYCs7Coe1ggetaSrO34Tv-_EVTq_DI4yWCol384PAKl8xHy9O9q8h2fDw-vJr6WZ6PsdsWTF2lRJOpufwHww43H"]
c.url.searchengines = { "DEFAULT": "http://priv.au/?preferences=eJx1WMuO6zgO_ZrJxugAPT1AYxZZDTDbaWB6b9AWbfNaEn31SOL6-qZiO6bj6kUZ0ZFEia9DqlpI2HMgjLcePQawFwu-z9DjDf3Fcgv29Qty4pbdZDHhzeR2LH89X8jJ0noK_Jxvf4aMF4dpYHP743____MSocOIENrh9uslDejwFqnIuASM2aZYs689PuoEze2_YCNeDFMtk2zvGG4MMrxy6C_LtjqmWa5jIIyXFn3CUIOl3jv5ve4HcwffoqnXcxf0Z8Yw1-TrREkEvC5KviNPSYS2ga1dwGVXuVa7WGYWQRbbtEwPnEac481gB3L_i6EIjZXT0PfkxYj_7qGvaxZdwz_--R_wHmJVJNIdFTyNlaMQOGhM9KvkW8XEQS_20LI3UNeUyjAkauV3MXss4zjW9eo6GTbgTQtuqmuXI7UFIUvlr67vZJDjC_L9YZOMq0WikvxCxTmCle-GLFIO0lIjsYBpvWEzNQfhyVCvbNK27S_prvbzhF6cHVGd3U5TwA4DiitXseKkGAWsxV9U8AV7mDtJAKkDZ5w-hmfdCnhQrc3BEup9gpTj56N1Bz9wpyGD-CVh-Da3wZggUdwVNngn8Ekcpy6AcnMy-6IHjWQgwUH0O8vOCqi5k0PU3EFHhT8QysGf4edgUhdHxz9oQkOwY0mifD7Y6denulZnqR2DBgJiFblLDwhYGQqSSiWpFp92gfxIoOO5m2dlFjmGctytK-PEvO7uJZeh2cKDDTYY-m2O2QQEo9QRqBcdT-Za8cnCXPLvvOM141jiTG9zwg-BwFYk6ald009sjA6JAZoA5bPebQDJlrC4ZgFe56wDcqbZr0Cuz9qe5EHdgbz8JM7xe2y7wA-KA-8yhQ8ChLkqPow6UrcJ7irRqRca1npZyf77IUAtNzHhNWx6wJedA7XqZCkG0E7g1wWOnq3lbNQC_hpIy3QP11gN-Mmtu_0MKhLZzBHxg0dAAmzKjUSh5ODLLTtZlHm5DypLFEg2sLLBJM6BnuLGZhOVMoNRJ-9UskKd_BpfXyrtmgmBrcVEKfMGzxm9T20R-t22Q0KLpldhl_WmPx_CMnrXCzjuWKDT2Qt8yowAEkhVI1QVdTwHTqnkoWQAozJdxIlg0_ktZAFKelbls142opMjqa1iO7CFoB0VC1dOpa1QyiQeZ04sgTyWcHrzUdFAZEA-LFboqnk6pFX2UbI6DrokwFCYRRWOAnwwKJCdHZfQUhreyZWgeo8f1ByqhnRQTynLgQ7JUxi_YR7jJ3g4sQA_Myf8XBU5h_aMTti-aOpv4N3IBS5Vl9L8ufrO84fxCyrNn5OMup6C58G2C-DATsOxfFGbvtgfi8Vvv_3-VKUxG_Q6gL48uAMb8A_E8YgID09kOe37PNxLfO6LQm7mHt3GSxNiSLnRZOFKWZPtY-keHtioqRmORb-MzykTsvCUlmjFnFHYQ2MPftLIXpK0irNnPzvU2uIYjvG1QKezFviUnvHHdJ0e2n4pQHuggHjvC78pWXcmI0yen6ttHmDtIPbz2qPibie98cEK2Tk772dJpbgfXPsCztGxwOem8QUflJfqs5eSJbyHnPZ6fiDEsb_2vJHfRYj_0IW_qPKlZVV0ebfOT7p_5sDa36i-b8Bu5EJh7yg1fSUNf3ksLDVFxTiXUl4NeWtD9h5LL8MkrOHlQsr9nQmsO0DpZnYx_doR7CLWXuRk3xU_WHLFvqFWSeMRoi756NxcldzORT08TWWh_hMoFTN9K0TKgsK_flk7ih1yIM8bw_5T7hsfhJWFvvWUebcPIN0ibm3UVu9L2xwxnWq9ZANikpZWFXdTSGBfNsl7jlUCTRSkq2tAXViauVbuRt6gIi6pvK60AErUPG1xJlcypOhJYlkeZce-R2pcO7LQVmf5scVnHHOTfcpbJ1g6Dy8d1PJ-_K5S5glDjm-TyLOZjPTX4eiHmfMH_b2R7T6SCiW4j74SunLSrFdCKz5asYx-sHAwnkZViZlTV8ykXhWPlMKVlIGb9K_tKbi_nSebJW3jrXQKz-s6ug4SY1INsBYCs7Coe1ggetaSrO34Tv-_EVTq_DI4yWCol384PAKl8xHy9O9q8h2fDw-vJr6WZ6PsdsWTF2lRJOpufwHww43H&q={}" }
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

def get_colors(theme):
    if theme.lower() == "dark":
        with (Path.home() / ".config/alacritty/mellow-dark.toml").open('rb') as file:
            d = tomllib.load(file)
    else:
        with (Path.home() / ".config/alacritty/mellow-light.toml").open('rb') as file:
            d = tomllib.load(file)
    return d["colors"]


with (Path.home() / ".config/alacritty/alacritty.toml").open('rb') as file:
    term_config = tomllib.load(file)
    c.fonts.default_size = str(term_config["font"]["size"]) + "pt"

c.fonts.default_family = "monospace"
c.fonts.web.size.default_fixed = 14
c.fonts.web.size.minimum = 14

c.colors.hints.bg = "rgba(200, 200, 200, 0.6)"
c.colors.hints.fg = "black"
c.colors.hints.match.fg = "darkRed"

THEME = subprocess.run(["theme", "-q"], capture_output=True, check=True).stdout
if "dark" in str(THEME):
    colors = get_colors("dark")
    # Optional Qt dark mode, works for all sites not just those with dark CSS option,
    # however overwrites dark CSS, looks more ugly and requires a restart to turn off.
    if "QB_QT_DARKMODE" in os.environ and bool(os.environ["QB_QT_DARKMODE"]):
        c.colors.webpage.darkmode.enabled = True
    else:
        c.colors.webpage.preferred_color_scheme = "dark"

    # Set the default bg to a darker color as well to prevent white flashes.
    # But not too dark so that crappy sites that don't set a background/font color
    # aren't unreadable without forced Qt dark mode.
    c.colors.webpage.bg = colors["bright"]["magenta"]

    c.colors.statusbar.normal.bg = colors["normal"]["magenta"]
    c.colors.tabs.bar.bg = colors["normal"]["magenta"]
    c.colors.tabs.odd.bg = colors["normal"]["magenta"]
    c.colors.tabs.even.bg = colors["bright"]["magenta"]
    c.colors.tabs.pinned.odd.bg = colors["normal"]["cyan"]
    c.colors.tabs.pinned.even.bg = colors["bright"]["cyan"]
    c.colors.tabs.odd.fg = colors["bright"]["yellow"]
    c.colors.tabs.even.fg = colors["bright"]["yellow"]
    c.colors.tabs.pinned.odd.fg = colors["normal"]["black"]
    c.colors.tabs.pinned.even.fg = colors["normal"]["black"]
    c.colors.tabs.selected.even.fg = colors["normal"]["white"]
    c.colors.tabs.selected.odd.fg = colors["normal"]["white"]

    # Forced dark mode for some URL patterns.
    config.set("colors.webpage.darkmode.enabled", True, "https://pkgs.alpinelinux.org/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.anu.edu.au/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.apsjobs.gov.au/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.doi.org/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.distrowatch.com/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.freedesktop.org/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.git-scm.com/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.git-send-email.io/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.sircmpwn.srht.site/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://ihateregex.io/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.lua.org/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.microsoftonline.com/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.oilshell.org/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.openai.com/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.orcid.org/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.overleaf.com/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.pypi.org/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.repology.org/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.rosettacode.org/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.sciencedirect.com/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.semanticscholar.org/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.stripe.com/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.theregister.com/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.wiley.com/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.ycombinator.com/*")
    config.set("colors.webpage.darkmode.enabled", True, "https://*.zulipchat.com/login/*")
    config.set("colors.webpage.darkmode.enabled", True, "qute://*")
else:
    colors = get_colors("light")
    c.colors.webpage.bg = colors["bright"]["white"]
    c.colors.statusbar.normal.bg = colors["normal"]["magenta"]


# Custom key bindings.
########################################################################################

config.unbind("J")
config.unbind("K")
config.unbind("<Ctrl-N>")
config.unbind("<Ctrl-P>")

config.unbind("<Ctrl-Q>")

config.bind("<Ctrl-N>", "tab-next")
config.bind("<Ctrl-P>", "tab-prev")

config.bind("gR", "restart")
config.bind("tt", "config-cycle tabs.show always switching")

config.bind("<Ctrl-l>", "search")  # Clears search highlighting.
config.bind("¶", "clear-keychain ;; search ;; fullscreen --leave")
config.bind("<Ctrl-c>", "clear-keychain ;; search ;; fullscreen --leave")

for m in ["caret", "command", "hint", "insert", "prompt", "register", "yesno"]:
    config.bind("¶", "mode-leave", mode=m)
    config.bind("<Ctrl-c>", "mode-leave", mode=m)


# Don't load the autoconfig, maintain all configuration here (must be last).
config.load_autoconfig(False)
