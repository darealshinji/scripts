ghdl DeadSix27/waifu2x-converter-cpp
mkdir build
cd build

cmake_flags="-DCMAKE_INSTALL_PREFIX=$vsprefix -DCMAKE_BUILD_TYPE=Release -DENABLE_GUI=OFF -DENABLE_CUDA=ON"
cmake .. $cmake_flags -DENABLE_OPENCV=ON || cmake .. $cmake_flags -DENABLE_OPENCV=OFF
make -j$JOBS
cp -f ../src/w2xconv.h $vsprefix/include/
cp -f libw2xc.so $vsprefix/lib/
cd ../..
rm -rf build

ghdl HomeOfVapourSynthEvolution/VapourSynth-Waifu2x-w2xc
rm -rf $vsprefix/lib/vapoursynth/models
cp -r Waifu2x-w2xc/models $vsprefix/lib/vapoursynth
build libwaifu2x-w2xc
