#!/bin/bash -v

curdir="$PWD"

mkdir ffms2
cd ffms2

git clone --depth 1 "git://source.ffmpeg.org/ffmpeg.git"
cd ffmpeg
CFLAGS="-fstack-protector-all -fno-strict-aliasing -ffunction-sections -fdata-sections -D_FORTIFY_SOURCE=2" \
./configure --prefix="$curdir/libs" --disable-programs --disable-doc --disable-bzlib --disable-lzma --disable-debug
sed -i 's/-O3/-O2/g' config.mak
make -j4
make install
cd ..

git clone --depth 1 "https://github.com/FFMS/ffms2.git"
cd ffms2
autoreconf -ivf
PKG_CONFIG_PATH="$curdir/libs/lib/pkgconfig" \
CXXFLAGS="-O2 -fstack-protector-all -fno-strict-aliasing -ffunction-sections -fdata-sections -Wno-missing-field-initializers -D_FORTIFY_SOURCE=2" \
./configure --prefix="$curdir/libs" --disable-shared --enable-static
make -j4
make install
