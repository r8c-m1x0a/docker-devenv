FROM ubuntu:22.04

ENV PATH=/usr/local/m32c-elf/bin:$PATH
ARG BIN_UTIL_VER=2.40
ARG GCC_VER=12.2.0
ARG NEW_LIB_VER=4.1.0

RUN \
  apt-get -y update && \
  apt-get -y install texinfo libgmp-dev libmpfr-dev libmpc-dev diffutils automake zlib1g-dev \
    clang wget build-essential git libboost-dev scons cmake gdb doxygen lcov

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
  cd ~/r8c/gcc-${GCC_VER}/gcc/config/m32c && \
  {  \
     echo '--- old/m32c.cc 2022-08-19 08:09:52.648663341 +0000'; \
     echo '+++ new/m32c.cc 2023-03-25 01:46:20.722151623 +0000'; \
     echo '@@ -4013,9 +4013,13 @@'; \
     echo ' m32c_leaf_function_p (void)'; \
     echo ' {'; \
     echo '   int rv;'; \
     echo '+  struct sequence_stack *tem;'; \
     echo ' '; \
     echo '   push_topmost_sequence ();'; \
     echo '+  tem = get_current_sequence ()->next;'; \
     echo '+  get_current_sequence ()->next = nullptr;'; \
     echo '   rv = leaf_function_p ();'; \
     echo '+  get_current_sequence ()->next = tem;'; \
     echo '   pop_topmost_sequence ();'; \
     echo '   return rv;'; \
     echo ' }'; \
  } > patch.gcc && \
  patch m32c.cc < patch.gcc && \
  mkdir ~/r8c/gcc-${GCC_VER}/m32c_build && \
  cd ~/r8c/gcc-${GCC_VER}/m32c_build && \
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
  rm newlib/libc/stdlib/arc4random.c; touch newlib/libc/stdlib/arc4random.c && \
  rm newlib/libc/search/hash.c; touch newlib/libc/search/hash.c && \
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
  rm libstdc++-v3/src/c++11/cow-stdexcept.cc; touch libstdc++-v3/src/c++11/cow-stdexcept.cc && \
  rm libstdc++-v3/src/c++17/fs_ops.cc; touch libstdc++-v3/src/c++17/fs_ops.cc && \
  rm libstdc++-v3/src/c++17/fs_path.cc; touch libstdc++-v3/src/c++17/fs_path.cc && \
  rm libstdc++-v3/src/c++17/fs_dir.cc; touch libstdc++-v3/src/c++17/fs_dir.cc && \
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
  sed -i '/bool __class_type_info::/{N;/__do_upcast/s/^/__attribute__((optimize("O0")))\n/;}' libstdc++-v3/libsupc++/class_type_info.cc && \
  sed -i 's/d_maybe_print_designated_init (struct /__attribute__((optimize("O0"))) d_maybe_print_designated_init (struct /' libiberty/cp-demangle.c && \
  sed -i -rz 's/(CP_STATIC_IF_GLIBCPP_V3\s*struct demangle_component \*)(\s*cplus_demangle_type \(struct d_info \*di\))/\1 __attribute__((optimize("O0"))) \2/' libiberty/cp-demangle.c && \
  sed -i 's/d_print_comp_inner (struct/__attribute__((optimize("O0"))) d_print_comp_inner (struct/' libiberty/cp-demangle.c && \
  sed -i 's/^d_demangle_callback (const/__attribute__((optimize("O0"))) d_demangle_callback (const/' libiberty/cp-demangle.c && \
  sed -i 's/print_instance(PrintContext/__attribute__((optimize("O0"))) print_instance(PrintContext/' libstdc++-v3/src/c++11/debug.cc && \
  sed -i 's/error_category::equivalent(int __i/__attribute__((optimize("O0"))) error_category::equivalent(int __i/' libstdc++-v3/src/c++11/system_error.cc && \
  sed -i 's/error_category::_M_message(/__attribute__((optimize("O0"))) error_category::_M_message(/' libstdc++-v3/src/c++11/system_error.cc && \
  sed -i 's/__throw_system_error(int/__attribute__((optimize("O0"))) __throw_system_error(int/'  libstdc++-v3/src/c++11/system_error.cc && \
  sed -i 's/__collate_transform(current_abi, const facet\* f,/__attribute__((optimize("O0"))) __collate_transform(current_abi, const facet\* f,/' libstdc++-v3/src/c++11/cxx11-shim_facets.cc && \
  sed -i 's/do_copy_file(const char_type\* from, const char_type\* to,/__attribute__((optimize("O0"))) do_copy_file(const char_type* from, const char_type* to,/' libstdc++-v3/src/filesystem/ops-common.h && \
  sed -i 's/fs::copy(const path\& from, const path\& to, copy_options options,/__attribute__((optimize("O0"))) fs::copy(const path\& from, const path\& to, copy_options options,/' libstdc++-v3/src/c++17/fs_ops.cc && \
  sed -i 's/operator!=(const directory_iterator\& __lhs,/__attribute__((optimize("O0"))) operator!=(const directory_iterator\& __lhs,/' libstdc++-v3/include/bits/fs_dir.h && \
  sed -i 's/operator==(const directory_iterator\& __lhs,/__attribute__((optimize("O0"))) operator==(const directory_iterator\& __lhs,/' libstdc++-v3/include/bits/fs_dir.h && \
  sed -i 's/owner_before(__shared_ptr/__attribute__((optimize("O0"))) owner_before(__shared_ptr/' libstdc++-v3/include/bits/shared_ptr_base.h && \
  { \
    echo '--- old/gcc-12.2.0/libstdc++-v3/src/c++17/memory_resource.cc    2022-08-19 08:09:55.532700260 +0000'; \
    echo '+++ gcc-12.2.0/libstdc++-v3/src/c++17/memory_resource.cc        2023-03-25 05:20:55.856042212 +0000'; \
    echo '@@ -286,13 +286,16 @@'; \
    echo '   };'; \
    echo ' '; \
    echo '   void'; \
    echo '-  monotonic_buffer_resource::_M_new_buffer(size_t bytes, size_t alignment)'; \
    echo '+  __attribute__((optimize("O0"))) monotonic_buffer_resource::_M_new_buffer(size_t bytes, size_t alignment)'; \
    echo '   {'; \
    echo '     const size_t n = std::max(bytes, _M_next_bufsiz);'; \
    echo '     const size_t m = aligned_ceil(alignment, alignof(std::max_align_t));'; \
    echo '-    auto [p, size] = _Chunk::allocate(_M_upstream, n, m, _M_head);'; \
    echo '-    _M_current_buf = p;'; \
    echo '-    _M_avail = size;'; \
    echo '+//    auto [p, size] = _Chunk::allocate(_M_upstream, n, m, _M_head);'; \
    echo '+//    _M_current_buf = p;'; \
    echo '+//    _M_avail = size;'; \
    echo '+    auto a = _Chunk::allocate(_M_upstream, n, m, _M_head);'; \
    echo '+    _M_current_buf = a.first;'; \
    echo '+    _M_avail = a.second;'; \
    echo '     _M_next_bufsiz *= _S_growth_factor;'; \
    echo '   }'; \
  } > patch.gcc && \
  patch libstdc++-v3/src/c++17/memory_resource.cc < patch.gcc && \
  { \
    echo '--- /old/stl_algobase.h	2023-03-25 05:59:50.791128044 +0000'; \
    echo '+++ libstdc++-v3/include/bits/stl_algobase.h	2023-03-25 06:01:01.758521702 +0000'; \
    echo '@@ -1835,16 +1835,26 @@'; \
    echo ' 	  if constexpr (__is_byte_iter<_InputIter1>)'; \
    echo ' 	    if constexpr (__is_byte_iter<_InputIter2>)'; \
    echo ' 	      {'; \
    echo '-		const auto [__len, __lencmp] = _GLIBCXX_STD_A::'; \
    echo '+//		const auto [__len, __lencmp] = _GLIBCXX_STD_A::'; \
    echo '+//		  __min_cmp(__last1 - __first1, __last2 - __first2);'; \
    echo '+//		if (__len)'; \
    echo '+//		  {'; \
    echo '+//		    const auto __c'; \
    echo '+//		      = __builtin_memcmp(&*__first1, &*__first2, __len) <=> 0;'; \
    echo '+//		    if (__c != 0)'; \
    echo '+//		      return __c;'; \
    echo '+//		  }'; \
    echo '+//		return __lencmp;'; \
    echo '+		const auto a = _GLIBCXX_STD_A::'; \
    echo ' 		  __min_cmp(__last1 - __first1, __last2 - __first2);'; \
    echo '-		if (__len)'; \
    echo '+		if (a.first)'; \
    echo ' 		  {'; \
    echo ' 		    const auto __c'; \
    echo '-		      = __builtin_memcmp(&*__first1, &*__first2, __len) <=> 0;'; \
    echo '+		      = __builtin_memcmp(&*__first1, &*__first2, a.first) <=> 0;'; \
    echo ' 		    if (__c != 0)'; \
    echo ' 		      return __c;'; \
    echo ' 		  }'; \
    echo '-		return __lencmp;'; \
    echo '+		return a.second;'; \
    echo ' 	      }'; \
    echo ' '; \
    echo '       while (__first1 != __last1)'; \
  } > patch.gcc && \
  patch libstdc++-v3/include/bits/stl_algobase.h < patch.gcc && \
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

RUN \
  cd ~/r8c && \
  mkdir src && \
  cd src && \
  wget https://github.com/r8c-m1x0a/io/raw/main/src/r8c-m1xa-io.cpp && \
  wget https://github.com/r8c-m1x0a/io/raw/main/src/r8c-m1xa-io.h
