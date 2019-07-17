mkdir build
cd build
wget http://www.avisynth.nl/users/vcmohan/vcmod/vcmod_src.7z
7z e vcmod_src.7z
sed -i 's|vapoursynth\.h|VapourSynth.h|g; s|vshelper.h|VSHelper.h|g' vcmod.cpp  # Linux is case-sensitive
g++ -std=c++11 $CXXFLAGS $LDFLAGS -shared vcmod.cpp -o libvcmod.so
finish libvcmod.so
