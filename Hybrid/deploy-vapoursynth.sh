#!/bin/sh
set -e
set -x

vsprefix="$HOME/opt/vapoursynth"
test -e "$vsprefix"

mkdir -p AppDir/usr/
cp -r "$vsprefix/include" "$vsprefix/lib" "$vsprefix/src" install-vs.sh AppDir/usr/

for l in AppDir/usr/lib/vapoursynth/*.so ; do
  cmdLine="$cmdLine -e$l"
done

wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod a+x linuxdeploy-x86_64.AppImage

# https://github.com/linuxdeploy/linuxdeploy/issues/86
sed -i 's|AI\x02|\x00\x00\x00|' linuxdeploy-x86_64.AppImage

LD_LIBRARY_PATH="$vsprefix/lib" ./linuxdeploy-x86_64.AppImage --appdir=AppDir $cmdLine || true
rm linuxdeploy-x86_64.AppImage

mv AppDir/usr/ vapoursynth
rmdir AppDir
cd vapoursynth
mv -f bin/*.so lib/vapoursynth/
rm -rf bin lib/python*/ lib/vapoursynth/*.la lib/*.la
mv lib/vapoursynth/ vsplugins
cd ..

now=$(date +"%Y%m%d")
mv vapoursynth vapoursynth_$now
7z a -m0=lzma2 -mx "vapoursynth_$now.7z" vapoursynth_$now

