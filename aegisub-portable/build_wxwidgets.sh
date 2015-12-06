#!/bin/bash -v

curdir="$PWD"

export CFLAGS="-O2 -fstack-protector-all -fno-strict-aliasing -ffunction-sections -fdata-sections -D_FORTIFY_SOURCE=2"
export CXXFLAGS="$CFLAGS"

rm -rf wxWidgets
git clone --depth 1 --branch WX_3_0_BRANCH "https://github.com/wxWidgets/wxWidgets.git"
cd wxWidgets
./configure --prefix="$curdir/libs" --enable-static --disable-shared --with-opengl
make -j4
make install

