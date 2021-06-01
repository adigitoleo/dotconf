#                                  _                            vim:fdm=marker
#                          _______| |__  _ __ ___
#                         |_  / __| '_ \| '__/ __|
#                        _ / /\__ \ | | | | | (__
#          adigitoleo's (_)___|___/_| |_|_|  \___| for zsh

# Save shell event history (command lines) to a file.
HISTFILE=~/.histfile
# Max. number of events to save in the interactive session history.
HISTSIZE=1000
# Max. number of events to save to the history file.
SAVEHIST=1000
# Some sensible defaults, check man zshoptions.
setopt nomatch notify appendhistory histignorealldups
# No annoying beep noises.
unsetopt beep
# Use vi-style modal keymaps.
bindkey -v
# Quicker mode switches.
export KEYTIMEOUT=1

# FUNCTIONS {{{1
# Runs automatically whenever the directory is changed.
function chpwd {
    # Activate Python venv if cd lands in the project root.
    if [[ -d ".venv-${PWD##*/}" ]]; then
        if [[ -z "$VIRTUAL_ENV" ]]; then
            source ".venv-${PWD##*/}/bin/activate"
        # Deactivate other Python venv if still active.
        elif [[ "$VIRTUAL_ENV" != "$(pwd)/.venv-${PWD##*/}" ]]; then
            deactivate
            source ".venv-${PWD##*/}/bin/activate"
        fi
    fi
    # List files after cd.
    ls --color=auto --group-directories-first
}

# Make directory and enter it.
function mkcd { mkdir "$1" && cd "$1" }

# Change cursor shape based on keymap mode.
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne "\e[2 q"
    else
        echo -ne "\e[5 q"
    fi
}
zle-line-init() { zle-keymap-select 'beam' }
zle-line-finish() { zle-keymap-select 'block' }
zle -N zle-keymap-select
zle -N zle-line-init

# Make <Tab> at empty prompt list contents instead.
function expand-or-complete-or-list {
    if [[ $#BUFFER == 0 ]]; then
        BUFFER="ls "
        CURSOR=3
        zle list-choices
        zle backward-kill-word
    else
        zle expand-or-complete
    fi
}
zle -N expand-or-complete-or-list
bindkey "^I" expand-or-complete-or-list


# MAPPINGS {{{1
# Create a zkbd compatible hash to use special keys, see man 5 terminfo.
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# Enable intuitive history search.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Set up or fix mappings.
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-beginning-search
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-beginning-search
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}" reverse-menu-complete

# Ctrl-P and Ctrl-N as optional substitutes for Up/Down arrows.
bindkey "^P" up-line-or-beginning-search
bindkey "^N" down-line-or-beginning-search

# Make j and k in vi mode also do the same thing.
bindkey -M vicmd "k" up-line-or-beginning-search
bindkey -M vicmd "j" down-line-or-beginning-search

# Make sure the terminal is in application mode, when ZLE is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi


# PROMPT {{{1
# Requires: zsh-pure-prompt-git [AUR].
if [[ -f "/usr/share/zsh/functions/Prompts/prompt_pure_setup" ]]; then
    autoload -U promptinit; promptinit
    print () {  # Hack to remove newlines between successive prompts.
        [ 0 -eq $# -a 'prompt_pure_precmd' = "${funcstack[-1]}" ] || builtin print "$@";
    }
    prompt pure
    # Show number of background jobs if any, and make default prompt green.
    RPROMPT="%(1j.[bg:%j] .)"
    zstyle :prompt:pure:prompt:success color 'green'
fi


# COMPLETION {{{1
autoload -Uz compinit; compinit
setopt menu_complete

# Requires fzf.
if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS='--multi --height 50% --layout=reverse --marker="+"
        --bind backward-eof:abort,tab:down,shift-tab:up
        --bind +:toggle-down,alt-\;:abort,ctrl-l:clear-selection+first
        --bind alt-j:preview-down,alt-k:preview-up
        --color fg:12,bg:-1,hl:1,fg+:-1,bg+:-1,hl+:1,preview-fg:3
        --color prompt:2,gutter:-1,pointer:-1,marker:6,spinner:3,info:3
        --color border:12,header:12
    '
    # Make Alt-f use fzf to find completions, e.g. after cd command.
    source /usr/share/fzf/completion.zsh
    export FZF_COMPLETION_TRIGGER=''
    bindkey "^[f" fzf-completion
    bindkey "^I" $fzf_default_completion

    # Requires ripgrep (rg).
    if command -v rg &>/dev/null; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --no-messages'
    fi
fi
# }}}

# Import additional shell aliases.
if [[ -f "$HOME/.aliases" ]]; then
    source "$HOME/.aliases"
fi
