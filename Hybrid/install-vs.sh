#!/bin/sh

vsprefix="$HOME/opt/vapoursynth"

if ! pkg-config --exists python3 ; then
  echo "Python 3 development files missing!"
  exit 1
fi

if [ -e "$vsprefix" ]; then
  echo "Path \`$vsprefix' already exists!"
  exit 1
fi

set -e
#set -x

cd "$(dirname "$0")"

echo "Copy files."
sitepackages="$vsprefix/lib/python3/site-packages"
mkdir -p "$sitepackages"
cp -r include lib vsplugins "$vsprefix"

echo "Build Python module."
gcc -shared -fPIC -O3 -Isrc  $(pkg-config --cflags python3) \
  src/src/cython/vapoursynth.c  -o "$sitepackages/vapoursynth.so" \
  -Llib -lvapoursynth  -s -Wl,-rpath,"$vsprefix/lib"

echo "Build VSScript library."
g++ -shared -fPIC -O3 -Isrc/include  $(pkg-config --cflags python3) \
  src/src/vsscript/vsscript.cpp  -o "$vsprefix/lib/libvapoursynth-script.so.0" \
  $(pkg-config --libs python3)  -s -Wl,-rpath,"$vsprefix/lib"  -Wl,-soname,libvapoursynth-script.so.0

ln -sf libvapoursynth-script.so.0 "$vsprefix/lib/libvapoursynth-script.so"

echo "Build VSPipe."
g++ -O3 -Isrc/include  src/src/vspipe/vspipe.cpp  -o "$vsprefix/vspipe" \
  -L"$vsprefix/lib" -lvapoursynth-script  -s -Wl,-rpath,"$vsprefix/lib"

#set +x

echo "Create \`$vsprefix/env.sh'"
cat <<EOF >"$vsprefix/env.sh"
# source this file with
# . "$vsprefix/env.sh"
export LD_LIBRARY_PATH="$vsprefix/lib:\$LD_LIBRARY_PATH"
export PYTHONPATH="$vsprefix/lib/python3/site-packages:\$PYTHONPATH"
EOF

# http://www.vapoursynth.com/doc/autoloading.html#linux
conf="$HOME/.config/vapoursynth/vapoursynth.conf"
echo "Create \`$conf'"
mkdir -p "$HOME/.config/vapoursynth"
echo "SystemPluginDir=$vsprefix/vsplugins" > "$conf"

echo "Finished."

