# ZSH CONFIGURATION FILE
# Configuration for individual zsh sessions, NOT login sessions.
# Use ~/.zprofile or ~/.zlogin for login session configuration.

# Parameters, see `man zshparam`.
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
KEYTIMEOUT=10

# Options, see `man zshoptions`.
setopt NOTIFY NOMATCH NOBGNICE COMPLETE_IN_WORD
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS
unsetopt BEEP

# Key bindings, and vi mode. Always vi mode.
bindkey -v
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search

# Make directory (and parents if necessary) and enter it.
function mkcd { mkdir -p -- "$1" && cd -P -- "$1" }

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
            'v^'    ' have diverged, '
            'v'     'Your branch is behind '
            '^'     'Your branch is ahead of '
            '+'     'new file: '
            'x'     'deleted: '
            '!'     'modified: '
            '>'     'renamed: '
            '?'     'Untracked files: '
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

_subst_async_callback() {  # Adapted from <https://github.com/agkozak/agkozak-zsh-prompt>.
    emulate -L zsh
    setopt LOCAL_OPTIONS NO_IGNORE_BRACES
    local fd="$1" response
    IFS='' builtin read -rs -d $'\0' -u "$fd" response
    zle -F ${fd}; exec {fd}<&-
    psvar[9]="$response"
    zle && zle .reset-prompt
}

_subst_async() {  # Adapted from <https://github.com/agkozak/agkozak-zsh-prompt>.
    emulate -L zsh
    setopt LOCAL_OPTIONS NO_IGNORE_BRACES
    typeset -g ASYNC_FD=13371
    exec {ASYNC_FD} < <(_git_branch_status)
    command true  # Bug workaround; see <http://www.zsh.org/mla/workers/2018/msg00966.html>.
    zle -F "$ASYNC_FD" _subst_async_callback
}


#
# Add hooks and ZLE customizations.
#
autoload -Uz add-zle-hook-widget

_keymap_mode_psvar() {
    case $KEYMAP in
        vicmd ) psvar[1]=':' ;;
        viins|main ) psvar[1]='>' ;;
    esac
    zle && { zle .reset-prompt; zle -R }
}
add-zle-hook-widget zle-line-init _keymap_mode_psvar
add-zle-hook-widget zle-keymap-select _keymap_mode_psvar

precmd() {
    emulate -L zsh
    # Clear vi mode indicator and git indicators.
    psvar[1]=''
    psvar[9]=''
    # Start async runners.
    _subst_async
}

TRAPWINCH() {  # See <https://github.com/ohmyzsh/ohmyzsh/issues/3605#issuecomment-75271013>
    zle && { zle .reset-prompt; zle -R }
}


# Set PROMPT and RPROMPT.
setopt PROMPT_SUBST
PROMPT='%F{3}%n@%m %F{4}%25<..<%~%<< %F{6}%9v%f
%B%(?.%F{2}.%F{1})%#zsh%1v%b%f '
RPROMPT='%F{3}%(1j.[bg:%j] .)'

# Load completions and aliases.
autoload -Uz compinit; compinit
if [[ -f "$HOME/.aliases" ]]; then
    source "$HOME/.aliases"
fi
