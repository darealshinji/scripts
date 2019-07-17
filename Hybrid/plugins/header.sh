#!/bin/sh
set -e

JOBS=4

ghdl ()
{
  git clone --depth 1 --recursive https://github.com/$1 build
  cd build
}

strip_copy ()
{
  chmod a-x $1
  strip $1
  nm -D --extern-only $1 | grep -q 'T VapourSynthPluginInit'
  cp -f $1 ..
}

finish ()
{
  strip_copy $1
  cd ..
  rm -rf build
}

build ()
{
  if [ -f meson.build ]; then
    meson build
    ninja -C build -j$JOBS
  elif [ -f waf ]; then
    python3 ./waf configure
    python3 ./waf build -j$JOBS
  else
    if [ ! -x configure -a -f configure.ac ]; then
      autoreconf -if
    fi

    if [ -x configure ]; then
      if grep -q -- '--extra-cflags' configure && grep -q -- '--extra-cxxflags' configure ; then
        ./configure --extra-cflags="$CFLAGS" --extra-cxxflags="$CXXFLAGS" --extra-ldflags="$LDFLAGS" || cat config.log
      elif grep -q -- '--extra-cflags' configure ; then
        ./configure --extra-cflags="$CFLAGS" --extra-ldflags="$LDFLAGS" || cat config.log
      elif grep -q -- '--extra-cxxflags' configure ; then
        ./configure --extra-cxxflags="$CXXFLAGS" --extra-ldflags="$LDFLAGS" || cat config.log
      else
        ./configure || cat config.log
      fi
    fi

    make -j$JOBS X86=1
  fi

  if [ -e .libs/${1}.so ]; then
    finish .libs/${1}.so
  elif [ -e build/${1}.so ]; then
    finish build/${1}.so
  else
    finish ${1}.so
  fi
}

mkgh ()
{
  ghdl $1
  build $2
}

set -x

vsprefix="$HOME/opt/vapoursynth"

export PATH="$vsprefix/bin:$PATH"
export LD_LIBRARY_PATH="$vsprefix/lib"
export PYTHONUSERBASE="$vsprefix"
export PKG_CONFIG_PATH="$vsprefix/lib/pkgconfig"
export CFLAGS="-pipe -O3 -Wno-attributes -fPIC -fvisibility=hidden -fno-strict-aliasing $(pkg-config --cflags vapoursynth) -I/usr/include/compute"
export CXXFLAGS="$CFLAGS -Wno-reorder"

