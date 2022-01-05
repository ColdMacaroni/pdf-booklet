#!/usr/bin/sh
# Uses pdfinfo, pdfcrop, pdftk, bc, grep, awk

# set -x
set -e

pdf_name="$1"
if [ -z "$pdf_name" ]
then
    >&2 echo "Please provide a pdf to split in half"
    exit 1
fi

# Get dimensions in pt using pdfinfo and grep

# Pass through cat -v to show non-printing characters.
# Necessary because, for example, converting a png to a pdf with convert from
# ImageMagick adds a NUL char at the end of the title, making grep not work
width=$(pdfinfo "$pdf_name" | cat -v | grep "Page size:" | awk '{printf $3}')
height=$(pdfinfo "$pdf_name" | cat -v | grep "Page size:" | awk '{printf $5}')

# For whatever reason if the pdf is not found the set -e doesnt catch it
if [ -z "$width" ]
then
    >&2 echo "pdf not found"
    exit 1
fi

# Convert to bp with bc to 6dp, use awk to print the leading 0
# width_bp=$(echo "scale=6; $width/1.00374" | bc | awk '{printf "%f", $1}')

new_width="$(echo "$width*2" | bc)"

gs \
    -o "wide.$pdf_name" \
    -sDEVICE=pdfwrite \
    -dDEVICEWIDTHPOINTS=$new_width \
    -dDEVICEHEIGHTPOINTS=$height \
    -dPDFFitPage \
    "$pdf_name"



# pdfcrop --margins "0 0 -$crop_bp 0" "$pdf_name" "/tmp/odd.$pdf_name"

set +e
