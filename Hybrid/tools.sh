#!/bin/bash

MAKEFLAGS="-j4"

build_nasm () {
  ver="2.14.02"
  wget https://www.nasm.us/pub/nasm/releasebuilds/$ver/nasm-${ver}.tar.xz
  tar xf nasm-${ver}.tar.xz
  cd nasm-$ver
  ./configure
  make $MAKEFLAGS
  cp nasm ..
  cd ..
  rm -rf nasm-$ver nasm-${ver}.tar.xz
}

build_ffdep () {
  cd $1
  if [ ! -x configure ] && [ -x autogen.sh ]; then
    ./autogen.sh || true
  fi
  if [ ! -x configure ]; then
    autoreconf -if
  fi
  PKG_CONFIG_PATH="$PKG_CONFIG_PATH" \
  CPPFLAGS="-I$PWD/../libs/include" \
    ./configure --prefix="$PWD/../libs" --disable-shared --enable-static $2
  make $MAKEFLAGS
  make install
  cd ..
}

set -e
set -x

if [ $# -eq 0 ]; then
  args="all"
else
  args="$*"
fi

sudo apt update
sudo apt upgrade -y
sudo apt install --no-install-recommends -y \
 build-essential \
 git \
 subversion \
 wget \
 cmake \
 nasm \
 yasm \
 unzip \
 upx-ucl \
 autoconf \
 automake \
 gettext \
 libtool-bin \
 pkg-config \
 qt5-default \
 docbook-xsl \
 xsltproc \
 rake \
 ragel \
 libgl1-mesa-dev \
 libboost-filesystem-dev \
 libboost-system-dev \
 libboost-regex-dev \
 libboost-date-time-dev \
 libdvdread-dev \
 libogg-dev \
 libvorbis-dev \
 libflac-dev \
 zlib1g-dev \
 liblzma-dev \
 libbz2-dev \
 libpng-dev \
 libjpeg-dev \
 libgif-dev \
 libopenal-dev \
 libasound-dev \
 libpulse-dev \
 libopencore-amrnb-dev \
 libopencore-amrwb-dev \
 libmp3lame-dev \
 libopus-dev \
 libopusfile-dev \
 libsndfile-dev \
 libwavpack-dev \
 libmagic-dev \
 libnuma-dev \
 libbluray-dev \
 libxvidcore-dev \
 libva-dev \
 libvdpau-dev \
 libxml2-dev \
 libfreetype6-dev \
 libfontconfig1-dev \
 libxcb1-dev \
 libxcb-shm?-dev \
 libxcb-xfixes?-dev \
 libxcb-shape?-dev

sudo apt clean

rm -rf build


### downloads only ###

### nvhsp
if echo "$args" | grep -q -i -w -E 'all|nvhsp|nvhsp.py'
then
  git clone --depth 1 https://github.com/SK-Hardwired/nv_hevc_hdr_patcher build
  cd build
  git clone --depth 1 https://github.com/scott-griffiths/bitstring

  cat <<EOL >header1.txt
#!/usr/bin/env python3

# https://github.com/SK-Hardwired/nv_hevc_hdr_patcher
# $(git rev-parse HEAD)

# https://github.com/scott-griffiths/bitstring
# $(git -C bitstring rev-parse HEAD)

# begin bitstring.py

EOL

cat <<EOL >header2.txt


# begin nvhsp.py

EOL
  cat header1.txt bitstring/bitstring.py header2.txt nvhsp.py > ../nvhsp

  cd ..
  sed -i 's|^from bitstring import|#from bitstring import|' nvhsp
  chmod a+x nvhsp
  rm -rf build
fi

### DivX265
if echo "$args" | grep -q -i -w -E 'all|divx265'
then
  mkdir build
  cd build
  wget -O DivX265 http://download.divx.com/hevc/DivX265_1_5_8
  chmod a+x DivX265
  cp -f DivX265 ..
  cd ..
  rm -rf build
fi

### neroAac
if echo "$args" | grep -q -i -w -E 'all|neroaac|neroaacenc'
then
  mkdir build
  cd build
  url="https://www.videohelp.com/download/NeroAACCodec-1.5.4.zip"
  wget --referer $url $url
  unzip NeroAACCodec-1.5.4.zip
  chmod a+x linux/neroAacEnc
  cp -f linux/neroAacEnc ..
  cd ..
  rm -rf build
fi

### tsMuxeR
if echo "$args" | grep -q -i -w -E 'all|tsmuxer'
then
  mkdir build
  cd build
  url="https://www.videohelp.com/download/tsMuxeR_2.6.11.tar.gz"
  wget --referer $url $url
  tar xf tsMuxeR_2.6.11.tar.gz
  upx-ucl -d tsMuxeR
  strip tsMuxeR
  chmod a+x tsMuxeR
  cp -f tsMuxeR ..
  cd ..
  rm -rf build
fi



### fast builds ###

### telxcc
if echo "$args" | grep -q -i -w -E 'all|telxcc'
then
  git clone https://github.com/kanongil/telxcc build
  gcc -O3 build/telxcc.c -o telxcc -s
  cat <<EOL >telxcc-sources.txt
https://github.com/kanongil/telxcc
$(git -C build rev-parse HEAD)
EOL
  rm -rf build
fi

### FLVExtractCL
if echo "$args" | grep -q -i -w -E 'all|flvextract|flvextractcl'
then
  mkdir build
  cd build
  wget http://www.moitah.net/download/latest/FLVExtractCL_cpp.zip
  unzip FLVExtractCL_cpp.zip
  make
  strip FLVExtractCL
  cp -f FLVExtractCL ..
  cd ..
  rm -rf build
fi

### FrameCounter
if echo "$args" | grep -q -i -w -E 'all|framecounter'
then
  git clone https://github.com/Selur/FrameCounter build
  cd build
  qmake
  make
  strip FrameCounter
  cp -f FrameCounter ..
  cd ..
  rm -rf build
fi

### IdxSubCutter
if echo "$args" | grep -q -i -w -E 'all|idxsubcutter'
then
  git clone https://github.com/Selur/IdxSubCutter build
  cd build
  qmake
  make CXX="g++ -std=c++11"
  strip IdxSubCutter
  cp -f IdxSubCutter ..
  cd ..
  rm -rf build
fi

### vsViewer
if echo "$args" | grep -q -i -w -E 'all|vsviewer'
then
  git clone https://github.com/Selur/vsViewer build
  cd build
  git clone https://github.com/vapoursynth/vapoursynth vapoursynth-git
  cd vapoursynth-git
  git checkout $(git tag --list | sort -V | tail -1)
  cp include/*.h ../vapoursynth
  cd ..
  qmake
  make $MAKEFLAGS
  strip build/release-64bit-gcc/vsViewer
  cp -f build/release-64bit-gcc/vsViewer ..
  cd ..
  rm -rf build
  cat <<EOF >vsViewer_withenv.sh
#!/bin/sh
scriptDir="\$(dirname "\$(readlink -f "\$0")")"

env="\$HOME/opt/vapoursynth/env.sh"
if [ -f "\$env" ]; then
  echo "sourcing \$env"
  . "\$env"
else
  echo "'\$env' does not exist!"
fi

env="/opt/vapoursynth/env.sh"
if [ -f "\$env" ]; then
  echo "sourcing \$env"
  . "\$env"
else
  echo "'\$env' does not exist!"
fi

"\$scriptDir/vsViewer" \$*
EOF
  chmod a+x vsViewer_withenv.sh
fi

### lsdvd
if echo "$args" | grep -q -i -w -E 'all|lsdvd'
then
  git clone https://git.code.sf.net/p/lsdvd/git build
  cd build
  autoreconf -if
  ./configure
  make
  strip lsdvd
  cp -f lsdvd ..
  cd ..
  cat <<EOL >lsdvd-sources.txt
https://git.code.sf.net/p/lsdvd/git
$(git -C build rev-parse HEAD)
EOL
  rm -rf build
fi

### ffdcaenc
if echo "$args" | grep -q -i -w -E 'all|ffdcaenc|dcaenc'
then
  git clone https://github.com/filler56789/ffdcaenc-2 build
  cd build
  autoreconf -if
  ./configure --disable-shared
  make
  strip ffdcaenc
  cp -f ffdcaenc ..
  cd ..
  cat <<EOL >ffdcaenc-sources.txt
https://github.com/filler56789/ffdcaenc-2
$(git -C build rev-parse HEAD)
EOL
  rm -rf build
fi

### kvazaar
if echo "$args" | grep -q -i -w -E 'all|kvazaar'
then
  git clone https://github.com/ultravideo/kvazaar build
  cd build
  git checkout $(git tag --list | sort -V | grep -v rc | tail -1)
  ./autogen.sh
  ./configure --disable-shared
  make $MAKEFLAGS
  strip src/kvazaar
  cp -f src/kvazaar ..
  cd ..
  rm -rf build
fi

### lame
if echo "$args" | grep -q -i -w -E 'all|lame'
then
  mkdir build
  cd build
  ver=$(wget -q -O- 'https://sourceforge.net/p/lame/svn/HEAD/tree/tags' | \
    grep RELEASE_ | \
    sed -n 's,.*RELEASE__\([0-9_][^<]*\)<.*,\1,p' | \
    tr '_' '.' | \
    sort -V | \
    tail -1)
  wget https://sourceforge.net/projects/lame/files/lame/$ver/lame-${ver}.tar.gz
  tar xf lame-${ver}.tar.gz
  cd lame-${ver}
  ./configure --disable-shared --enable-nasm --disable-rpath --disable-gtktest
  make $MAKEFLAGS
  strip frontend/lame
  cp -f frontend/lame ../..
  cd ../..
  rm -rf build
fi

### faac
if echo "$args" | grep -q -i -w -E 'all|faac'
then
  git clone https://github.com/knik0/faac build
  cd build
  git checkout $(git tag --list | grep '^[1-9]' | sort -V | tail -1)
  ./bootstrap
  ./configure --disable-shared
  make $MAKEFLAGS
  strip frontend/faac
  cp -f frontend/faac ..
  cd ..
  rm -rf build
fi

### flac
if echo "$args" | grep -q -i -w -E 'all|flac'
then
  git clone https://github.com/xiph/flac build
  cd build
  git checkout $(git tag --list | sort -V | tail -1)
  ./autogen.sh
  ./configure --disable-shared --disable-rpath
  make $MAKEFLAGS
  strip src/flac/flac
  cp -f src/flac/flac ..
  cd ..
  rm -rf build
fi

### aften
if echo "$args" | grep -q -i -w -E 'all|aften'
then
  git clone https://git.code.sf.net/p/aften/code build
  mkdir -p build/build
  cd build/build
  cmake .. -DCMAKE_BUILD_TYPE=Release -DSHARED=OFF
  make $MAKEFLAGS
  strip aften
  cp -f aften ../..
  cd ../..
  rm -rf build
fi

### sox
# TODO: build static deps?
if echo "$args" | grep -q -i -w -E 'all|sox'
then
  git clone https://git.code.sf.net/p/sox/code build
  cd build
  git checkout $(git tag --list | sort -V | grep -v rc | tail -1)
  autoreconf -if
  ./configure --disable-shared
  make $MAKEFLAGS
  strip src/sox
  cp -f src/sox ..
  cd ..
  rm -rf build
fi

### delaycut
if echo "$args" | grep -q -i -w -E 'all|delaycut'
then
  git clone https://github.com/darealshinji/delaycut build
  cd build
  git checkout $(git tag --list | sort -V | tail -1)
  qmake
  make $MAKEFLAGS
  strip delaycut
  cp -f delaycut ..
  cd ..
  rm -rf build
fi



### not so fast builds ###

### BDSup2SubPlusPlus
if echo "$args" | grep -q -i -w -E 'all|bdsup2sub++|bdsup2subplusplus|bdsup2sub'
then
  git clone https://github.com/amichaeltm/BDSup2SubPlusPlus build
  cd build
  sed -i 's|QSettings::IniFormat, QSettings::UserScope, "bdsup2sub++", "bdsup2sub++"|QSettings::IniFormat, QSettings::UserScope, ".config", "bdsup2sub++"|' src/bdsup2sub.cpp
  git diff >../bdsup2sub++.patch
  qmake src/bdsup2sub++.pro
  make clean
  make $MAKEFLAGS
  strip bdsup2sub++
  cp -f bdsup2sub++ ..
  cd ..
  cat <<EOL >bdsup2sub++-sources.txt
https://github.com/amichaeltm/BDSup2SubPlusPlus
$(git -C build rev-parse HEAD)

Patch applied:
EOL
  cat bdsup2sub++.patch >> bdsup2sub++-sources.txt
  rm -rf build bdsup2sub++.patch
fi

### fdkaac
if echo "$args" | grep -q -i -w -E 'all|fdkaac|fdk-aac|aac-enc'
then
  git clone https://git.code.sf.net/p/opencore-amr/fdk-aac build
  cd build
  git checkout $(git tag --list | sort -V | grep -v rc | tail -1)
  ./autogen.sh
  ./configure --disable-shared --enable-example
  make $MAKEFLAGS
  strip aac-enc
  cp -f aac-enc ..
  cd ..
  rm -rf build
fi

### oggenc
if echo "$args" | grep -q -i -w -E 'all|oggenc'
then
  mkdir build
  cd build
  git clone https://github.com/xiph/ogg
  git clone https://github.com/xiph/vorbis
  git clone https://github.com/xiph/vorbis-tools

  cd ogg
  git checkout $(git tag --list | sort -V | tail -1)
  ./autogen.sh
  ./configure --prefix="$PWD/.." --disable-shared
  make
  make install

  cd ../vorbis
  git checkout $(git tag --list | sort -V | tail -1)
  ./autogen.sh
  PKG_CONFIG_PATH="$PWD/../lib/pkgconfig" ./configure --prefix="$PWD/.." --disable-shared
  make $MAKEFLAGS
  make install

  cd ../vorbis-tools
  git checkout $(git tag --list | sort -V | tail -1)
  ./autogen.sh
  PKG_CONFIG_PATH="$PWD/../lib/pkgconfig" ./configure
  make $MAKEFLAGS -C share
  make $MAKEFLAGS -C oggenc

  strip oggenc/oggenc
  cp -f oggenc/oggenc ../..
  cd ../..

  cat <<EOL >oggenc-sources.txt
https://github.com/xiph/ogg
$(git -C build/ogg rev-parse HEAD)

https://github.com/xiph/vorbis
$(git -C build/vorbis rev-parse HEAD)

https://github.com/xiph/vorbis-tools
$(git -C build/vorbis-tools rev-parse HEAD)
EOL
  rm -rf build
fi

### opusenc
if echo "$args" | grep -q -i -w -E 'all|opusenc'
then
  mkdir build
  cd build
  git clone https://github.com/xiph/opus
  git clone https://github.com/xiph/libopusenc
  git clone https://github.com/xiph/opusfile
  git clone https://github.com/xiph/opus-tools

  cd opus
  git checkout $(git tag --list | sort -V | tail -1)
  ./autogen.sh
  ./configure --prefix="$PWD/.." \
    --disable-shared \
    --disable-doc \
    --disable-extra-programs
  make $MAKEFLAGS
  make install

  cd ../libopusenc
  git checkout $(git tag --list | sort -V | tail -1)
  ./autogen.sh
  PKG_CONFIG_PATH="$PWD/../lib/pkgconfig" \
  ./configure \
    --prefix="$PWD/.." \
    --disable-shared \
    --disable-doc \
    --disable-examples
  make
  make install

  cd ../opusfile
  git checkout $(git tag --list | sort -V | tail -1)
  ./autogen.sh
  PKG_CONFIG_PATH="$PWD/../lib/pkgconfig" \
  ./configure \
    --prefix="$PWD/.." \
    --disable-shared \
    --disable-doc \
    --disable-examples \
    --disable-http
  make
  make install

  cd ../opus-tools
  git checkout $(git tag --list | sort -V | tail -1)
  ./autogen.sh
  PKG_CONFIG_PATH="$PWD/../lib/pkgconfig" \
  ./configure \
    --prefix="$PWD/.." \
    --disable-shared \
    --disable-assertions
  make $MAKEFLAGS

  strip opusenc
  cp -f opusenc ../..
  cd ../..

  cat <<EOL >opusenc-sources.txt
https://github.com/xiph/opus
$(git -C build/opus rev-parse HEAD)

https://github.com/xiph/libopusenc
$(git -C build/libopusenc rev-parse HEAD)

https://github.com/xiph/opusfile
$(git -C build/opusfile rev-parse HEAD)

https://github.com/xiph/opus-tools
$(git -C build/opus-tools rev-parse HEAD)
EOL
  rm -rf build
fi

### MP4Box
if echo "$args" | grep -q -i -w -E 'all|mp4box'
then
  git clone https://github.com/gpac/gpac build
  cd build
  git checkout $(git tag --list | sort -V | tail -1)
  ./configure --enable-static-bin
  make $MAKEFLAGS
  strip bin/gcc/MP4Box
  cp -f bin/gcc/MP4Box ..
  cd ..
  rm -rf build
fi

### mp4fpsmod
if echo "$args" | grep -q -i -w -E 'all|mp4fpsmod'
then
  git clone https://github.com/nu774/mp4fpsmod build
  cd build
  git checkout $(git tag --list | sort -V | tail -1)
  ./bootstrap.sh
  ./configure
  make $MAKEFLAGS
  strip mp4fpsmod
  cp -f mp4fpsmod ..
  cd ..
  rm -rf build
fi

### vpxenc
if echo "$args" | grep -q -i -w -E 'all|vpxenc'
then
  git clone --depth 1 https://chromium.googlesource.com/webm/libvpx build
  cd build
  ./configure \
    --disable-docs \
    --disable-unit-tests \
    --enable-vp8 \
    --enable-vp9 \
    --enable-vp9-highbitdepth \
    --enable-postproc \
    --enable-vp9-postproc \
    --enable-runtime-cpu-detect
  make $MAKEFLAGS
  strip vpxenc
  cp -f vpxenc ..
  cd ..

  cat <<EOL >vpxenc-sources.txt
https://chromium.googlesource.com/webm/libvpx
$(git -C build rev-parse HEAD)
EOL
  rm -rf build
fi



### slow builds ###

### rav1e
if echo "$args" | grep -q -i -w -E 'all|rav1e'
then
  git clone --depth 1 https://github.com/xiph/rav1e build
  cd build

  if [ ! -x "$HOME/.cargo/bin/cargo" ]; then
    wget -O rustup-init.sh https://sh.rustup.rs
    sh ./rustup-init.sh -y
  fi
  "$HOME/.cargo/bin/rustup" update || true

  build_nasm
  PATH="$PWD:$PATH" "$HOME/.cargo/bin/cargo" build --release
  strip target/release/rav1e
  cp -f target/release/rav1e ..
  cd ..

  cat <<EOL >rav1e-sources.txt
https://github.com/xiph/rav1e
$(git -C build rev-parse HEAD)
EOL
  rm -rf build
fi

### aomenc
if echo "$args" | grep -q -i -w -E 'all|aomenc'
then
  git clone --depth 1 https://aomedia.googlesource.com/aom build
  mkdir -p build/build-aom
  cd build/build-aom
  cmake .. -DCMAKE_BUILD_TYPE=Release -DCONFIG_SHARED=0
  make $MAKEFLAGS aomenc
  strip aomenc
  cp -f aomenc ../..
  cd ../..

  cat <<EOL >aomenc-sources.txt
https://aomedia.googlesource.com/aom
$(git -C build rev-parse HEAD)
EOL
  rm -rf build
fi

### mediainfo
if echo "$args" | grep -q -i -w -E 'all|mediainfo'
then
  mkdir build
  cd build
  ver=$(wget -q -O - "https://mediaarea.net/en/MediaInfo/Download/Source" | \
    grep -o 'MediaInfo_CLI_.*_GNU_FromSource\.tar\.xz' | \
    sed 's,MediaInfo_CLI_,,; s,_GNU_FromSource\.tar\.xz,,')
  wget https://mediaarea.net/download/binary/mediainfo/$ver/MediaInfo_CLI_${ver}_GNU_FromSource.tar.xz
  tar xf MediaInfo_CLI_${ver}_GNU_FromSource.tar.xz
  cd MediaInfo_CLI_GNU_FromSource
  ./CLI_Compile.sh
  strip MediaInfo/Project/GNU/CLI/mediainfo
  cp -f MediaInfo/Project/GNU/CLI/mediainfo ../..
  cd ../..
  rm -rf build
fi

### x265
if echo "$args" | grep -q -i -w -E 'all|x265'
then
  wget -c https://bitbucket.org/multicoreware/x265/get/tip.tar.bz2
  tar xf tip.tar.bz2
  mv multicoreware-x265-*/ build
  rm tip.tar.bz2

  mkdir -p build/build-x265
  cd build/build-x265

  build_nasm

  mkdir 8bit 10bit 12bit
  cd 12bit
  cmake ../../source \
    -DNASM_EXECUTABLE=../nasm \
    -DEXPORT_C_API=OFF \
    -DHIGH_BIT_DEPTH=ON \
    -DENABLE_SHARED=OFF \
    -DENABLE_HDR10_PLUS=ON \
    -DENABLE_CLI=OFF \
    -DMAIN12=ON
  make $MAKEFLAGS

  cd ../10bit
  cmake ../../source \
    -DNASM_EXECUTABLE=../nasm \
    -DEXPORT_C_API=OFF \
    -DHIGH_BIT_DEPTH=ON \
    -DENABLE_SHARED=OFF \
    -DENABLE_HDR10_PLUS=ON \
    -DENABLE_CLI=OFF
  make $MAKEFLAGS

  cd ../8bit
  cp ../10bit/libx265.a libx265_main10.a
  cp ../12bit/libx265.a libx265_main12.a
  cmake ../../source \
    -DNASM_EXECUTABLE=../nasm \
    -DENABLE_SHARED=OFF \
    -DENABLE_HDR10_PLUS=ON \
    -DEXTRA_LIB="x265_main10.a;x265_main12.a;-ldl" \
    -DEXTRA_LINK_FLAGS="-L. -s" \
    -DLINKED_10BIT=ON \
    -DLINKED_12BIT=ON
  make $MAKEFLAGS
  cp -f x265 ../../..
  cd ../../..
  rm -rf build
fi

### ffmbc
if echo "$args" | grep -q -i -w -E 'all|ffmbc'
then
  git clone --branch ffmbc --depth 1 https://github.com/bcoudurier/FFmbc build
  cd build
  ./configure --enable-gpl --disable-doc --disable-debug
  make $MAKEFLAGS
  cp -f ffmbc ..
  cd ..

  cat <<EOL >ffmbc-sources.txt
https://github.com/bcoudurier/FFmbc
$(git -C build rev-parse HEAD)
EOL
  rm -rf build
fi

### x264
if echo "$args" | grep -q -i -w -E 'all|x264'
then
  mkdir build
  cd build

  top="$PWD"
  export PATH="$top:$PATH"
  export PKG_CONFIG_PATH="$top/libs/lib/pkgconfig"

  git clone --depth 1 https://code.videolan.org/videolan/x264.git
  git clone --depth 1 https://github.com/l-smash/l-smash
  git clone --depth 1 https://github.com/FFMS/ffms2
  git clone --depth 1 https://github.com/FFmpeg/FFmpeg

  build_nasm

  cd FFmpeg
  ./configure --prefix="$top/libs" \
    --enable-gpl \
    --enable-version3 \
    --disable-encoders \
    --disable-muxers \
    --disable-outdevs \
    --disable-programs \
    --disable-doc \
    --disable-debug \
    --disable-xlib \
    --disable-sdl2 \
    --extra-cflags="-ffunction-sections -fdata-sections"
  make $MAKEFLAGS
  make install

  cd ../ffms2
  mkdir -p src/config
  autoreconf -if
  ./configure --prefix="$top/libs" --disable-shared
  make $MAKEFLAGS
  make install

  cd ../l-smash
  ./configure --prefix="$top/libs" --extra-cflags="-O2"
  make $MAKEFLAGS lib
  make install-lib

  cd ../x264
  ./configure --enable-strip --disable-gpac --extra-ldflags="$(pkg-config --static --libs ffms2) -Wl,--gc-sections"
  make $MAKEFLAGS
  cp -f x264 ../..
  cd ..

  cat <<EOL >../x264-sources.txt
https://code.videolan.org/videolan/x264.git
$(git -C x264 rev-parse HEAD)

https://github.com/l-smash/l-smash
$(git -C l-smash rev-parse HEAD)

https://github.com/FFMS/ffms2
$(git -C ffms2 rev-parse HEAD)

https://github.com/FFmpeg/FFmpeg
$(git -C FFmpeg rev-parse HEAD)
EOL

  cd ..
  rm -rf build
fi

### mplayer / mencoder
if echo "$args" | grep -q -i -w -E 'all|mencoder|mplayer'
then
  svn checkout svn://svn.mplayerhq.hu/mplayer/trunk build
  cd build
  git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git ffmpeg
  ./configure --disable-relocatable
  make $MAKEFLAGS
  strip mencoder mplayer
  cp -f mencoder mplayer ..
  cd ..
  rm -rf build
fi

### mkvtoolnix
if echo "$args" | grep -q -i -w -E 'all|mkvmerge|mkvextract|mkvinfo|mkvtoolnix'
then
  git clone https://gitlab.com/mbunkus/mkvtoolnix.git build
  cd build
  git checkout $(git tag --list | sort -V | tail -1)
  git submodule init
  git submodule update
  ./autogen.sh
  ./configure --disable-qt --enable-appimage
  rake $MAKEFLAGS
  strip src/{mkvextract,mkvinfo,mkvmerge}
  cp -f src/{mkvextract,mkvinfo,mkvmerge} ..
  cd ..
  rm -rf build
fi

### ffmpeg
if echo "$args" | grep -q -i -w -E 'all|ffmpeg'
then
  mkdir build
  cd build

  top="$PWD"
  export PATH="$top:$PATH"
  export PKG_CONFIG_PATH="$top/libs/lib/pkgconfig"

  git clone --depth 1 https://github.com/FFmpeg/FFmpeg ffmpeg-src
  git clone --depth 1 https://github.com/dyne/frei0r
  git clone --depth 1 https://github.com/fribidi/fribidi
  git clone --depth 1 https://github.com/harfbuzz/harfbuzz
  git clone --depth 1 https://github.com/ultravideo/kvazaar
  git clone --depth 1 https://github.com/libass/libass
  git clone --depth 1 https://code.videolan.org/videolan/libbluray.git
  git clone --depth 1 https://github.com/xiph/ogg
  git clone --depth 1 https://github.com/xiph/vorbis
  git clone --depth 1 https://github.com/xiph/theora
  git clone --depth 1 https://github.com/xiph/flac
  git clone --depth 1 https://chromium.googlesource.com/webm/libvpx
  git clone --depth 1 https://chromium.googlesource.com/webm/libwebp
  git clone --depth 1 https://code.videolan.org/videolan/x264.git
  git clone --depth 1 https://github.com/FFmpeg/nv-codec-headers
  git clone --depth 1 https://git.code.sf.net/p/opencore-amr/code opencore-amr
  git clone --depth 1 https://git.code.sf.net/p/opencore-amr/vo-amrwbenc
  git clone https://github.com/xiph/opus
  git clone --depth 1 https://github.com/xiph/libopusenc
  git clone --depth 1 https://github.com/xiph/opusfile
  svn checkout https://svn.code.sf.net/p/lame/svn/trunk/lame

  wget -O x265.tar.bz2 https://bitbucket.org/multicoreware/x265/get/tip.tar.bz2
  tar xf x265.tar.bz2
  mv multicoreware-x265-*/ x265

  build_nasm

  old_mkflags="$MAKEFLAGS"; MAKEFLAGS="-j1"
  build_ffdep fribidi
  MAKEFLAGS="$old_mkflags"

  cd harfbuzz && ./autogen.sh && cd ..
  build_ffdep harfbuzz "--with-glib=no"

  cd libbluray && git submodule init && git submodule update && cd ..
  build_ffdep libbluray "--disable-bdjava-jar --disable-doxygen-doc"

  build_ffdep kvazaar
  build_ffdep libass
  build_ffdep ogg
  build_ffdep flac
  build_ffdep vorbis
  build_ffdep theora
  build_ffdep opus
  build_ffdep libopusenc "--disable-doc --disable-examples"
  build_ffdep opusfile "--disable-doc --disable-examples --disable-http"
  build_ffdep libwebp
  build_ffdep libvpx "--enable-vp9-highbitdepth --disable-unit-tests --disable-examples --disable-tools --disable-docs"
  build_ffdep lame
  build_ffdep opencore-amr
  build_ffdep vo-amrwbenc
  make -C nv-codec-headers install PREFIX="$top/libs"

  cd "$top/frei0r"
  ./autogen.sh
  ./configure --prefix="$top/libs" --enable-static --disable-shared
  make $MAKEFLAGS
  cp frei0r.pc "$top/libs/lib/pkgconfig"
  cp include/frei0r.h "$top/libs/include"
  mkdir -p "$top/libs/lib/frei0r-1"
  cp src/.libs/*.a "$top/libs/lib/frei0r-1"

  cd "$top/x264"
  ./configure \
    --prefix="$top/libs" \
    --disable-cli \
    --enable-static \
    --disable-swscale \
    --disable-lavf \
    --disable-ffms \
    --disable-gpac \
    --disable-lsmash
  make $MAKEFLAGS
  make install

  cd "$top/x265/build/linux"
  MAKEFLAGS="$MAKEFLAGS" ./multilib.sh
  cp -f 8bit/libx265.a "$top/libs/lib"
  cp -f "$top/x265/source/x265.h" 8bit/x265_config.h "$top/libs/include"
  cat <<EOF >"$top/libs/lib/pkgconfig/x265.pc"
Name: x265
Description: H.265/HEVC video encoder
Version: 0
Libs: -L"$top/libs/lib" -lx265
Libs.private: -lstdc++ -lm -lrt -ldl -lnuma
Cflags: -I"$top/libs/include"
EOF

  cd "$top/ffmpeg-src"
  ./configure \
    --disable-debug \
    --pkg-config-flags="--static" \
    --extra-cflags="-O3 -ffunction-sections -fdata-sections -I$top/libs/include" \
    --extra-ldflags="-Wl,--gc-sections -pthread -L$top/libs/lib" \
    --ld="g++" \
    --enable-gpl \
    --enable-version3 \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-doc \
    --enable-avisynth \
    --enable-frei0r \
    --enable-libass \
    --enable-libbluray \
    --enable-libfontconfig \
    --enable-libfreetype \
    --enable-libfribidi \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopus \
    --enable-libtheora \
    --enable-libvo-amrwbenc \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libkvazaar \
    --enable-ffnvcodec \
    --enable-nvdec \
    --enable-nvenc \
    --enable-cuvid \
    --enable-libxcb \
    --enable-libxcb-shm \
    --enable-libxcb-xfixes \
    --enable-libxcb-shape \
    --enable-vaapi \
    --enable-vdpau \
    --enable-openal \
    --enable-libpulse \
    --disable-libjack
  make $MAKEFLAGS
  cp ffmpeg "$top/.."

  cd "$top"
  cat <<EOL >../ffmpeg-sources.txt
https://github.com/FFmpeg/FFmpeg
$(git -C ffmpeg-src rev-parse HEAD)

https://github.com/dyne/frei0r
$(git -C frei0r rev-parse HEAD)

https://github.com/fribidi/fribidi
$(git -C fribidi rev-parse HEAD)

https://github.com/harfbuzz/harfbuzz
$(git -C harfbuzz rev-parse HEAD)

https://github.com/ultravideo/kvazaar
$(git -C kvazaar rev-parse HEAD)

https://github.com/libass/libass
$(git -C libass rev-parse HEAD)

https://code.videolan.org/videolan/libbluray.git
$(git -C libbluray rev-parse HEAD)

https://github.com/xiph/ogg
$(git -C ogg rev-parse HEAD)

https://github.com/xiph/vorbis
$(git -C vorbis rev-parse HEAD)

https://github.com/xiph/theora
$(git -C theora rev-parse HEAD)

https://github.com/xiph/flac
$(git -C flac rev-parse HEAD)

https://chromium.googlesource.com/webm/libvpx
$(git -C libvpx rev-parse HEAD)

https://chromium.googlesource.com/webm/libwebp
$(git -C libwebp rev-parse HEAD)

https://code.videolan.org/videolan/x264.git
$(git -C x264 rev-parse HEAD)

https://github.com/FFmpeg/nv-codec-headers
$(git -C nv-codec-headers rev-parse HEAD)

opencore-amr: https://git.code.sf.net/p/opencore-amr/code
$(git -C opencore-amr rev-parse HEAD)

https://git.code.sf.net/p/opencore-amr/vo-amrwbenc
$(git -C vo-amrwbenc rev-parse HEAD)

git clone https://github.com/xiph/opus
$(git -C opus rev-parse HEAD)

https://github.com/xiph/libopusenc
$(git -C libopusenc rev-parse HEAD)

https://github.com/xiph/opusfile
$(git -C opusfile rev-parse HEAD)

https://svn.code.sf.net/p/lame/svn/trunk/lame
revision $(svn info lame | grep '^Revision:' | cut -d' ' -f2)

https://bitbucket.org/multicoreware/x265
$(cat x265/.hg_archival.txt)
EOL

  cd ..
  rm -rf build

  exit 0
fi
