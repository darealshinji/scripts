#!/bin/sh -e

# Create an X11 icon set from a single image file.
# Usage: make-icon.sh <icon> [<output-folder>]

# Last revision : 2014-09-07
# Requires: librsvg2-bin imagemagick


# Copyright (c) 2014, djcj <djcj@gmx.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


input="$1"
output1=$(basename "$1")
output="${output1%.*}"
tmp="${output1}_tmp.png"

if [ -z "$1" ] ; then
    echo "Usage: $0 <icon> [<output-folder>]"
    exit 1
elif [ ! -e "$1" ] ; then
    echo "Can't find '$1'!"
    exit 1
elif [ -d "$1" ] ; then
    echo "Input is a directory!"
    exit 1
fi

if [ -z "$2" ] ; then
    destdir=converted_icons
else
    destdir="$2"
fi


## Check if input is an SVG
if [ "${input##*.}" = "svg" ] || [ "${input##*.}" = "SVG" ] ; then
    svgdir="$destdir/icons/hicolor/scalable/apps"
    echo "install SVG"

	# install SVG into hicolor/scalable/apps
    install -c -D -m644 "$input" "$svgdir/$output1"

    # Create temporary input PNG file
    rsvg-convert "$input" -o "$tmp"
    input="$tmp"
fi


## Create XPM
pixmaps="$destdir/pixmaps"
mkdir -p "$pixmaps"
echo "create pixmap"
convert "$input" -filter Lanczos -resize 32x32 "$pixmaps/$output.xpm"


## Create PNGs
for n in 16 22 24 32 48 64 96 128 256 512
do
    w=$(identify -format "%w" "$input")
    h=$(identify -format "%h" "$input")

    if [ $w != $h ] ; then
        echo "hicolor icons require width and height to be equal, but input resolution is ${w}x${h}."
        echo "Didn't create hicolor icons."
        exit 0
    fi

    if [ $w -ge $n ] ; then
        icondestdir="$destdir/icons/hicolor/${n}x${n}/apps"
        mkdir -p "$icondestdir"
        echo "create hicolor ${n}x${n}"
        convert "$input" -filter Lanczos -resize ${n}x${n} "$icondestdir/$output.png"
    fi
done

if [ -f "$tmp" ] ; then
    rm "$tmp"
fi