#!/bin/bash -v

version="3.0.2"
curdir="$PWD"

export CFLAGS="-O2 -fstack-protector -fno-strict-aliasing -D_FORTIFY_SOURCE=2"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-s -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,noexecstack -Wl,--as-needed -static-libstdc++"

rm -rf wxWidgets-${version} wxWidgets-${version}.tar.bz2
wget "https://github.com/wxWidgets/wxWidgets/releases/download/v${version}/wxWidgets-${version}.tar.bz2"

tar xf wxWidgets-${version}.tar.bz2
cd wxWidgets-${version}

./configure --prefix="$curdir/libs" --enable-static --disable-shared --with-opengl --with-x --with-gtk
make -j4
make install

