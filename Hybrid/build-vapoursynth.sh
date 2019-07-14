#!/bin/sh
# build script for Ubuntu 16.04 or newer

if [ $(id -u) -eq 0 ]; then
  # running as root or sudo
  prefix="/opt/vapoursynth"
else
  prefix="$HOME/opt/vapoursynth"
fi

set -e
set -x

sudo apt update
sudo apt upgrade
sudo apt install --no-install-recommends \
  build-essential \
  git \
  nasm \
  autoconf \
  automake \
  libtool \
  python3-dev \
  libass-dev \
  libtesseract-dev \
  libleptonica-dev \
  libavcodec-dev \
  libavformat-dev \
  libavutil-dev \
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

cd $(mktemp -d)

# build zimg, needed by Vapoursynth
git clone https://github.com/sekrit-twc/zimg
cd zimg
git checkout $(git tag | sort -V | tail -1)
autoreconf -if
./configure --prefix="$prefix" --disable-static
make -j4
make install-strip
cd ..
rm -rf zimg

# build ImageMagick 7, needed by imwri plugin
git clone https://github.com/ImageMagick/ImageMagick
cd ImageMagick
git checkout $(git tag | grep '^7\.' | sort -V | tail -1)
PATH="$PWD:$PATH" autoreconf -if
./configure --prefix="$prefix" \
  --disable-static \
  --disable-docs \
  --without-utilities \
  --enable-hdri \
  --with-quantum-depth=16
make -j4
make install-strip
cd ..
rm -rf ImageMagick "$prefix/bin"

export PKG_CONFIG_PATH="$prefix/lib/pkgconfig"
export CXXFLAGS="-O3 -fno-strict-aliasing"

git clone --depth 1 https://github.com/cython/cython
git clone https://github.com/vapoursynth/vapoursynth
cd vapoursynth
git checkout $(git tag | grep '^R' | sort -V | tail -1)
sed -i 's|-w -Worphan-labels -Wunrecognized-char||g' configure.ac
autoreconf -if
./configure --prefix="$prefix" \
  --disable-static \
  --with-cython="$PWD/../cython/cython.py"
make -j4
make install-strip
cd ..
rm -rf cython vapoursynth

pyver=$(python3 -c "import sys; sys.stdout.write(sys.version[:3])")
cat <<EOF >"$prefix/env.sh"
# source this file with
export PYTHONPATH="$prefix/lib/python$pyver/site-packages:\$PYTHONPATH"
export LD_LIBRARY_PATH="$prefix/lib:\$LD_LIBRARY_PATH"
#export PATH="$prefix/bin:\$PATH"
EOF

