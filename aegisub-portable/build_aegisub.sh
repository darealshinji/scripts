#!/bin/bash -v

curdir="$PWD"


commonflags="-Wall -Wextra -Wno-unused-parameter -Wno-unused-local-typedefs -O3 -fstack-protector-all -fno-strict-aliasing -ffunction-sections -fdata-sections -D_FORTIFY_SOURCE=2"

export CFLAGS="$commonflags -std=gnu99"
export CXXFLAGS="$commonflags -fno-strict-aliasing -std=c++11"

export LDFLAGS="-s -Wl,-z,relro -Wl,-z,defs -Wl,--as-needed -Wl,--gc-sections  -pthread -static-libstdc++"
export LIBS="-lpthread -ldl -lm"

export ICU_UC_LIBS="-Wl,-Bstatic $(pkg-config --libs icu-uc) -Wl,-Bdynamic -ldl"
export ICU_I18N_LIBS="-Wl,-Bstatic $(pkg-config --libs icu-i18n) -Wl,-Bdynamic -ldl"

export PKG_CONFIG_PATH="$curdir/libs/lib/pkgconfig"
export FFMS2_LIBS="$(pkg-config --libs ffms2) -lavformat -lavcodec -lswresample -lswscale -lavutil -Wl,-Bstatic -lz -Wl,-Bdynamic"
export FFTW3_LIBS="-Wl,-Bstatic -lfftw3 -Wl,-Bdynamic"
export HUNSPELL_CFLAGS="-I\"$curdir/libs/include\" -I\"$curdir/libs/include/hunspell\""

test -d aegisub || git clone --depth 1 "https://github.com/Aegisub/Aegisub.git" aegisub
cd aegisub

sed -i 's/$(LIBS_ICU)$/$(LIBS_ICU) -pthread -lpthread/' tools/Makefile
sed -i 's/ -fPIC//' libaegisub/Makefile
sed -i 's/with_openal="no"/with_openal="yes"/' configure.ac
patch < ../portable.patch libaegisub/unix/path.cpp
patch < ../fix-boost-defines.patch src/video_out_gl.cpp

autoreconf -ivf
./configure --disable-compiler-flags --disable-rpath --with-wx-prefix="$curdir/libs"
sed -i 's/-lpng/-Wl,-Bstatic -lpng -lz -Wl,-Bdynamic/' Makefile.inc
sed -i '/^LIBS_BOOST/d' Makefile.inc
echo 'LIBS_BOOST = -Wl,-Bstatic -lboost_filesystem -lboost_locale -lboost_regex -lboost_system -lboost_thread -lboost_chrono -Wl,-Bdynamic' >> Makefile.inc

make -j4 V=1
make install DESTDIR="$PWD/tmp"

