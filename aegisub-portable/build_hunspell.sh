#!/bin/bash -v

curdir="$PWD"
version="1.3.3"

export CFLAGS="-Wall -O2 -fstack-protector-all -fno-strict-aliasing -ffunction-sections -fdata-sections -D_FORTIFY_SOURCE=2"
export CXXFLAGS="$CFLAGS"

rm -rf hunspell-${version} hunspell_${version}.orig.tar.gz
wget "http://http.debian.net/debian/pool/main/h/hunspell/hunspell_${version}.orig.tar.gz"
tar xf hunspell_${version}.orig.tar.gz
rm -f hunspell_${version}.orig.tar.gz
cd hunspell-${version}
wget "http://http.debian.net/debian/pool/main/h/hunspell/hunspell_${version}-3.debian.tar.xz"
tar xf hunspell_${version}-3.debian.tar.xz

QUILT_PATCHES=debian/patches quilt push -a

./configure --prefix="$curdir/libs" --enable-static --disable-shared
make -j4
make install

