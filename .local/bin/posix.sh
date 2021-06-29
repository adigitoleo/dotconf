#!/bin/sh
# ----------- MESSAGING FUNCTIONS ---------------------------------------------
readonly SCRIPTNAME="${0##*/}"
usage() { # Print a short synopsis <https://pubs.opengroup.org/onlinepubs/9699919799/>
    printf 'Usage: %s [-h]\n' "$SCRIPTNAME"
    printf '       %s ' "$SCRIPTNAME"
    echo '[-ab][-c command|-d string][operand...]'
}
helpf() { # Print a longer help string
    echo 'Options:'
    echo '-a                prints the letter A, can be combined with -b,'
    echo '                  can be repeated any number of times'
    echo '-b                prints the letter B, can be combined with -a,'
    echo '                  cannot be repeated more than twice'
    echo '-c <command>      check for command in the current shell'
    echo '-d <string>       echo back the given string'
    echo '<operand>...      echo back operands after handling everything else'
    echo
    echo 'Template for a robust Bourne shell script,'
    echo 'focusing on POSIX compliance and portability.'
    echo 'You can find the source file by running:'
    printf '  command -v %s\n' "$SCRIPTNAME"
    echo 'See also <https://github.com/dylanaraps/pure-sh-bible>.'
}
warn() { # warn [message]... Print message to stderr <https://stackoverflow.com/a/23550347>
    >&2 printf '%s\n' "${SCRIPTNAME}: $1"
}
tell() { # tell [message]... Print message to stdout
    printf '%s\n' "${SCRIPTNAME}: $1"
}
quote() { # quote [string] Safe shell quoting? <https://www.etalabs.net/sh_tricks.html>
    printf '%s\n' "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/"
}

# ----------- MAIN ROUTINES ---------------------------------------------------
FUNCRETURN=  # Store non-integer return values, see also <https://stackoverflow.com/a/18198358>
ARGSTR=  # Store argument string during processing
COUNT_B=0  # Store the number of times that -b was given
OPT_C=false  # Store a boolean to tell if -c was given
OPT_D=false  # Store a boolean to tell if -d was given
lstrip() { # lstrip [string] [pattern] Strip pattern from start of string
    FUNCRETURN="${1##$2}"
}
rstrip() { # rstrip [string] [pattern] Strip pattern from end of string
    FUNCRETURN="${1%%$2}"
}
consume() { # consume [letter] Consume a command line option
    echo "$ARGSTR"
    lstrip "$ARGSTR" "$1" && ARGSTR="$FUNCRETURN"
}
is_command() { # Check if command exists, for flow control (no stdout messages)
    1>/dev/null 2>&1 command -v "$1" && [ "$?" -eq 0 ] && return 0 \
        || { warn "command '${1}' not found" && return 1 ;}
}
count_files() { # count_files [glob] Count files matching glob
    [ -e "$1" ] && FUNCRETURN="$#" || return 1
}

[ $# -eq 0 ] && usage && exit 1
# NOTE: Long form options like `--help` are not POSIX compliant.
while getopts "abc:d:h" OPT ; do
    case "$OPT" in
        a ) echo 'A' ;;
        b ) if [ $COUNT_B -eq 2 ] ; then
                warn "cannot specify -b more than twice" && exit 1
            else
                COUNT_B=$(("$COUNT_B" + 1)) && echo 'B'
            fi
            ;;
        c ) $OPT_D && warn "options -c and -d are mutually exclusive" && exit 1
            OPT_C=true && is_command "$OPTARG" || exit 1
            ;;
        d ) $OPT_C && warn "options -c and -d are mutually exclusive" && exit 1
            OPT_D=true && echo "$OPTARG"
            ;;
        h ) usage && helpf ; exit 0 ;;
    esac
done
shift $(($OPTIND - 1))
while [ $# -gt 0 ] ; do
    echo "remaining args (operands): $1"
    shift
done
