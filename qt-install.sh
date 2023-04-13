#!/bin/bash
set -e
set -x

AQTPATH="/tmp/${RANDOM}-aqt"

mkdir qt
cd qt

pip3 install aqtinstall --target="$AQTPATH"

export PYTHONPATH="$AQTPATH"

# 5.12 branch
VER=$("$AQTPATH/bin/aqt" list-qt linux desktop | tr ' ' '\n' | grep '5\.12' | tail -1)
"$AQTPATH/bin/aqt" install-qt linux desktop $VER

rm -rf "$AQTPATH"
