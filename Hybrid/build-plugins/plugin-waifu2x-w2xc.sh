ghdl HomeOfVapourSynthEvolution/VapourSynth-Waifu2x-w2xc
ghdl DeadSix27/waifu2x-converter-cpp

mkdir build
cd build

if [ "x$(pkg-config --modversion opencv | head -c2)" = "x3." ]; then
  enable_opencv="ON"
  opencv_libs="-Wl,--as-needed $(pkg-config --libs opencv)"
else
  enable_opencv="OFF"
  opencv_libs=""
fi

cmakeflags="-DCMAKE_BUILD_TYPE=Release -DENABLE_GUI=OFF -DENABLE_OPENCV=$enable_opencv"
cmake .. -DENABLE_CUDA=ON $cmakeflags || cmake .. -DENABLE_CUDA=OFF $cmakeflags
make -j$JOBS w2xc
cd ../..

g++ -std=c++11 $CXXFLAGS $LDFLAGS -shared -Ibuild/src Waifu2x-w2xc/Waifu2x-w2xc.cpp \
  -o libwaifu2x-w2xc.so build/build/CMakeFiles/w2xc.dir/src/*.o \
  $opencv_libs -lstdc++fs -ldl -lpthread

rm -rf ../models
cp -r Waifu2x-w2xc/models ..
finish libwaifu2x-w2xc.so
