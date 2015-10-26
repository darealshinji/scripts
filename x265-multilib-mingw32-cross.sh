#!/bin/sh

build_x265 () {
	arch=$1
	asm=$2
	verbose=$3
	mkflags=$4

	cmake_flags="-DCMAKE_SYSTEM_NAME=Windows \
		-DCMAKE_C_COMPILER=/usr/bin/${arch}-w64-mingw32-gcc \
		-DCMAKE_CXX_COMPILER=/usr/bin/${arch}-w64-mingw32-g++ \
		-DCMAKE_RC_COMPILER=/usr/bin/${arch}-w64-mingw32-windres \
		-DCMAKE_RANLIB=/usr/bin/${arch}-w64-mingw32-ranlib \
		-DCMAKE_VERBOSE_MAKEFILE=$verbose \
		-DENABLE_SHARED=OFF \
		-DENABLE_ASSEMBLY=$asm \
		-DCMAKE_ASM_YASM_COMPILER=yasm"

	cd 12bit
	cmake ../source \
		$cmake_flags \
		-DHIGH_BIT_DEPTH=ON \
		-DEXPORT_C_API=OFF \
		-DENABLE_CLI=OFF \
		-DMAIN12=ON
	make $mkflags
	cp libx265.a ../8bit/libx265_main12.a

	cd ../10bit
	cmake ../source \
		$cmake_flags \
		-DHIGH_BIT_DEPTH=ON \
		-DEXPORT_C_API=OFF \
		-DENABLE_CLI=OFF
	make $mkflags
	cp libx265.a ../8bit/libx265_main10.a

	cd ../8bit
	cmake ../source \
		$cmake_flags \
		-DEXTRA_LIB="x265_main10.a;x265_main12.a" \
		-DEXTRA_LINK_FLAGS=-L. \
		-DLINKED_10BIT=ON \
		-DLINKED_12BIT=ON
	make $mkflags

	cd ..
}

mkflags=-j4
verbose=OFF
export LDFLAGS="-s -static-libgcc -static-libstdc++"


topdir="$PWD"


set -e
set -v


sudo apt-get install yasm cmake mercurial \
  mingw32 mingw32-binutils mingw32-runtime \
  mingw-w64 mingw-w64-i686-dev mingw-w64-tools mingw-w64-x86-64-dev

hg clone "https://bitbucket.org/multicoreware/x265" x265-build
cd x265-build
# checkout latest release
version=$(hg log -r "." --template "{latesttag}")
hg checkout $version


mkdir -p 8bit 10bit 12bit win-x86

build_x265 i686 OFF $verbose $mkflags
cp 8bit/x265.exe /usr/i686-w64-mingw32/lib/libwinpthread-1.dll win-x86

rm -rf 8bit 10bit 12bit
mkdir -p 8bit 10bit 12bit win-x64

build_x265 x86_64 ON $verbose $mkflags
cp 8bit/x265.exe /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll win-x64

rm -rf 8bit 10bit 12bit


mv win-x86 "$topdir"
mv win-x64 "$topdir"
cd "$topdir"
rm -rf x265-build

set +v
echo
echo "version: $version"

