# $ZDOTDIR/.zprofile ($HOME/.zprofile by default)
# Sourced when starting as a login shell.
# Used to set portable session-wide environment variables, e.g. EDITOR, PATH, ...
# For hardware-specific or non-portable variables, use ./.zprofile.more instead.
# To autostart graphical servers, use ./.zprofile.more instead.

# Fuzzy search.
is_command() {
    if 1>/dev/null 2>&1 command -v "$1"; then
        return 0
    else
        >&2 printf '%s\n' "$HOME/.zprofile: command '$1' not found"; return 1
    fi
}
if is_command fzf && is_command rg; then
    export FZF_DEFAULT_OPTS='--multi --height 50% --layout=reverse --marker="+"
        --bind backward-eof:abort,tab:down,shift-tab:up
        --bind +:toggle-down,¶:abort,alt-\;:abort,ctrl-l:clear-selection+first
        --bind alt-j:preview-down,alt-k:preview-up
        --color fg:12,bg:-1,hl:1,fg+:-1,bg+:-1,hl+:1,preview-fg:3
        --color prompt:2,gutter:-1,pointer:-1,marker:6,spinner:3,info:3
        --color border:12,header:12
    '
    export FZF_DEFAULT_COMMAND='rg --files --hidden --binary --no-messages --no-ignore-vcs'
    # Undocumented in manpage, triggers fzf if tab is pressed afterwards.
    export FZF_COMPLETION_TRIGGER=',,'
fi


# Set preferred editors.
EDITOR="vim"
VISUAL="vim"
if [ -x "/usr/bin/vis" ]; then
    EDITOR="/usr/bin/vis"
fi
if [ -x "/usr/bin/nvim" ]; then
    VISUAL="/usr/bin/nvim"
fi
export EDITOR
export VISUAL

# Set colorterm to use truecolors if not already.
if [ "$COLORTERM" != "truecolor" ]; then
    export COLORTERM=truecolor
    export MANPAGER="less -R --use-color -Dd+c -Du+y"
fi

# Set LS_COLORS if not set already.
if [ -z "$LS_COLORS" ] && is_command dircolors; then
    eval $(dircolors $HOME/.dir_colors)
fi

# Prepend ~/.local/bin to PATH if it exists.
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Prepend ~/.local/share/man to MANPATH if it exists.
if [ -d "$HOME/.local/share/man" ]; then
    export MANPATH="$HOME/.local/share/man:$MANPATH"
fi

# Prepend ~/.cargo/bin to PATH if it exists.
if [ -d "$HOME/.cargo/bin" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Prepend ~/.nimble/bin to PATH if it exists.
if [ -d "$HOME/.nimble/bin" ]; then
    export PATH="$HOME/.nimble/bin:$PATH"
fi

# Use ~/.go instead of ~/go for GOPATH if it exists.
if [ -d "$HOME/.go" ]; then
    export GOPATH="$HOME/.go"
    export PATH="$GOPATH/bin:$PATH"
fi

# A good website to ping for network checks if in AUS.
export TELSTRA="139.130.4.5"

# Load hardware-specific or non-universal options from an untracked file.
if [ -r "$HOME/.zprofile.more" ]; then
    . "$HOME/.zprofile.more"
fi
