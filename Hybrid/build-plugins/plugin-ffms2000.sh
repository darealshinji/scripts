git clone https://github.com/FFMS/ffms2 build
cd build
git checkout ffms2000
./autogen.sh || cat config.log
make -j$JOBS
cp src/core/.libs/libffms2.so libffms2000.so
finish libffms2000.so
