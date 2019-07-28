ghdl FFMS/ffms2
./autogen.sh || cat config.log
make -j$JOBS
finish src/core/.libs/libffms2.so
