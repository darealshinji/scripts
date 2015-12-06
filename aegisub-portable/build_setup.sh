#!/bin/sh -v

dir=aegisub-portable
prefix=aegisub/tmp/usr/local

rm -rf MojoSetup-Bins $dir

mkdir -p $dir/bin

mv $prefix/bin/aegisub-3.2 $prefix/bin/aegisub 2>/dev/null
install -m 0755 -D $prefix/bin/aegisub $dir/bin
install -m 0755 -D run-aegisub $dir/aegisub

cp libs/lib/libopenal.so.1 $dir/bin
chmod 0644 $dir/bin/libopenal.so.1
strip -s $dir/bin/*

cp -r $prefix/share/aegisub/automation $dir
cp -r $prefix/share/locale $dir
cp -r /usr/share/hunspell $dir/dictionaries

cp $prefix/share/icons/hicolor/64x64/apps/aegisub.png $dir/icon.png

git clone --depth 1 https://github.com/darealshinji/MojoSetup-Bins.git
cd MojoSetup-Bins

export FULLNAME=Aegisub
export SHORTNAME=Aegisub
export VENDOR=Aegisub.org
export START=aegisub
export ICON=icon.png
export SPLASH=../splash.png
export README=../README

./create-package.sh ../aegisub-portable

mv -f Aegisub-*-install.sh ..

