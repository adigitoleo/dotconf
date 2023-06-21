# ZSH CONFIGURATION FILE
# Configuration for individual zsh sessions, NOT login sessions.
# Use ~/.zprofile or ~/.zlogin for login session configuration.

# Parameters, see `man zshparam`.
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
KEYTIMEOUT=10

# Options, see `man zshoptions`.
setopt NOTIFY NOMATCH NOBGNICE
setopt MENU_COMPLETE AUTO_LIST LIST_PACKED COMPLETE_IN_WORD
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS
unsetopt BEEP

# Key bindings, and vi mode. Always vi mode.
bindkey -v
bindkey ¶ vi-cmd-mode
bindkey '^[[Z' reverse-menu-complete
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# Make directory (and parents if necessary) and enter it.
mkcd() { mkdir -p -- "$1" && cd -P -- "$1" }
# Ignore whatever ripgrep would in tree output (requires ripgrep, tree).
rg,tree() { rg --files $@|tree --fromfile --dirsfirst }
# Remove white background from PNG image in-place (requires imagemagick).
rmbg() { convert -transparent white "${1:--}" "${1--}" }
# Invert RGB channel of a PNG image in-place (requires imagemagick).
rgbneg() { convert -channel RGB -negate "${1:--}" "${1:--}" }
# Share file to https://x0.at/ pastebin (requires curl).
share() { curl -F "file=@${2:--};filename=.${1:-txt}" https://x0.at/ }

#
# Asynchronous git status indicator.
#

_git_branch_status() {  # Adapted from <https://github.com/agkozak/agkozak-zsh-prompt>.
    emulate -L zsh
    setopt LOCAL_OPTIONS WARN_CREATE_GLOBAL
    local ref branch
    ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null)
    case $? in
        0 ) ;;  # Var $ref contains checked-out branch name.
        128 ) return ;;  # No git repo here.
        # Otherwise, check for detached HEAD.
        * ) ref=$(command git rev-parse --short HEAD 2>/dev/null) || return ;;
    esac
    branch=${ref#refs/heads/}

    if [[ -n $branch ]]; then
        local git_status symbols="" i=1 k
        git_status="$(LC_ALL=C GIT_OPTIONAL_LOCKS=0 command git status --show-stash 2>&1)"
        typeset -A messages
        messages=(
            'v^'    ' have diverged,'
            'v'     'Your branch is behind '
            '^'     'Your branch is ahead of '
            '+'     'new file:'
            'x'     'deleted:'
            '!'     'modified:'
            '>'     'renamed:'
            '?'     'Untracked files:'
            '$'     'Your stash currently has '
        )
        for k in 'v^' 'v' '^' '+' 'x' '!' '>' '?' '$'; do
            case $git_status in *${messages[$k]}* ) symbols+=$k ;; esac
            (( i++ ))
        done
        [[ -n $symbols ]] && symbols="(${symbols})"
        printf -- '%s %s' "$branch" "$symbols"
    fi
}

_set_git_branch_status() {  # Adapted from <https://github.com/agkozak/agkozak-zsh-prompt>.
    emulate -L zsh
    setopt LOCAL_OPTIONS NO_IGNORE_BRACES
    local fd="$1" response
    IFS='' builtin read -rs -d $'\0' -u "$fd" response
    zle -F ${fd}; exec {fd}<&-
    psvar[8]="$response"
    zle && zle .reset-prompt
}

_subst_async() {  # Adapted from <https://github.com/agkozak/agkozak-zsh-prompt>.
    emulate -L zsh
    setopt LOCAL_OPTIONS NO_IGNORE_BRACES
    typeset -g ASYNC_FD=13371
    exec {ASYNC_FD} < <(_git_branch_status)
    command true  # Bug workaround; see <http://www.zsh.org/mla/workers/2018/msg00966.html>.
    zle -F "$ASYNC_FD" _set_git_branch_status
}


#
# Widgets, hooks and ZLE customizations.
#
autoload -Uz add-zle-hook-widget add-zsh-hook

_vi_yank_clip() {
    zle vi-yank
    >/dev/null command -v wl-copy && printf "%s" "$CUTBUFFER"|wl-copy
}
zle -N _vi_yank_clip
bindkey -M vicmd 'y' _vi_yank_clip

_set_keymap_prompt() {
    case $KEYMAP in
        vicmd ) psvar[9]=':' ;;
        viins|main ) psvar[9]='>' ;;
    esac
    zle && { zle .reset-prompt; zle -R }
}
add-zle-hook-widget zle-line-init _set_keymap_prompt
add-zle-hook-widget zle-keymap-select _set_keymap_prompt

_run_async() {
    # Clear vi mode indicator and git indicators.
    psvar[8]=''
    psvar[9]=''
    # Disctinct background for remote sessions (that set SSH_TTY).
    [[ -n "${SSH_TTY+_}" ]] && { psvar[1]='4' && psvar[2]='15' } \
        || { psvar[1]='bg' && psvar[2]='4' }
    # Distinct color for non-login user (e.g. after su - <user>).
    who|2>/dev/null 1>&2 grep $(whoami) || psvar[2]='9'
    # Start async runners.
    _subst_async
}
add-zsh-hook precmd _run_async

_set_title() {
    # Show working directory in title bar of terminal emulator
    # <https://zsh.sourceforge.io/FAQ/zshfaq03.html>
    [[ -t 1 ]] || return
    case $TERM in
        alacritty|xterm*|rxvt*|(dt|k|a|E)term ) print -Pn "\e]2;%n@%m:%~\a" ;;
    esac
}
add-zsh-hook precmd _set_title

TRAPWINCH() {  # See <https://github.com/ohmyzsh/ohmyzsh/issues/3605#issuecomment-75271013>
    zle && { zle .reset-prompt; zle -R }
}


# Set PROMPT and RPROMPT.
setopt PROMPT_SUBST
if [ $TERM = "linux" ]; then
    PROMPT='%F{3}%n@%m %25<..<%~%<< %8v%f
%B%(?.%F{2}.%F{1})%#zsh%9v%b%f '
    RPROMPT='%(1j.[bg:%j] .)'
else
    PROMPT='%K{%1v}%F{%2v}%n@%m%k %F{3}%25<..<%~%<< %F{6}%8v%f
%B%(?.%F{2}.%F{1})%#zsh%9v%b%f '
    RPROMPT='%F{3}%(1j.[bg:%j] .)'
fi

# Set PS2 (continuation prompt)
PS2='%F{5}%_>%f '

# Load completions and aliases.
fpath=(~/.config/zsh/completions $fpath)
autoload -Uz compinit; compinit
if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi
if [[ -f "$HOME/.aliases" ]]; then
    source "$HOME/.aliases"
fi
