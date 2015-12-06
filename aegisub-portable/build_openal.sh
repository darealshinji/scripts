#!/bin/bash -v

curdir="$PWD"

CFLAGS="-Wall -O3 -fstack-protector-all -fno-strict-aliasing -ffunction-sections -fdata-sections -D_FORTIFY_SOURCE=2"
LDFLAGS="-s -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,noexecstack -Wl,-z,defs -Wl,--as-needed -Wl,--gc-sections"

rm -rf openal-soft
git clone --depth 1 "git://repo.or.cz/openal-soft.git"
cd openal-soft
cmake -DCMAKE_INSTALL_PREFIX="$curdir/libs" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS_RELEASE="$CFLAGS" \
	-DCMAKE_SHARED_LINKER_FLAGS="$LDFLAGS" \
	-DCMAKE_VERBOSE_MAKEFILE=ON .
make -j4
make install

