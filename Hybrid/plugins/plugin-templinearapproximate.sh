git clone --depth 1 https://bitbucket.org/mystery_keeper/templinearapproximate-vapoursynth build
cd build
gcc $CFLAGS -Isrc -c src/main.c -o main.o
gcc $CFLAGS -Isrc -c src/processplane.c -o processplane.o
gcc $LDFLAGS -shared -o libtemplinearapproximate.so main.o processplane.o -lm
finish libtemplinearapproximate.so
