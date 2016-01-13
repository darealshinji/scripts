#!/bin/bash -v

curdir="$PWD"

export CFLAGS="-O2 -fstack-protector-all -fno-strict-aliasing -ffunction-sections -fdata-sections -D_FORTIFY_SOURCE=2"
export CXXFLAGS="$CFLAGS"

rm -rf wxwidgets3.0_*
apt-get source wxwidgets3.0
cd wxwidgets3.0-*/
./configure --prefix="$curdir/libs" --enable-static --disable-shared --with-opengl
make -j4
make install

