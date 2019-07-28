ghdl myrsloik/VapourSynth-FFT3DFilter
meson build
if ! ninja -C build -j4 ; then
  sed -i 's|fftwf_make_planner_thread_safe();||g; s|constexpr||g' FFT3DFilter.cpp  # hack
  ninja -C build -j4
fi
finish build/libfft3dfilter.so
