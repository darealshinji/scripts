ghdl VFR-maniac/L-SMASH-Works
ghdl l-smash/l-smash

./configure --prefix="$vsprefix" --extra-cflags="$CFLAGS" || cat config.log
make -j$JOBS lib
cp liblsmash.a ..

cd ../VapourSynth
./configure --prefix="$vsprefix" \
  --extra-cflags="-I../build $CFLAGS -Wno-deprecated-declarations" \
  --extra-ldflags="-L.. $LDFLAGS" \
 || cat config.log

make -j$JOBS
cp libvslsmashsource.so.1 ../libvslsmashsource.so

cd ..
finish libvslsmashsource.so
