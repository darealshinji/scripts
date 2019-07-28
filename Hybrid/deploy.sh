#!/bin/bash

misc_files="vapoursynth.sh plugins.sh plugins/ README"
binaries_copy="nvhsp vapoursynth_env.sh"
binaries_qt="Hybrid bdsup2sub++ delaycut FrameCounter IdxSubCutter vsViewer"
binaries_32bit="DivX265 neroAacEnc tsMuxeR"
binaries_64bit="""
aac-enc
aften
aomenc
faac
ffdcaenc
ffmbc
ffmpeg
flac
FLVExtractCL
kvazaar
lame
lsdvd
mediainfo
mencoder
mkvextract
mkvinfo
mkvmerge
MP4Box
mp4fpsmod
mplayer
oggenc
opusenc
rav1e
sox
telxcc
vpxenc
x264
x265
"""

deploy_dir="hybrid"

set -e
set -x

sudo dpkg --add-architecture i386
sudo apt update
sudo apt upgrade -y

sudo apt install --no-install-recommends -y \
  build-essential \
  autoconf \
  automake \
  fuse \
  git \
  wget \
  p7zip-full \
  libqt5multimedia5 \
  libqt5multimedia5-plugins \
  libfreetype6:i386 \
  zlib1g:i386 \
  libgcc1:i386 \
  libstdc++6:i386

rm -rf $deploy_dir
mkdir $deploy_dir
cd $deploy_dir

git clone --depth=1 https://github.com/Selur/VapoursynthScriptsInHybrid vsscripts
rm -rf vsscripts/.git

url_deploy="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
url_qtdeploy="https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
wget $url_deploy || cp ../linuxdeploy-x86_64.AppImage .
wget $url_qtdeploy || cp ../linuxdeploy-plugin-qt-x86_64.AppImage .
chmod a+x *.AppImage

cmdLine="--appdir=. --plugin qt -l/usr/lib/i386-linux-gnu/libfreetype.so.6 -l/lib/i386-linux-gnu/libz.so.1"
for bin in $binaries_qt $binaries_64bit $binaries_32bit ; do
  cmdLine="$cmdLine -e../$bin"
done

./linuxdeploy-x86_64.AppImage $cmdLine
cp ../*.txt ./usr/share/doc

cd ..
cp $binaries_copy ./$deploy_dir/usr/bin
cp -r $misc_files ./$deploy_dir
cd $deploy_dir

mv ./usr/* .
mv ./bin/* .
mv ./share/doc .

git clone https://github.com/NixOS/patchelf
cd patchelf
./bootstrap.sh
./configure
make
cd ..

for bin in $binaries_qt $binaries_64bit ; do
  ./patchelf/src/patchelf --set-rpath '$ORIGIN/lib' $bin
done

for bin in $binaries_32bit ; do
  ./patchelf/src/patchelf --set-rpath '$ORIGIN/lib32' $bin
done

chmod a+x $binaries_qt $binaries_64bit $binaries_32bit $binaries_copy

cat <<EOF >qt.conf
[Paths]
Prefix = .
Plugins = plugins
Imports = qml
Qml2Imports = qml
EOF

rm -rf ./usr ./bin ./share ./patchelf *.AppImage
cd ..

rsync -r build/* $deploy_dir/vsfilters/
now=$(date +"%Y%m%d")
7z a -m0=lzma2 -mx "Hybrid_$now.7z" $deploy_dir

