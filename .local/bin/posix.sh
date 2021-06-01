#!/usr/bin/sh
# ----------- I/O FUNCTIONS ---------------------------------------------------
SCRIPTNAME="${0##*/}"
usage() { # Print a short synopsis <https://pubs.opengroup.org/onlinepubs/9699919799/>
    printf 'Usage: %s\n' "$SCRIPTNAME [-h]"
    printf '       %s ' "$SCRIPTNAME"
    echo '[-ab][-c command]'
}
helpf() { # Print a longer help string
    echo 'Options:'
    echo '-a                prints the letter A, can be combined with -b'
    echo '-b                prints the letter B, can be combined with -a'
    echo '-c <command>      check for command in the current shell'
    echo
    echo 'Header template for a robust Bourne shell script,'
    echo 'focusing on POSIX compliance and portability.'
    echo 'You can find the source file by running:'
    printf '  command -v %s\n' "$SCRIPTNAME"
    echo 'See also <https://github.com/dylanaraps/pure-sh-bible>.'
}
warn() { # warn [message]... Print message to stderr <https://stackoverflow.com/a/23550347>
    >&2 printf '%s\n' "$*"
}
quote() { # quote [string] Safe shell quoting? <https://www.etalabs.net/sh_tricks.html>
    printf '%s\n' "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/"
}

# ----------- MAIN ROUTINES ---------------------------------------------------
FUNCRETURN=  # Store non-integer return values, see also <https://stackoverflow.com/a/18198358>
ARGSTR=  # Store argument string during processing
lstrip() { # lstrip [string] [pattern] Strip pattern from start of string
    FUNCRETURN="${1##$2}"
}
rstrip() { # rstrip [string] [pattern] Strip pattern from end of string
    FUNCRETURN="${1%%$2}"
}
consume() { # consume [letter] Consume a command line option
    lstrip "$ARGSTR" "$1" && ARGSTR="$FUNCRETURN"
}
is_command() { # Check if command exists, for flow control (no stdout messages)
    1>/dev/null 2>&1 command -v "$1" && [ "$?" -eq 0 ] && return 0 \
        || warn 'command' "$1" 'not found' && return 1
}

[ $# -eq 0 ] && usage && exit 1
while [ $# -gt 0 ] ; do
    # NOTE: Long form options like `--help` are not POSIX compliant.
    case "$1" in "-"* ) lstrip "$1" '-' && ARGSTR="$FUNCRETURN" ;; esac
    # NOTE: Additional while loop required to support option clusters.
    while [ -n "$ARGSTR" ] ; do
        case "$ARGSTR" in
            'a'* ) consume 'a' && echo 'A' ;;
            'b'* ) consume 'b' && echo 'B' ;;
            'c' ) consume 'c' && shift ; is_command "$1" || exit 1 ;;
            'h' ) usage && helpf ; exit 0 ;;
            * ) warn "$1" 'is not a valid option' && usage ; exit 1 ;;
        esac
    done
    shift
done
