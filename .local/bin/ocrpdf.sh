#!/usr/bin/sh
# ----------- MESSAGING FUNCTIONS ---------------------------------------------
readonly SCRIPTNAME="${0##*/}"
usage() { # Print a short synopsis <https://pubs.opengroup.org/onlinepubs/9699919799/>
    printf 'Usage: %s [-h]\n' "$SCRIPTNAME"
    printf '       %s ' "$SCRIPTNAME"
    echo '[-l lang][-o filename][-p password][document]'
}
helpf() { # Print a longer help string
    echo 'Options:'
    echo '-l <language>     override default language(s) for tesseract OCR'
    echo '-o <filename>     filename to use for the output PDF (without `.pdf`)'
    echo '-p <password>     user password for reading a locked PDF file'
    echo '<document>        the input PDF document'
    echo
    echo 'Run tesseract (optical character recognition) on a single PDF file,'
    echo 'to create a searchable PDF document in the same directory.'
    echo 'The output file will use the original document name,'
    echo 'with the suffix `_searchable` appended before the file extension,'
    echo 'unless overriden with the `-o` option.'
    echo 'Languages are specified using 3-character ISO 639-2 codes.'
    echo 'Multiple languages may be given, separated by plus signs (+).'
    echo 'See also <https://github.com/ElectricRCAircraftGuy/PDF2SearchablePDF>.'
}
warn() { # warn [message]... Print message to stderr <https://stackoverflow.com/a/23550347>
    >&2 printf '%s\n' "${SCRIPTNAME}: $1"
}

# ----------- MAIN ROUTINES ---------------------------------------------------
FUNCRETURN=  # Store non-integer return values, see also <https://stackoverflow.com/a/18198358>
ARGSTR=  # Store argument string during processing
PDF_OUT=  # Store filename for output PDF
USR_PASS=  # Store the optional PDF password
OCR_LANG=  # Store the optional OCR language codes
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
count_files() { # count_files [glob] Count files matching glob
    [ -e "$1" ] && FUNCRETURN="$#" || return 1
}
ocr() { # ocr [input] [output] Run OCR on input PDF and write to output PDF
    if [ -f "$2" ] ; then
        warn "file ${2} already exists, aborting" && return 1
    fi
    is_command mktemp || { warn 'command mktemp not found, aborting' && return 1 ; }
    is_command pdftoppm || { warn 'command pdftoppm not found, aborting' && return 1 ; }
    is_command tesseract || { warn 'command tesseract not found, aborting' && return 1 ; }

    echo 'scanning PDF document...'
    readonly TEMP_DIR=$(mktemp --tmpdir --directory ocrpdf-XXXXXX)
    if [ -n "$USR_PASS" ] ; then
        pdftoppm -upw "$USR_PASS" -tiff -r 300 "$1" "${TEMP_DIR}/pg" \
            || { warn 'command pdftoppm failed, aborting' \
                && rm -rf "$TEMP_DIR" ; return 1 ; }
    else
        pdftoppm -tiff -r 300 "$1" "${TEMP_DIR}/pg" \
            || { warn 'command pdftoppm failed, aborting' \
                && rm -rf "$TEMP_DIR" ; return 1 ; }
    fi

    readonly TEMP_LIST=$(mktemp --tmpdir ocrpdf-XXXXXX.txt)
    count_files "$TEMP_DIR"/* && echo "found ${FUNCRETURN} pages" \
        || { warn 'no pages found, aborting' ; return 1 ; }
    # TODO: Ensure correct glob match sorting for the tiff pages.
    for FILE in "${TEMP_DIR}"/* ; do
        echo "$FILE" >> "$TEMP_LIST"
    done
    if [ -z "$OCR_LANG" ] ; then
        tesseract -l "$OCR_LANG" "$TEMP_LIST" "$2" pdf \
            || { warn 'tesseract failed, aborting' \
                && rm -rf "$TEMP_DIR" ; rm "$TEMP_LIST" ; return 1 ; }
    else
        tesseract "$TEMP_LIST" "$2" pdf \
            || { warn 'tesseract failed, aborting' \
                && rm -rf "$TEMP_DIR" ; rm "$TEMP_LIST" ; return 1 ; }
    fi
    echo "wrote searchable PDF to ${2}.pdf"
    rm -rf "$TEMP_DIR" ; rm "$TEMP_LIST"
}

[ $# -eq 0 ] && usage && exit 1
while [ $# -gt 0 ] ; do
    # NOTE: Long form options like `--help` are not POSIX compliant.
    case "$1" in "-"* ) lstrip "$1" '-' && ARGSTR="$FUNCRETURN" ;; esac
    # NOTE: Additional while loop required to support option clusters.
    while [ -n "$ARGSTR" ] ; do
        case "$ARGSTR" in
            'o' ) consume 'o' && shift ; PDF_OUT="$1" ; shift ;;
            'p' ) consume 'p' && shift ; USR_PASS="$1" ; shift ;;
            'l' ) consume 'l' && shift ; OCR_LANG="$1" ; shift ;;
            'h' ) usage && helpf ; exit 0 ;;
            * ) warn "${1} is not a valid option" && usage ; exit 1 ;;
        esac
    done

    if [ -z "$PDF_OUT" ] ; then
        rstrip "$1" '.pdf' && PDF_OUT="${FUNCRETURN}_searchable"
    fi
    ocr "$1" "$PDF_OUT" || exit 1
    shift
done
