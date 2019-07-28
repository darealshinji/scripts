# libjpeg-turbo may be provided by the system as static non-PIC library,
# so we build it from source instead.

ghdl chikuzen/vsimagereader
ghdl libjpeg-turbo/libjpeg-turbo

mkdir build
cd build
cmake .. -DCMAKE_C_FLAGS="$CFLAGS" -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DWITH_TURBOJPEG=ON -DWITH_JAVA=OFF
make -j$JOBS

cd ../../src
rm -f VapourSynth.h
cat >> config.mak << EOF
CC      = gcc
LD      = gcc
STRIP   = strip
LIBNAME = libvsimagereader.so
CFLAGS  = $CFLAGS -I../build -I../build/build
LDFLAGS = -shared -Wl,-soname,\$(LIBNAME) $LDFLAGS
LIBS    = ../build/build/libjpeg.a ../build/build/libturbojpeg.a -lpng
EOF
make -j$JOBS

cd ..
finish src/libvsimagereader.so
