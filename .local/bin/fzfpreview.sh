#!/bin/sh

is_command() { command -v "$1" >/dev/null 2>&1 || echoerr "Preview unavailable"; }

case "$(file "$1")" in
    *"text"*)
        head -200 "$1" ;;
    *"PDF document"*)
        is_command pdftotext && pdftotext -layout -nodiag -l 1 "$1" - ;;
    *)
        echo "Preview unavailable" ;;
esac
