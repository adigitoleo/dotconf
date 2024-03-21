#!/bin/sh
set -u
readonly SCRIPTNAME="${0##*/}"
usage() {
    printf 'Usage: %s [-h]\n' "$SCRIPTNAME"
    printf '       %s FILE\n' "$SCRIPTNAME"
}
helpf() {
    echo 'Operands:'
    printf '\tFILE\t%s\n' 'the file to preview'
    echo
    echo 'Preview script for fzf(1) menus. Requires file(1).'
    echo 'Optionally requires pdftotext from the poppler library'
    echo 'for PDF document content previews.'
}
while getopts "h" OPT; do
    case "$OPT" in
        h ) usage && helpf ; exit 0 ;;
        * ) usage ; exit 1 ;;
    esac
done
[ $# -eq 1 ] || { usage && exit 1 ; }

is_command() { command -v "$1" >/dev/null 2>&1 || echoerr "Preview unavailable"; }

file "$1"|cut -d':' -f2-|while IFS= read -r line ;
    do case "$line" in
        *"text"* )
            head -200 "$1" ;;
        *"PDF document"* )
            is_command pdftotext && pdftotext -layout -nodiag -l 1 "$1" - ;;
        * )
            echo "Preview unavailable" ;;
    esac
done
