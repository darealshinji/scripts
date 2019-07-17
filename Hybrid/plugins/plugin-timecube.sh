ghdl sekrit-twc/timecube
# check if g++ supports -mtune=skylake-avx512
if ! echo "" | g++ -mtune=skylake-avx512 -xc++ -c- 2>/dev/null ; then
  sed -i 's|-mtune=skylake-avx512||g' Makefile
fi
build vscube
