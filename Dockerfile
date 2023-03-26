FROM ubuntu:22.04

ENV PATH=/usr/local/m32c-elf/bin:$PATH
ARG BIN_UTIL_VER=2.40
ARG GCC_VER=7.5.0
ARG NEW_LIB_VER=4.1.0

RUN \
  apt-get -y update && \
  apt-get -y install texinfo libgmp-dev libmpfr-dev libmpc-dev diffutils automake zlib1g-dev \
    clang wget build-essential git libboost-dev scons cmake gdb

RUN \
  mkdir ~/r8c && \
  cd ~/r8c && \
  wget https://ftp.gnu.org/gnu/binutils/binutils-${BIN_UTIL_VER}.tar.gz && \
  tar xf binutils-${BIN_UTIL_VER}.tar.gz && \
  cd binutils-${BIN_UTIL_VER} && \
  mkdir m32c_build && \
  cd m32c_build && \
  ../configure --target=m32c-elf --prefix=/usr/local/m32c-elf --disable-nls --with-system-zlib && \
  make && \
  make install && \
  cd ~/r8c && \
  rm -rf binutils-${BIN_UTIL_VER}.tar.gz binutils-${BIN_UTIL_VER}

RUN \
  cd ~/r8c && \
  wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.gz && \
  tar xf gcc-${GCC_VER}.tar.gz && \
  cd gcc-${GCC_VER} && \
  cd libgcc && \
  rm fp-bit.c; touch fp-bit.c && \
  for i in unwind-*.c; do rm $i; touch $i; done && \
  cd .. && \
  mkdir m32c_build && \
  cd m32c_build && \
  ../configure --prefix=/usr/local/m32c-elf --target=m32c-elf --enable-languages=c --disable-libssp --with-newlib \
    --disable-nls --disable-threads --disable-libgomp --disable-libmudflap --disable-libstdcxx-pch --disable-multilib \
    --enable-lto --with-system-zlib --disable-float --disable-atomic && \
  make && \
  make install && \
  ln -s /usr/local/m32c-elf/bin/m32c-elf-gcc /usr/local/m32c-elf/bin/m32c-elf-cc
  
RUN \
  cd ~/r8c && \
  wget ftp://sourceware.org/pub/newlib/newlib-${NEW_LIB_VER}.tar.gz && \
  tar xf newlib-${NEW_LIB_VER}.tar.gz && \
  cd newlib-${NEW_LIB_VER} && \
  rm newlib/libc/stdlib/mprec.c; touch newlib/libc/stdlib/mprec.c && \
  rm newlib/libc/stdlib/ldtoa.c; touch newlib/libc/stdlib/ldtoa.c && \
  rm newlib/libc/search/hash_bigkey.c; touch newlib/libc/search/hash_bigkey.c && \
  rm newlib/libc/stdio/vdiprintf.c; touch newlib/libc/stdio/vdiprintf.c && \
  rm newlib/libc/stdio/vfwprintf.c; touch newlib/libc/stdio/vfwprintf.c && \
  rm newlib/libc/stdio/vdprintf.c; touch newlib/libc/stdio/vdprintf.c && \
  rm newlib/libc/stdio/vfscanf.c; touch newlib/libc/stdio/vfscanf.c && \
  rm newlib/libc/stdio/vfwscanf.c; touch newlib/libc/stdio/vfwscanf.c && \
  rm newlib/libc/time/tzcalc_limits.c; touch newlib/libc/time/tzcalc_limits.c && \
  rm newlib/libc/time/../time/strftime.c; touch newlib/libc/time/../time/strftime.c && \
  rm newlib/libm/math/k_rem_pio2.c; touch newlib/libm/math/k_rem_pio2.c && \
  rm newlib/libm/math/kf_rem_pio2.c; touch newlib/libm/math/kf_rem_pio2.c && \
  mkdir m32c_build && \
  cd m32c_build && \
  ../configure --target=m32c-elf --prefix=/usr/local/m32c-elf && \
  make && \
  make install && \
  cd ~/r8c && \
  rm -rf newlib-${NEW_LIB_VER}.tar.gz newlib-${NEW_LIB_VER}

RUN \
  cd ~/r8c/gcc-${GCC_VER} && \
  rm libstdc++-v3/src/c++98/complex_io.cc; touch libstdc++-v3/src/c++98/complex_io.cc && \
  rm libstdc++-v3/src/c++11/cow-sstream-inst.cc; touch libstdc++-v3/src/c++11/cow-sstream-inst.cc && \
  rm libstdc++-v3/src/c++11/cow-string-inst.cc; touch libstdc++-v3/src/c++11/cow-string-inst.cc && \
  rm libstdc++-v3/src/c++11/cow-wstring-inst.cc; touch libstdc++-v3/src/c++11/cow-wstring-inst.cc && \
  rm libstdc++-v3/src/c++11/cow-wstring-io-inst.cc; touch libstdc++-v3/src/c++11/cow-wstring-io-inst.cc && \
  rm libstdc++-v3/src/c++11/cxx11-locale-inst.cc; touch libstdc++-v3/src/c++11/cxx11-locale-inst.cc && \
  rm libstdc++-v3/src/c++11/fstream-inst.cc; touch libstdc++-v3/src/c++11/fstream-inst.cc && \
  rm libstdc++-v3/src/c++11/locale-inst.cc; touch libstdc++-v3/src/c++11/locale-inst.cc && \
  rm libstdc++-v3/src/c++11/streambuf-inst.cc; touch libstdc++-v3/src/c++11/streambuf-inst.cc && \
  rm libstdc++-v3/src/c++11/wstring-io-inst.cc; touch libstdc++-v3/src/c++11/wstring-io-inst.cc && \
  sed -i 's/^bool __pointer_to_member_type_info::/__attribute__((optimize("O0"))) \nbool __pointer_to_member_type_info::/' libstdc++-v3/libsupc++/pmem_type_info.cc && \
  sed -i '/CP_STATIC_IF_GLIBCPP_V3/{N;N;s/CP_STATIC_IF_GLIBCPP_V3\nstruct demangle_component \*\ncplus_demangle_type (struct d_info \*di)/__attribute__((optimize("O0"))) &/}' libiberty/cp-demangle.c && \
  sed -i 's/d_unqualified_name (struct d_info \*di)/__attribute__((optimize("O0"))) \nd_unqualified_name (struct d_info *di)/' libiberty/cp-demangle.c && \
  sed -i 's/d_ctor_dtor_name (struct d_info \*di)/__attribute__((optimize("O0"))) \nd_ctor_dtor_name (struct d_info *di)/' libiberty/cp-demangle.c && \
  sed -i 's/d_parmlist (struct d_info \*di)/__attribute__((optimize("O0"))) \nd_parmlist (struct d_info *di)/' libiberty/cp-demangle.c && \
  sed -i 's/d_expr_primary (struct d_info \*di)/__attribute__((optimize("O0"))) \nd_expr_primary (struct d_info *di)/' libiberty/cp-demangle.c && \
  sed -i 's/_List_node_base::swap(/__attribute__((optimize("O0"))) \n_List_node_base::swap(/' libstdc++-v3/src/c++98/list.cc && \
  sed -i 's/_List_node_base::swap(/__attribute__((optimize("O0"))) \n_List_node_base::swap(/' libstdc++-v3/src/c++98/list-aux.cc && \
  sed -i 's/local_Rb_tree_decrement(_Rb_tree_node_base\* __x)/__attribute__((optimize("O0"))) \nlocal_Rb_tree_decrement(_Rb_tree_node_base* __x)/' libstdc++-v3/src/c++98/tree.cc && \
  sed -i 's/_Rb_tree_insert_and_rebalance(const/__attribute__((optimize("O0"))) \n_Rb_tree_insert_and_rebalance(const/' libstdc++-v3/src/c++98/tree.cc && \
  sed -i 's/print_string(PrintContext/__attribute__((optimize("O0"))) \nprint_string(PrintContext/' libstdc++-v3/src/c++11/debug.cc && \
  sed -i '/_Safe_sequence_base::/{N;/_M_detach_singular()/s/^/__attribute__((optimize("O0")))\n/;}' libstdc++-v3/src/c++11/debug.cc && \
  sed -i '/_Safe_iterator_base::/{N;/_M_singular() const throw ()/s/^/__attribute__((optimize("O0")))\n/;}' libstdc++-v3/src/c++11/debug.cc && \
  sed -i 's/_Error_formatter::_M_error() const/__attribute__((optimize("O0"))) _Error_formatter::_M_error() const/'  libstdc++-v3/src/c++11/debug.cc && \
  sed -i 's/print_description(PrintContext\& ctx, const _Parameter\& param)/__attribute__((optimize("O0"))) print_description(PrintContext\& ctx, const _Parameter\& param)/'  libstdc++-v3/src/c++11/debug.cc && \
  sed -i '/__time_get(current_abi, const facet\* f,/ {N;/istreambuf_iterator<C> end,/ {N;/ios_base& io,/ {N;s/^/\t__attribute__((optimize("O0"))) /;}}}' libstdc++-v3/src/c++11/cxx11-shim_facets.cc && \
  sed -i '/ctype<wchar_t>::/{N;/do_scan_is/s/^/__attribute__((optimize("O0")))\n/;}' libstdc++-v3/config/locale/newlib/ctype_members.cc && \
  sed -i '/ctype<wchar_t>::/{N;/do_scan_not/s/^/__attribute__((optimize("O0")))\n/;}' libstdc++-v3/config/locale/newlib/ctype_members.cc && \
  cd m32c_build && \
  ../configure --prefix=/usr/local/m32c-elf --target=m32c-elf --enable-languages=c,c++ --disable-libssp \
    --with-newlib --disable-nls --disable-threads --disable-libgomp --disable-libmudflap --disable-libstdcxx-pch \
    --disable-multilib --enable-lto --with-system-zlib --disable-float --disable-atomic && \
  make && \
  make install && \
  cd ~/r8c && \
  rm -rf gcc-${GCC_VER}.tar.gz gcc-${GCC_VER}  

RUN \
  cd ~/r8c && \
  git clone https://github.com/google/googletest.git -b v1.13.0 && \
  cd googletest && \
  mkdir build && \
  cd build && \
  cmake .. && \
  make && \
  make install && \
  cd ../.. && \
  rm -rf googletest
