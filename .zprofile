# $ZDOTDIR/.zprofile ($HOME/.zprofile by default)
# Sourced when starting as a login shell.
# Used to set portable session-wide environment variables, e.g. EDITOR, PATH, ...
# For hardware-specific or non-portable variables, use ./.zprofile.more instead.
# To autostart graphical servers, use ./.zprofile.more instead.


# Set preferred editor.
if [ -x "/usr/bin/nvim" ]; then
    export EDITOR="/usr/bin/nvim"
    export VISUAL="/usr/bin/nvim"
fi

# Prepend ~/.local/bin to PATH if it exists.
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Load hardware-specific or non-universal options from an untracked file.
if [ -r "$HOME/.zprofile.more" ]; then
    . "$HOME/.zprofile.more"
fi
