#!/bin/bash
# should be a shell that provides $SECONDS

# build script for Ubuntu 16.04 or newer

set -e
set -x

JOBS=4
stamp="dependencies_for_vapoursynth_installed.stamp"

if [ ! -e $stamp -a -x "/usr/bin/apt" ]; then
  sudo apt update
  sudo apt upgrade
  sudo apt install --no-install-recommends \
    build-essential \
    git \
    python3-pip \
    autoconf \
    automake \
    libtool \
    python3-dev \
    libltdl-dev \
    libva-dev \
    libvdpau-dev \
    libass-dev \
    libtesseract-dev \
    libleptonica-dev \
    zlib1g-dev \
    libbz2-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    liblzma-dev \
    libfontconfig-dev \
    libfreetype6-dev \
    libfftw3-dev \
    libpango1.0-dev \
    libopenjp2-?-dev \
    libxml2-dev

  touch $stamp
fi

vsprefix="$HOME/opt/vapoursynth"

export PATH="$vsprefix/bin:$PATH"
export PKG_CONFIG_PATH="$vsprefix/lib/pkgconfig"
export CFLAGS="-pipe -O3 -fno-strict-aliasing -Wno-deprecated-declarations"
export CXXFLAGS="-pipe -O3 -fno-strict-aliasing -Wno-deprecated-declarations"

mkdir build
cd build

# newer nasm
if [ ! -x "$vsprefix/bin/nasm" ]; then
  ver="2.14.02"
  wget -c https://www.nasm.us/pub/nasm/releasebuilds/$ver/nasm-${ver}.tar.xz
  tar xf nasm-${ver}.tar.xz
  cd nasm-$ver
  ./configure --prefix="$vsprefix"
  make -j$JOBS
  make install
  cd ..
fi

#cat <<EOL >/dev/null

# build zimg, needed by Vapoursynth
git clone https://github.com/sekrit-twc/zimg
cd zimg
git checkout $(git tag | sort -V | tail -1)
autoreconf -if
./configure --prefix="$vsprefix" --disable-static
make -j$JOBS
make install-strip
cd ..

# build ImageMagick 7, needed by imwri plugin
git clone https://github.com/ImageMagick/ImageMagick
cd ImageMagick
git checkout $(git tag | grep '^7\.' | sort -V | tail -1)
PATH="$PWD:$PATH" autoreconf -if
./configure --prefix="$vsprefix" \
  --disable-static \
  --disable-docs \
  --without-utilities \
  --enable-hdri \
  --with-quantum-depth=16
make -j$JOBS
make install-strip
cd ..

# for nvidia support in ffmpeg
git clone --depth 1 https://github.com/FFmpeg/nv-codec-headers
make -C nv-codec-headers install PREFIX="$vsprefix"

# ffmpeg
git clone --depth 1 https://github.com/FFmpeg/FFmpeg
cd FFmpeg
./configure --prefix="$vsprefix" \
  --disable-static \
  --enable-shared \
  --disable-programs \
  --disable-doc \
  --disable-debug \
  --enable-avresample \
  --enable-ffnvcodec \
  --enable-nvdec \
  --enable-nvenc \
  --enable-cuvid \
  --enable-vaapi \
  --enable-vdpau
make -j$JOBS
make install

#EOL

# VapourSynth
export PYTHONUSERBASE="$vsprefix"
pip3 install -q --upgrade --user cython
git clone https://github.com/vapoursynth/vapoursynth
cd vapoursynth
git checkout $(git tag | grep '^R' | sort -V | tail -1)
autoreconf -if
./configure --prefix="$vsprefix" --disable-static
make -j$JOBS
make install-strip
pip3 uninstall -y -q cython

pyver=$(python3 -c "import sys; sys.stdout.write(sys.version[:3])")
cat <<EOF >"$vsprefix/env.sh"
# source this file with
export PYTHONPATH="$vsprefix/lib/python$pyver/site-packages:\$PYTHONPATH"
export LD_LIBRARY_PATH="$vsprefix/lib:\$LD_LIBRARY_PATH"
EOF

set +x

s=$SECONDS
printf "\nfinished after %d min %d sec\n" $(($s / 60)) $(($s % 60))

