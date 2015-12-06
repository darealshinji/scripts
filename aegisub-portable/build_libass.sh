#!/bin/bash -v

curdir="$PWD"

export CFLAGS="-O2 -fstack-protector-all -fno-strict-aliasing -ffunction-sections -fdata-sections -D_FORTIFY_SOURCE=2"
export CXXFLAGS="$CFLAGS"

mkdir libass
cd libass

git clone --depth 1 "https://github.com/behdad/harfbuzz.git"
cd harfbuzz
echo "EXTRA_DIST = " > gtk-doc.make
cp /usr/share/libtool/config/ltmain.sh .
autoreconf -ivf
./configure --prefix="$curdir/libs" --enable-static --disable-shared
make -j4
make install
cd ..


git clone --depth 1 "https://github.com/behdad/fribidi.git"
cd fribidi
cp /usr/share/libtool/config/ltmain.sh .
autoreconf -ivf
./configure --prefix="$curdir/libs" --enable-static --disable-shared
make -j4
make install
cd ..


git clone --depth 1 "https://github.com/nijel/enca.git"
cd enca
cp /usr/share/libtool/config/ltmain.sh .
autoreconf -ivf
./configure --prefix="$curdir/libs" --enable-static --disable-shared
make -j4
make install
cd ..


git clone --depth 1 "https://github.com/libass/libass.git"
cd libass
cp /usr/share/libtool/config/ltmain.sh .
autoreconf -ivf
PKG_CONFIG_PATH="$curdir/libs/lib/pkgconfig" \
./configure --prefix="$curdir/libs" --enable-static --disable-shared
make -j4
make install

