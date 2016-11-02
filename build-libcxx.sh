#!/bin/sh

# sudo apt-get install clang-3.6 llvm llvm-3.8-dev

cc="clang-3.6"
cxx="clang++-3.6"
llvm_cmake_dir="/usr/share/llvm-3.8/cmake"
prefix="$HOME/libcxx"

set -v
set -e

checkout="$(mktemp -d)"
cd $checkout
test -d libcxx || svn co http://llvm.org/svn/llvm-project/libcxx/trunk libcxx
test -d libcxxabi || svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk libcxxabi


### libc++abi ###

rm -rf libcxxabi/build
mkdir -p libcxxabi/build
cd libcxxabi/build

sed -i "s|\${LLVM_BINARY_DIR}\/lib\${LLVM_LIBDIR_SUFFIX}\/cmake\/llvm|$llvm_cmake_dir|" ../CMakeLists.txt

cmake .. -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$prefix" \
	-DCMAKE_C_COMPILER="$cc" \
	-DCMAKE_CXX_COMPILER="$cxx" \
	-DLLVM_CMAKE_PATH="$llvm_cmake_dir" \
	-DLIBCXXABI_LIBCXX_PATH="$checkout/libcxx" \
	-DLIBCXXABI_ENABLE_SHARED=OFF \
	-DLIBCXXABI_ENABLE_STATIC=ON \
	-DLIBCXXABI_ENABLE_THREADS=OFF
make -j4

mkdir -p "$prefix"
cp -rf lib "$prefix"

cd $checkout


### libc++ ###

rm -rf libcxx/build
mkdir -p libcxx/build
cd libcxx/build

sed -i "s|\${LLVM_BINARY_DIR}\/lib\${LLVM_LIBDIR_SUFFIX}\/cmake\/llvm|$llvm_cmake_dir|" \
	../cmake/Modules/HandleOutOfTreeLLVM.cmake

cmake .. -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$prefix" \
	-DCMAKE_C_COMPILER="$cc" \
	-DCMAKE_CXX_COMPILER="$cxx" \
	-DLIBCXX_CXX_ABI="libcxxabi" \
	-DLIBCXX_CXX_ABI_INCLUDE_PATHS="$checkout/libcxxabi/include" \
	-DLIBCXX_ENABLE_SHARED=OFF \
	-DLIBCXX_ENABLE_THREADS=OFF \
	-DLIBCXX_INCLUDE_DOCS=OFF
make -j4
make -C include install
cp -f "$checkout/libcxxabi/include"/* "$prefix/include"
cd lib
if [ -f "CMakeFiles/cxx_static.dir/link.txt" ]; then
	cxx_dir="cxx_static.dir"
elif [ -f "CMakeFiles/cxx.dir/link.txt" ]; then
	cxx_dir="cxx.dir"
else
	exit 1
fi
sh CMakeFiles/$cxx_dir/link.txt
cp -f libc++.a "$prefix/lib"

### libc++-wrapper ###
set +v
cat <<EOF> "$prefix/libc++-wrapper"
#!/bin/sh

prefix="$prefix"

gxx="g++"
cxxv1="\$prefix/include/c++/v1"
libcxxdir="\$prefix/lib"

if [ "x\$1" = "x" ]; then
	"\$gxx"
	exit \$?
fi

if (echo "\$*" | tr '\t' ' ' | grep -q -e ' -c '); then
	"\$gxx" \$* -nostdinc++ -I"\$cxxv1"
else
	"\$gxx" \$* -nostdinc++ -I"\$cxxv1" -nodefaultlibs \\
		-Wl,--no-as-needed "\$libcxxdir/libc++.a" "\$libcxxdir/libc++abi.a" -lc \\
		-Wl,--as-needed -lm -lgcc_s -lgcc -lpthread -ldl -lrt
fi

EOF
set -v

chmod a+x "$prefix/libc++-wrapper"

rm -rf $checkout

