ghdl EleonoreMizo/fmtconv
cd build/unix
autoreconf -if
./configure || cat config.log
make -j$JOBS
cp .libs/libfmtconv.so ../..
cd ../..
finish libfmtconv.so
